using DMMS.Web.Data;
using DMMS.Web.Models;
using DMMS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DMMS.Web.Controllers;

public class SpecialOptionGroupsController(DmmsDbContext db) : Controller
{
    public async Task<IActionResult> Index()
    {
        try
        {
            var groups = await db.SpecialOptionGroups
                .Include(g => g.Options)
                .AsNoTracking()
                .OrderBy(g => g.Name)
                .ToListAsync();
            var linked = (await db.ProductSpecialOptions.AsNoTracking().Select(x => x.SpecialOptionId).Distinct().ToListAsync()).ToHashSet();
            return View(new SpecialOptionGroupListViewModel
            {
                Groups = groups.Select(g => new SpecialOptionGroupListItemViewModel
                {
                    Id = g.Id,
                    Name = g.Name,
                    Min = g.Min,
                    Max = g.Max,
                    OptionCount = g.Options.Count,
                    EnabledOptionCount = g.Options.Count(o => o.IsEnabled),
                    HasProductLinks = g.Options.Any(o => linked.Contains(o.Id))
                }).ToList()
            });
        }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        {
            return View(new SpecialOptionGroupListViewModel { DataError = "目前無法連線到資料庫，特口群組暫時無法載入。請確認 DefaultConnection 設定。" });
        }
    }

    [HttpGet]
    public async Task<IActionResult> Create() => View(new SpecialOptionGroupEditViewModel { GroupKind = SpecialOptionKind.Temperature, Options = [new()] });

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(SpecialOptionGroupEditViewModel model)
    {
        ApplyGroupKind(model);
        var clean = CleanOptions(model);
        if (!ModelState.IsValid || clean.Count == 0)
        {
            if (clean.Count == 0) ModelState.AddModelError(nameof(model.Options), "請至少加入一個群組選項。");
            model.Options = clean;
            return View(model);
        }
        var group = new SpecialOptionGroup { Name = model.Name.Trim(), Min = model.Min, Max = model.Max };
        foreach (var o in clean) group.Options.Add(ToOption(o));
        db.SpecialOptionGroups.Add(group);
        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線與資料格式。"); return View(model); }
    }

    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var g = await db.SpecialOptionGroups.Include(x => x.Options).ThenInclude(o => o.Sizes).AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (g is null) return NotFound();
        var inUse = await db.ProductSpecialOptions.AsNoTracking().AnyAsync(x => g.Options.Select(o => o.Id).Contains(x.SpecialOptionId));
        var opts = g.Options.OrderBy(o => o.Id).Select(o => new SpecialOptionInputModel
        {
            Id = o.Id, Name = o.Name, EnglishName = o.EnglishName, Kind = o.Kind, ExternalDataMode = o.ExternalDataMode,
            BeverageTemperature = o.BeverageTemperature, Suffix = o.Suffix, StandaloneExternalData = o.StandaloneExternalData, IsEnabled = o.IsEnabled,
            Sizes = o.Sizes.OrderBy(s => s.SortOrder).Select(s => new SpecialOptionSizeInputModel
            {
                Id = s.Id, SizeName = s.SizeName, ExternalData = s.ExternalData, Price = s.Price, IsEnabled = s.IsEnabled, SortOrder = s.SortOrder
            }).ToList()
        }).ToList();
        return View(new SpecialOptionGroupEditViewModel
        {
            Id = g.Id, Name = g.Name, Min = g.Min, Max = g.Max,
            GroupKind = opts.FirstOrDefault()?.Kind ?? SpecialOptionKind.Temperature,
            InUseByProducts = inUse,
            Options = opts
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, SpecialOptionGroupEditViewModel model)
    {
        if (id != model.Id) return BadRequest();
        ApplyGroupKind(model);
        var clean = CleanOptions(model);
        if (!ModelState.IsValid || clean.Count == 0)
        {
            if (clean.Count == 0) ModelState.AddModelError(nameof(model.Options), "請至少加入一個群組選項。");
            model.Options = clean;
            return View(model);
        }
        var group = await db.SpecialOptionGroups.Include(x => x.Options).ThenInclude(o => o.Sizes).FirstOrDefaultAsync(x => x.Id == id);
        if (group is null) return NotFound();

        group.Name = model.Name.Trim(); group.Min = model.Min; group.Max = model.Max;
        var existing = group.Options.ToDictionary(o => o.Id);
        foreach (var incoming in clean)
        {
            if (incoming.Id > 0 && existing.TryGetValue(incoming.Id, out var target))
            {
                target.Name = incoming.Name; target.EnglishName = incoming.EnglishName; target.Kind = incoming.Kind;
                target.ExternalDataMode = incoming.ExternalDataMode; target.BeverageTemperature = incoming.BeverageTemperature;
                target.Suffix = incoming.Suffix; target.StandaloneExternalData = incoming.StandaloneExternalData; target.IsEnabled = incoming.IsEnabled;
                ApplySizes(target, incoming);
                existing.Remove(incoming.Id);
            }
            else group.Options.Add(ToOption(incoming));
        }
        foreach (var orphan in existing.Values) db.SpecialOptions.Remove(orphan);

        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線與資料格式。"); return View(model); }
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id)
    {
        var g = await db.SpecialOptionGroups.Include(x => x.Options).FirstOrDefaultAsync(x => x.Id == id);
        if (g is null) return NotFound();
        if (await db.ProductSpecialOptions.AsNoTracking().AnyAsync(x => g.Options.Select(o => o.Id).Contains(x.SpecialOptionId)))
        {
            TempData["Error"] = "此群組已被商品使用，無法刪除。請先解除商品關聯。";
            return RedirectToAction(nameof(Index));
        }
        db.SpecialOptionGroups.Remove(g);
        try { await db.SaveChangesAsync(); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { TempData["Error"] = "刪除失敗，請確認資料庫連線。"; }
        return RedirectToAction(nameof(Index));
    }

    /// <summary>將表單頂端的「選項類型」套用到全部選項：甜度 → Standalone；冰度/溫度 → BaseCode+Suffix。</summary>
    private static void ApplyGroupKind(SpecialOptionGroupEditViewModel m)
    {
        foreach (var o in m.Options)
        {
            o.Kind = m.GroupKind;
            o.ExternalDataMode = m.GroupKind == SpecialOptionKind.Sweetness ? ExternalDataMode.Standalone : ExternalDataMode.BaseCodeAndSuffix;
            if (m.GroupKind == SpecialOptionKind.Sweetness) o.BeverageTemperature = null;
        }
    }

    private static List<SpecialOptionInputModel> CleanOptions(SpecialOptionGroupEditViewModel m)
    {
        var cleaned = m.Options.Where(o => !string.IsNullOrWhiteSpace(o.Name)).ToList();
        foreach (var o in cleaned)
        {
            o.Name = o.Name.Trim();
            o.Suffix = string.IsNullOrWhiteSpace(o.Suffix) ? null : o.Suffix.Trim();
            o.StandaloneExternalData = string.IsNullOrWhiteSpace(o.StandaloneExternalData) ? null : o.StandaloneExternalData.Trim();
            o.EnglishName = string.IsNullOrWhiteSpace(o.EnglishName) ? null : o.EnglishName.Trim();
        }
        return cleaned;
    }

    private static void ApplySizes(SpecialOption target, SpecialOptionInputModel incoming)
    {
        var keep = new List<SpecialOptionSize>();
        foreach (var row in incoming.Sizes.Where(s => !string.IsNullOrWhiteSpace(s.SizeName) && !string.IsNullOrWhiteSpace(s.ExternalData)))
        {
            var size = target.Sizes.FirstOrDefault(s => s.Id == row.Id);
            if (size is null)
            {
                size = new SpecialOptionSize();
                target.Sizes.Add(size);
            }
            size.SizeName = row.SizeName.Trim();
            size.ExternalData = row.ExternalData.Trim().StartsWith('@') ? row.ExternalData.Trim() : "@" + row.ExternalData.Trim();
            size.Price = row.Price;
            size.IsEnabled = row.IsEnabled;
            size.SortOrder = row.SortOrder;
            keep.Add(size);
        }
        foreach (var orphan in target.Sizes.Where(s => !keep.Contains(s)).ToList())
            target.Sizes.Remove(orphan);
    }

    private static SpecialOption ToOption(SpecialOptionInputModel o)
    {
        var opt = new SpecialOption
        {
            Name = o.Name, EnglishName = o.EnglishName, Kind = o.Kind, ExternalDataMode = o.ExternalDataMode,
            BeverageTemperature = o.BeverageTemperature, Suffix = o.Suffix, StandaloneExternalData = o.StandaloneExternalData, IsEnabled = o.IsEnabled
        };
        foreach (var row in o.Sizes.Where(s => !string.IsNullOrWhiteSpace(s.SizeName) && !string.IsNullOrWhiteSpace(s.ExternalData)))
        {
            opt.Sizes.Add(new SpecialOptionSize
            {
                SizeName = row.SizeName.Trim(),
                ExternalData = row.ExternalData.Trim().StartsWith('@') ? row.ExternalData.Trim() : "@" + row.ExternalData.Trim(),
                Price = row.Price, IsEnabled = row.IsEnabled, SortOrder = row.SortOrder
            });
        }
        return opt;
    }
}
