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
            var products = await db.Products
                .Include(p => p.ProductCategories).ThenInclude(pc => pc.Category)
                .Include(p => p.Sizes)
                .Include(p => p.SpecialOptions)
                .Include(p => p.AddOns)
                .AsNoTracking().OrderBy(p => p.SortOrder).ThenBy(p => p.Id).ToListAsync();
            return View(new ProductListViewModel
            {
                Products = products.Select(p => new ProductListItemViewModel
                {
                    Id = p.Id, Name = p.Name, EnglishName = p.EnglishName, BasePrice = p.BasePrice, IsEnabled = p.IsEnabled,
                    Categories = string.Join("、", p.ProductCategories.Select(x => x.Category.Name)) is var c && !string.IsNullOrWhiteSpace(c) ? c : "未分類",
                    SizeCount = p.Sizes.Count,
                    MissingCode = p.Sizes.Count == 0 || p.Sizes.Any(s => s.IsEnabled && string.IsNullOrWhiteSpace(s.ColdBaseCode) && string.IsNullOrWhiteSpace(s.HotBaseCode)),
                    SpecialOptionCount = p.SpecialOptions.Count(x => x.IsEnabled),
                    AddOnCount = p.AddOns.Count(x => x.IsEnabled)
                }).ToList()
            });
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
        var p = await db.Products
            .Include(x => x.Sizes)
            .Include(x => x.ProductCategories)
            .Include(x => x.SpecialOptions)
            .Include(x => x.AddOns)
            .FirstOrDefaultAsync(x => x.Id == id);
        if (p is null) return NotFound();
        return View(await BuildEditModelAsync(ToModel(p)));
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, ProductEditViewModel model)
    {
        if (id != model.Id) return BadRequest();
        if (!ModelState.IsValid) return View(await BuildEditModelAsync(model));
        var product = await db.Products
            .Include(x => x.Sizes).Include(x => x.ProductCategories)
            .Include(x => x.SpecialOptions).Include(x => x.AddOns)
            .FirstOrDefaultAsync(x => x.Id == id);
        if (product is null) return NotFound();
        Apply(model, product);
        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException) { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線與資料格式。"); return View(await BuildEditModelAsync(model)); }
    }

    // ---------- model builders ----------

    private async Task<ProductEditViewModel> BuildEditModelAsync(ProductEditViewModel model)
    {
        model.Categories = await db.Categories.AsNoTracking().OrderBy(x => x.Name).ToListAsync();
        model.GroupChoices = await LoadGroupChoicesAsync();
        var addOns = await db.AddOns.AsNoTracking().Include(a => a.Sizes).Where(a => a.IsEnabled).OrderBy(a => a.Name).ToListAsync();
        model.AvailableAddOns = addOns.Select(a => new AddOnChoiceItem
        {
            Id = a.Id, Name = a.Name, EnglishName = a.EnglishName,
            DefaultCode = a.ExternalData, DefaultPrice = a.Price,
            IcedOnly = a.IcedOnly, FixedRatio = a.FixedRatio,
            SizeSummary = string.Join("｜", a.Sizes.Where(s => s.IsEnabled).OrderBy(s => s.SortOrder).Select(s => $"{s.SizeName} {s.ExternalData} NT${s.Price:N0}"))
        }).ToList();

        if (model.Id > 0 && model.AddOnIds.Count == 0)
        {
            var saved = await db.ProductAddOns.AsNoTracking().Where(x => x.ProductId == model.Id && x.IsEnabled).Select(x => x.AddOnId).ToListAsync();
            model.AddOnIds = saved;
        }
        return model;
    }

    private async Task<List<SpecialOptionGroupChoice>> LoadGroupChoicesAsync()
    {
        var groups = await db.SpecialOptionGroups.Include(g => g.Options).AsNoTracking().OrderBy(g => g.Name).ToListAsync();
        return groups.Select(g => new SpecialOptionGroupChoice
        {
            GroupId = g.Id, GroupName = g.Name, Min = g.Min, Max = g.Max,
            Options = g.Options.Where(o => o.IsEnabled).OrderBy(o => o.Name).Select(o => new SpecialOptionChoice
            {
                Id = o.Id, Name = o.Name, EnglishName = o.EnglishName,
                KindLabel = o.Kind switch
                {
                    SpecialOptionKind.Temperature => o.BeverageTemperature == BeverageTemperature.Hot ? "熱" : "冰",
                    SpecialOptionKind.Sweetness => "甜度",
                    _ => "其他"
                }
            }).ToList()
        }).ToList();
    }

    private static ProductEditViewModel ToModel(Product p)
    {
        var m = new ProductEditViewModel
        {
            Id = p.Id, Name = p.Name, EnglishName = p.EnglishName, Description = p.Description, ImageUrl = p.ImageUrl,
            BasePrice = p.BasePrice, IsEnabled = p.IsEnabled, SortOrder = p.SortOrder,
            CategoryId = p.ProductCategories.Select(x => (int?)x.CategoryId).FirstOrDefault(),
            Sizes = p.Sizes.OrderBy(x => x.SortOrder).Select(s => new ProductSizeInputModel { Id = s.Id, Name = s.Name, PriceAdjustment = s.PriceAdjustment, ColdBaseCode = s.ColdBaseCode, HotBaseCode = s.HotBaseCode, IsEnabled = s.IsEnabled, SortOrder = s.SortOrder }).ToList(),
            SpecialOptionIds = p.SpecialOptions.Where(x => x.IsEnabled).Select(x => x.SpecialOptionId).ToList(),
            AddOnIds = p.AddOns.Where(x => x.IsEnabled).Select(x => x.AddOnId).ToList()
        };
        return m;
    }

    // ---------- apply ----------

    private void Apply(ProductEditViewModel m, Product p)
    {
        p.Name = m.Name; p.EnglishName = m.EnglishName; p.Description = m.Description; p.ImageUrl = m.ImageUrl;
        p.BasePrice = m.BasePrice; p.IsEnabled = m.IsEnabled; p.SortOrder = m.SortOrder;

        // 分類：清空重建
        p.ProductCategories.Clear();
        if (m.CategoryId.HasValue) p.ProductCategories.Add(new ProductCategory { Product = p, CategoryId = m.CategoryId.Value });

        // 編輯既有商品 → 先明確刪除舊關聯與舊尺寸
        if (p.Id != 0)
        {
            db.ProductAddOns.RemoveRange(p.AddOns);
            db.ProductSpecialOptions.RemoveRange(p.SpecialOptions);
            foreach (var s in p.Sizes.ToList()) db.ProductSizes.Remove(s);
            p.AddOns.Clear(); p.SpecialOptions.Clear(); p.Sizes.Clear();
        }

        // 尺寸重建（含新尺寸）
        foreach (var s in m.Sizes.Where(s => !string.IsNullOrWhiteSpace(s.Name)))
        {
            p.Sizes.Add(new ProductSize
            {
                Name = s.Name, PriceAdjustment = s.PriceAdjustment, ColdBaseCode = s.ColdBaseCode,
                HotBaseCode = s.HotBaseCode, IsEnabled = s.IsEnabled, SortOrder = s.SortOrder
            });
        }

        // 特口：商品層級勾選
        foreach (var oid in m.SpecialOptionIds.Distinct())
            p.SpecialOptions.Add(new ProductSpecialOption { Product = p, SpecialOptionId = oid, IsEnabled = true });

        // 加料：商品層級勾選（品號/價格由加料主檔依尺寸定義，商品不需填）
        foreach (var aid in m.AddOnIds.Distinct())
            p.AddOns.Add(new ProductAddOn { Product = p, AddOnId = aid, IsEnabled = true });
    }
}
