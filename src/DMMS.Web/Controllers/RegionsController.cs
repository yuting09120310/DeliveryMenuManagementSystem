using DMMS.Web.Data;
using DMMS.Web.Models;
using DMMS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DMMS.Web.Controllers;

/// <summary>價格區管理（北區／南區／未來中區…）。純價格維度，與 UE 店家/UUID 無關。
/// 規則：可新增／改名／排序／停用；不提供刪除（地區被地區價與菜單版本引用）。
/// 新增地區時自動為所有商品建立地區價並預填 BasePrice。</summary>
public class RegionsController(DmmsDbContext db) : Controller
{
    public async Task<IActionResult> Index()
    {
        var rows = await db.Regions.AsNoTracking()
            .OrderBy(r => r.SortOrder).ThenBy(r => r.Id)
            .Select(r => new RegionListItemViewModel
            {
                Id = r.Id, Name = r.Name, SortOrder = r.SortOrder, IsEnabled = r.IsEnabled,
                PriceCount = r.ProductPrices.Count,
                MenuVersionCount = db.MenuVersions.Count(v => v.RegionId == r.Id)
            }).ToListAsync();
        return View(rows);
    }

    [HttpGet]
    public IActionResult Create() => View("Edit", new RegionEditViewModel { IsEnabled = true });

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(RegionEditViewModel model)
    {
        if (!ModelState.IsValid) return View("Edit", model);
        if (await db.Regions.AnyAsync(r => r.Name == model.Name))
        {
            ModelState.AddModelError(nameof(model.Name), "已有同名地區。");
            return View("Edit", model);
        }
        var region = new Region { Name = model.Name, SortOrder = model.SortOrder, IsEnabled = model.IsEnabled };
        db.Regions.Add(region);
        await db.SaveChangesAsync();
        // 為所有商品建立此區地區價，預填 BasePrice（未手動調整 → PriceModifiedAt=null）
        var products = await db.Products.AsNoTracking().Select(p => new { p.Id, p.BasePrice }).ToListAsync();
        foreach (var p in products)
            db.ProductRegionPrices.Add(new ProductRegionPrice { ProductId = p.Id, RegionId = region.Id, Price = p.BasePrice });
        await db.SaveChangesAsync();
        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var r = await db.Regions.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (r is null) return NotFound();
        return View(new RegionEditViewModel
        {
            Id = r.Id, Name = r.Name, SortOrder = r.SortOrder, IsEnabled = r.IsEnabled,
            PriceCount = await db.ProductRegionPrices.CountAsync(x => x.RegionId == id),
            MenuVersionCount = await db.MenuVersions.CountAsync(x => x.RegionId == id)
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, RegionEditViewModel model)
    {
        if (id != model.Id) return BadRequest();
        if (!ModelState.IsValid) return View("Edit", model);
        if (await db.Regions.AnyAsync(r => r.Name == model.Name && r.Id != id))
        {
            ModelState.AddModelError(nameof(model.Name), "已有同名地區。");
            return View("Edit", model);
        }
        var r = await db.Regions.FirstOrDefaultAsync(x => x.Id == id);
        if (r is null) return NotFound();
        r.Name = model.Name; r.SortOrder = model.SortOrder; r.IsEnabled = model.IsEnabled;
        await db.SaveChangesAsync();
        return RedirectToAction(nameof(Index));
    }

    /// <summary>停用/啟用（不刪除）。停用後不出現在建菜單的地區下拉。</summary>
    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Toggle(int id)
    {
        var r = await db.Regions.FirstOrDefaultAsync(x => x.Id == id);
        if (r is null) return NotFound();
        r.IsEnabled = !r.IsEnabled;
        await db.SaveChangesAsync();
        return RedirectToAction(nameof(Index));
    }
}
