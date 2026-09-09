using DMMS.Web.Data;
using DMMS.Web.Models;
using DMMS.Web.Services;
using DMMS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DMMS.Web.Controllers;
public class MenuVersionsController(DmmsDbContext db, MenuExportService exporter) : Controller
{
    public async Task<IActionResult> Index() => View(await db.MenuVersions.Include(x => x.Products).ThenInclude(x => x.Product).OrderByDescending(x => x.CreatedAt).ToListAsync());
    [HttpGet] public async Task<IActionResult> Create() => View("Edit", await Form(null));
    [HttpPost, ValidateAntiForgeryToken] public async Task<IActionResult> Create(MenuVersionEditViewModel input) => await Save(input, null);
    [HttpGet] public async Task<IActionResult> Edit(int id) => View(await Form(await Load(id)));
    [HttpGet] public async Task<IActionResult> Build(int id) => View("Edit", await Form(await Load(id)));
    [HttpPost, ValidateAntiForgeryToken] public async Task<IActionResult> Build(MenuVersionEditViewModel input) => await Save(input, input.Id);
    [HttpGet] public async Task<IActionResult> Preview(int id)
    {
        var version = await Load(id); if (version is null) return NotFound();
        var result = exporter.Build(version.Products.Select(x => x.Product).ToArray(), version);
        return View(new MenuVersionPreviewViewModel { Version = version, Errors = result.Errors, Warnings = result.Warnings, RowCounts = result.RowCounts, SheetNames = result.SheetNames });
    }
    [HttpPost, ValidateAntiForgeryToken] public async Task<IActionResult> Export(int id)
    {
        var version = await Load(id); if (version is null) return NotFound();
        var result = exporter.Build(version.Products.Select(x => x.Product).ToArray(), version);
        if (result.File is null) return View("Preview", new MenuVersionPreviewViewModel { Version = version, Errors = result.Errors, Warnings = result.Warnings, RowCounts = result.RowCounts, SheetNames = result.SheetNames });
        version.Status = "Exported"; version.ExportedAt = DateTime.UtcNow; await db.SaveChangesAsync();
        return File(result.File, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", $"DMMS-UE-菜單-V1-{DateTime.Now:yyyyMMddHHmmss}.xlsx");
    }
    private async Task<MenuVersion?> Load(int id) => await db.MenuVersions.Include(x => x.Products).ThenInclude(x => x.Product).ThenInclude(x => x.ProductCategories).ThenInclude(x => x.Category).Include(x => x.Products).ThenInclude(x => x.Product).ThenInclude(x => x.Sizes).Include(x => x.Products).ThenInclude(x => x.Product).ThenInclude(x => x.SpecialOptions).ThenInclude(x => x.SpecialOption).ThenInclude(x => x.Group).Include(x => x.Products).ThenInclude(x => x.Product).ThenInclude(x => x.AddOns).ThenInclude(x => x.AddOn).ThenInclude(x => x.Sizes).SingleOrDefaultAsync(x => x.Id == id);
    private async Task<MenuVersionEditViewModel> Form(MenuVersion? v) => new() { Id = v?.Id ?? 0, Name = v?.Name ?? "UE 菜單 V1", Platform = v?.Platform ?? "UberEats", StoreUuid = v?.StoreUuid, MenuExternalId = v?.MenuExternalId ?? "全日菜單_Menu", MenuDisplayName = v?.MenuDisplayName ?? "全日菜單 Menu", OpenHours = v?.OpenHours ?? "10:30--20:00", SelectedProductIds = v?.Products.Select(x => x.ProductId).ToList() ?? [], Products = await db.Products.Where(x => x.IsEnabled).OrderBy(x => x.SortOrder).ThenBy(x => x.Name).ToListAsync() };
    private async Task<IActionResult> Save(MenuVersionEditViewModel input, int? id)
    {
        if (!ModelState.IsValid) { input.Products = await db.Products.Where(x => x.IsEnabled).OrderBy(x => x.Name).ToListAsync(); return View("Edit", input); }
        var v = id.HasValue ? await db.MenuVersions.Include(x => x.Products).SingleOrDefaultAsync(x => x.Id == id) : new MenuVersion(); if (v is null) return NotFound();
        v.Name = input.Name; v.Platform = input.Platform; v.StoreUuid = input.StoreUuid; v.MenuExternalId = input.MenuExternalId; v.MenuDisplayName = input.MenuDisplayName; v.OpenHours = input.OpenHours; if (!id.HasValue) db.MenuVersions.Add(v); else v.Products.Clear();
        await db.SaveChangesAsync(); foreach (var productId in input.SelectedProductIds.Distinct()) v.Products.Add(new MenuVersionProduct { MenuVersionId = v.Id, ProductId = productId }); await db.SaveChangesAsync(); return RedirectToAction(nameof(Preview), new { id = v.Id });
    }
}
