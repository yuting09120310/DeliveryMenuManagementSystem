using DMMS.Web.Data;
using DMMS.Web.Models;
using DMMS.Web.ViewModels;
using DMMS.Web.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DMMS.Web.Controllers;

public class AddOnsController(DmmsDbContext db) : Controller
{
    public async Task<IActionResult> Index()
    {
        try
        {
            var list = await db.AddOns.AsNoTracking().Include(a => a.Sizes).OrderBy(a => a.Name).ToListAsync();
            var used = (await db.ProductAddOns.AsNoTracking().Select(x => x.AddOnId).Distinct().ToListAsync()).ToHashSet();
            return View(new AddOnListViewModel
            {
                AddOns = list.Select(a => new AddOnListItemViewModel
                {
                    Id = a.Id, Name = a.Name, EnglishName = a.EnglishName, Price = a.Price,
                    ExternalData = a.ExternalData,
                    ExternalDataDisplay = new ExternalDataCalculator().CalculateAddOn(a),
                    IcedOnly = a.IcedOnly, FixedRatio = a.FixedRatio, IsEnabled = a.IsEnabled,
                    SizeSummary = string.Join("｜", a.Sizes.Where(s => s.IsEnabled).OrderBy(s => s.SortOrder).Select(s => $"{s.SizeName} {s.ExternalData} NT${s.Price:N0}")),
                    IsUsedByProduct = used.Contains(a.Id)
                }).ToList()
            });
        }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { return View(new AddOnListViewModel { DataError = "目前無法連線到資料庫，加料資料暫時無法載入。請確認 DefaultConnection 設定。" }); }
    }

    [HttpGet]
    public IActionResult Create() => View(NewVm());

    private static AddOnEditViewModel NewVm() => new() { Price = 0, Sizes = [new() { SizeName = "中杯", SortOrder = 0 }, new() { SizeName = "大杯", SortOrder = 1 }] };

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(AddOnEditViewModel model)
    {
        Clean(model);
        if (!ModelState.IsValid) { if (model.Sizes.Count == 0) model.Sizes = NewVm().Sizes; return View(model); }
        var addOn = new AddOn { Name = model.Name.Trim(), EnglishName = model.EnglishName?.Trim(), Price = model.Price, ExternalData = NormalizeAddOnCode(model.ExternalData), IcedOnly = model.IcedOnly, FixedRatio = model.FixedRatio, IsEnabled = model.IsEnabled };
        foreach (var s in model.Sizes.Where(x => !string.IsNullOrWhiteSpace(x.SizeName))) addOn.Sizes.Add(ToSize(s));
        db.AddOns.Add(addOn);
        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線與資料格式。"); return View(model); }
    }

    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var a = await db.AddOns.AsNoTracking().Include(x => x.Sizes).FirstOrDefaultAsync(x => x.Id == id);
        if (a is null) return NotFound();
        return View(new AddOnEditViewModel
        {
            Id = a.Id, Name = a.Name, EnglishName = a.EnglishName, Price = a.Price, ExternalData = a.ExternalData,
            IcedOnly = a.IcedOnly, FixedRatio = a.FixedRatio, IsEnabled = a.IsEnabled,
            Sizes = a.Sizes.OrderBy(s => s.SortOrder).Select(s => new AddOnSizeInputModel { Id = s.Id, SizeName = s.SizeName, ExternalData = s.ExternalData, Price = s.Price, IsEnabled = s.IsEnabled, SortOrder = s.SortOrder }).ToList()
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, AddOnEditViewModel model)
    {
        if (id != model.Id) return BadRequest();
        Clean(model);
        if (!ModelState.IsValid) return View(model);
        var a = await db.AddOns.Include(x => x.Sizes).FirstOrDefaultAsync(x => x.Id == id);
        if (a is null) return NotFound();
        a.Name = model.Name.Trim(); a.EnglishName = model.EnglishName?.Trim(); a.Price = model.Price;
        a.ExternalData = NormalizeAddOnCode(model.ExternalData); a.IcedOnly = model.IcedOnly; a.FixedRatio = model.FixedRatio; a.IsEnabled = model.IsEnabled;
        var incoming = model.Sizes.Where(x => !string.IsNullOrWhiteSpace(x.SizeName)).ToList();
        var existing = a.Sizes.ToDictionary(s => s.Id);
        foreach (var row in incoming)
        {
            if (row.Id > 0 && existing.TryGetValue(row.Id, out var target))
            {
                target.SizeName = row.SizeName.Trim(); target.ExternalData = NormalizeAddOnCode(row.ExternalData);
                target.Price = row.Price; target.IsEnabled = row.IsEnabled; target.SortOrder = row.SortOrder;
                existing.Remove(row.Id);
            }
            else a.Sizes.Add(ToSize(row));
        }
        foreach (var orphan in existing.Values) db.AddOnSizes.Remove(orphan);
        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線與資料格式。"); return View(model); }
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id)
    {
        var a = await db.AddOns.FirstOrDefaultAsync(x => x.Id == id);
        if (a is null) return NotFound();
        if (await db.ProductAddOns.AsNoTracking().AnyAsync(x => x.AddOnId == id))
        {
            TempData["Error"] = "此加料已被商品使用，無法刪除。請先解除商品關聯。";
            return RedirectToAction(nameof(Index));
        }
        db.AddOns.Remove(a);
        try { await db.SaveChangesAsync(); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { TempData["Error"] = "刪除失敗，請確認資料庫連線。"; }
        return RedirectToAction(nameof(Index));
    }

    private static void Clean(AddOnEditViewModel m)
    {
        m.Name = m.Name?.Trim() ?? ""; m.ExternalData = m.ExternalData?.Trim() ?? ""; m.EnglishName = string.IsNullOrWhiteSpace(m.EnglishName) ? null : m.EnglishName.Trim();
        // 只保留有填品號的尺寸列：沒填品號 = 該尺寸沿用主檔預設品號，不需存列
        m.Sizes = m.Sizes.Where(s => !string.IsNullOrWhiteSpace(s.ExternalData?.Trim())).ToList();
        foreach (var s in m.Sizes)
        {
            s.SizeName = string.IsNullOrWhiteSpace(s.SizeName) ? "預設" : s.SizeName.Trim();
            s.ExternalData = s.ExternalData.Trim();
        }
    }

    private static AddOnSize ToSize(AddOnSizeInputModel s) => new()
    {
        SizeName = s.SizeName.Trim(), ExternalData = NormalizeAddOnCode(s.ExternalData),
        Price = s.Price, IsEnabled = s.IsEnabled, SortOrder = s.SortOrder
    };

    public static string NormalizeAddOnCode(string raw)
    {
        var v = (raw ?? "").Trim();
        if (v.Length == 0) return v;
        return v.StartsWith('@') ? v : "@" + v;
    }
}
