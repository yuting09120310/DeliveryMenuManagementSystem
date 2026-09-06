using DMMS.Web.Data;
using DMMS.Web.Models;
using DMMS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DMMS.Web.Controllers;

public class ProductsController(DmmsDbContext db) : Controller
{
    public async Task<IActionResult> Index()
    {
        try
        {
            var products = await db.Products.Include(p => p.ProductCategories).ThenInclude(pc => pc.Category).Include(p => p.Sizes).AsNoTracking().OrderBy(p => p.SortOrder).ThenBy(p => p.Id).ToListAsync();
            return View(new ProductListViewModel { Products = products.Select(p => new ProductListItemViewModel { Id = p.Id, Name = p.Name, EnglishName = p.EnglishName, BasePrice = p.BasePrice, IsEnabled = p.IsEnabled, Categories = string.Join("、", p.ProductCategories.Select(x => x.Category.Name)) is var c && !string.IsNullOrWhiteSpace(c) ? c : "未分類", SizeCount = p.Sizes.Count, MissingCode = p.Sizes.Count == 0 || p.Sizes.Any(s => s.IsEnabled && string.IsNullOrWhiteSpace(s.ColdBaseCode) && string.IsNullOrWhiteSpace(s.HotBaseCode)) }).ToList() });
        }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { return View(new ProductListViewModel { DataError = "目前無法連線到資料庫，商品列表暫時無法載入。請確認 DefaultConnection 設定。" }); }
    }

    [HttpGet]
    public async Task<IActionResult> Create() => View(await BuildEditModelAsync(new ProductEditViewModel { Sizes = [new() { Name = "中杯" }, new() { Name = "大杯", SortOrder = 1 }] }));

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(ProductEditViewModel model)
    {
        if (!ModelState.IsValid) return View(await BuildEditModelAsync(model));
        var product = new Product();
        Apply(model, product);
        db.Products.Add(product);
        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException) { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線與資料格式。"); return View(await BuildEditModelAsync(model)); }
    }

    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var p = await db.Products.Include(x => x.Sizes).Include(x => x.ProductCategories).FirstOrDefaultAsync(x => x.Id == id);
        if (p is null) return NotFound();
        return View(await BuildEditModelAsync(ToModel(p)));
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, ProductEditViewModel model)
    {
        if (id != model.Id) return BadRequest();
        if (!ModelState.IsValid) return View(await BuildEditModelAsync(model));
        var product = await db.Products.Include(x => x.Sizes).Include(x => x.ProductCategories).FirstOrDefaultAsync(x => x.Id == id);
        if (product is null) return NotFound();
        Apply(model, product);
        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException) { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線與資料格式。"); return View(await BuildEditModelAsync(model)); }
    }

    private async Task<ProductEditViewModel> BuildEditModelAsync(ProductEditViewModel model) { model.Categories = await db.Categories.AsNoTracking().OrderBy(x => x.Name).ToListAsync(); return model; }
    private static ProductEditViewModel ToModel(Product p) => new() { Id = p.Id, Name = p.Name, EnglishName = p.EnglishName, Description = p.Description, ImageUrl = p.ImageUrl, BasePrice = p.BasePrice, IsEnabled = p.IsEnabled, SortOrder = p.SortOrder, SourceExternalId = p.SourceExternalId, SourceUuid = p.SourceUuid, CategoryId = p.ProductCategories.Select(x => (int?)x.CategoryId).FirstOrDefault(), Sizes = p.Sizes.OrderBy(x => x.SortOrder).Select(s => new ProductSizeInputModel { Id = s.Id, Name = s.Name, PriceAdjustment = s.PriceAdjustment, ColdBaseCode = s.ColdBaseCode, HotBaseCode = s.HotBaseCode, IsEnabled = s.IsEnabled, SortOrder = s.SortOrder }).ToList() };
    private void Apply(ProductEditViewModel m, Product p)
    {
        p.Name = m.Name; p.EnglishName = m.EnglishName; p.Description = m.Description; p.ImageUrl = m.ImageUrl; p.BasePrice = m.BasePrice; p.IsEnabled = m.IsEnabled; p.SortOrder = m.SortOrder; p.SourceExternalId = m.SourceExternalId; p.SourceUuid = m.SourceUuid;
        p.ProductCategories.Clear(); if (m.CategoryId.HasValue) p.ProductCategories.Add(new ProductCategory { Product = p, CategoryId = m.CategoryId.Value });
        foreach (var existing in p.Sizes.ToList()) db.Entry(existing).State = EntityState.Deleted;
        p.Sizes.Clear(); foreach (var s in m.Sizes.Where(s => !string.IsNullOrWhiteSpace(s.Name))) p.Sizes.Add(new ProductSize { Name = s.Name, PriceAdjustment = s.PriceAdjustment, ColdBaseCode = s.ColdBaseCode, HotBaseCode = s.HotBaseCode, IsEnabled = s.IsEnabled, SortOrder = s.SortOrder });
    }
}
