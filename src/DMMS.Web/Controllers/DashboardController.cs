using DMMS.Web.Data;
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
            model = new DashboardViewModel
            {
                ProductCount = products.Count,
                EnabledProductCount = products.Count(p => p.IsEnabled),
                CategoryCount = await db.Categories.CountAsync(),
                SpecialOptionGroupCount = await db.SpecialOptionGroups.CountAsync(),
                AddOnCount = await db.AddOns.CountAsync(),
                MissingCodeProductCount = products.Count(p => p.Sizes.Count == 0 || p.Sizes.Any(s => s.IsEnabled && string.IsNullOrWhiteSpace(s.ColdBaseCode) && string.IsNullOrWhiteSpace(s.HotBaseCode)))
            };
        }
        catch (Exception ex) when (ex is DbUpdateException or InvalidOperationException or System.Data.Common.DbException)
        {
            model = new DashboardViewModel { DataError = "目前無法連線到資料庫，統計資料暫時無法載入。請確認 DefaultConnection 設定。" };
        }
        return View(model);
    }
}
