using DMMS.Web.Data;
using DMMS.Web.Models;
using DMMS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DMMS.Web.Controllers;

public class CategoriesController(DmmsDbContext db) : Controller
{
    public async Task<IActionResult> Index()
    {
        try
        {
            var cats = await db.Categories.AsNoTracking().OrderBy(c => c.SortOrder).ThenBy(c => c.Name).ToListAsync();
            var counts = await db.ProductCategories.AsNoTracking().GroupBy(x => x.CategoryId).Select(g => new { g.Key, N = g.Count() }).ToDictionaryAsync(x => x.Key, x => x.N);
            return View(new CategoryListViewModel
            {
                Categories = cats.Select(c => new CategoryListItemViewModel
                {
                    Id = c.Id, Name = c.Name, EnglishName = c.EnglishName, SortOrder = c.SortOrder,
                    ProductCount = counts.GetValueOrDefault(c.Id)
                }).ToList()
            });
        }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { return View(new CategoryListViewModel { DataError = "目前無法連線到資料庫，分類資料暫時無法載入。" }); }
    }

    [HttpGet]
    public IActionResult Create() => View(new CategoryEditViewModel());

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(CategoryEditViewModel model)
    {
        if (!ModelState.IsValid) return View(model);
        db.Categories.Add(ToEntity(model));
        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線。"); return View(model); }
    }

    [HttpGet]
    public async Task<IActionResult> Edit(int id)
    {
        var c = await db.Categories.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (c is null) return NotFound();
        return View(new CategoryEditViewModel { Id = c.Id, Name = c.Name, EnglishName = c.EnglishName, SortOrder = c.SortOrder });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(int id, CategoryEditViewModel model)
    {
        if (id != model.Id) return BadRequest();
        if (!ModelState.IsValid) return View(model);
        var c = await db.Categories.FirstOrDefaultAsync(x => x.Id == id);
        if (c is null) return NotFound();
        Apply(model, c);
        try { await db.SaveChangesAsync(); return RedirectToAction(nameof(Index)); }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        { ModelState.AddModelError("", "儲存失敗，請確認資料庫連線。"); return View(model); }
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(int id)
    {
        var c = await db.Categories.FirstOrDefaultAsync(x => x.Id == id);
        if (c is null) return NotFound();
        if (await db.ProductCategories.AsNoTracking().AnyAsync(x => x.CategoryId == id))
        {
            TempData["Error"] = "此分類已有商品，無法刪除。請先將商品移到其他分類。";
            return RedirectToAction(nameof(Index));
        }
        db.Categories.Remove(c);
        try { await db.SaveChangesAsync(); }
        catch { TempData["Error"] = "刪除失敗。"; }
        return RedirectToAction(nameof(Index));
    }

    private static Category ToEntity(CategoryEditViewModel m) { var c = new Category(); Apply(m, c); return c; }
    private static void Apply(CategoryEditViewModel m, Category c)
    {
        c.Name = m.Name.Trim();
        c.EnglishName = string.IsNullOrWhiteSpace(m.EnglishName) ? null : m.EnglishName.Trim();
        c.SortOrder = m.SortOrder;
    }
}
