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
            var list = await db.AddOns.AsNoTracking().OrderBy(a => a.Name).ToListAsync();
            return View(new AddOnListViewModel
            {
                AddOns = list.Select(a => new AddOnListItemViewModel
                {
                    Id = a.Id, Name = a.Name, EnglishName = a.EnglishName, Price = a.Price,
                    ExternalData = a.ExternalData,
                    ExternalDataDisplay = new ExternalDataCalculator().CalculateAddOn(a),
                    IcedOnly = a.IcedOnly, FixedRatio = a.FixedRatio, IsEnabled = a.IsEnabled
                }).ToList()
            });
        }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { return View(new AddOnListViewModel { DataError = "目前無法連線到資料庫，加料資料暫時無法載入。請確認 DefaultConnection 設定。" }); }
    }

    [HttpGet]
    public IActionResult Create() => View(new AddOnEditViewModel { Price = 0 });

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(AddOnEditViewModel model)
    {
        model.ExternalData = model.ExternalData?.Trim() ?? "";
        if (!ModelState.IsValid) return View(model);
        db.AddOns.Add(new AddOn
        {
            Name = model.Name.Trim(), EnglishName = model.EnglishName?.Trim(),
            Price = model.Price, ExternalData = NormalizeAddOnCode(model.ExternalData),
            IcedOnly = model.IcedOnly, FixedRatio = model.FixedRatio, IsEnabled = model.IsEnabled
        });
        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線與資料格式。"); return View(model); }
    }

    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var a = await db.AddOns.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (a is null) return NotFound();
        return View(new AddOnEditViewModel { Id = a.Id, Name = a.Name, EnglishName = a.EnglishName, Price = a.Price, ExternalData = a.ExternalData, IcedOnly = a.IcedOnly, FixedRatio = a.FixedRatio, IsEnabled = a.IsEnabled });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, AddOnEditViewModel model)
    {
        if (id != model.Id) return BadRequest();
        model.ExternalData = model.ExternalData?.Trim() ?? "";
        if (!ModelState.IsValid) return View(model);
        var a = await db.AddOns.FirstOrDefaultAsync(x => x.Id == id);
        if (a is null) return NotFound();
        a.Name = model.Name.Trim(); a.EnglishName = model.EnglishName?.Trim(); a.Price = model.Price;
        a.ExternalData = NormalizeAddOnCode(model.ExternalData); a.IcedOnly = model.IcedOnly; a.FixedRatio = model.FixedRatio; a.IsEnabled = model.IsEnabled;
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

    public static string NormalizeAddOnCode(string raw)
    {
        var v = raw.Trim();
        return v.StartsWith('@') ? v : "@" + v;
    }
}
