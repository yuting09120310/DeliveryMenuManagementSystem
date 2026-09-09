using DMMS.Web.Data;
using DMMS.Web.Models;
using DMMS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DMMS.Web.Controllers;

public class DashboardController(DmmsDbContext db) : Controller
{
    public async Task<IActionResult> Index()
    {
        var model = new DashboardViewModel();
        try
        {
            var products = await db.Products.Include(p => p.Sizes).AsNoTracking().ToListAsync();
            var missing = products.Where(p => p.Sizes.Count == 0 || p.Sizes.Any(s => s.IsEnabled && string.IsNullOrWhiteSpace(s.ColdBaseCode) && string.IsNullOrWhiteSpace(s.HotBaseCode))).ToList();
            model = new DashboardViewModel
            {
                ProductCount = products.Count,
                EnabledProductCount = products.Count(p => p.IsEnabled),
                CategoryCount = await db.Categories.CountAsync(),
                AddOnCount = await db.AddOns.CountAsync(),
                SpecialOptionCount = await db.SpecialOptions.CountAsync(o => o.IsEnabled),
                IceOptionCount = await db.SpecialOptions.CountAsync(o => o.IsEnabled && o.Kind == SpecialOptionKind.Temperature),
                SweetOptionCount = await db.SpecialOptions.CountAsync(o => o.IsEnabled && o.Kind == SpecialOptionKind.Sweetness),
                MissingCodeProductCount = missing.Count,
                MissingCodeProductNames = missing.Select(p => p.Name).ToList(),
                RecentVersions = await db.MenuVersions.Include(v => v.Products).AsNoTracking().OrderByDescending(v => v.CreatedAt).Take(5).ToListAsync()
            };
        }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        {
            model = new DashboardViewModel { DataError = "目前無法連線到資料庫，統計資料暫時無法載入。請確認 DefaultConnection 設定。" };
        }
        return View(model);
    }
}
