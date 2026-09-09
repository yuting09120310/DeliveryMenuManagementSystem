using DMMS.Web.Services;
using Microsoft.AspNetCore.Mvc;

namespace DMMS.Web.Controllers;

/// <summary>開發用匯入端點：從原版 UE 校稿檔匯入計畫建立分類與商品主檔（一次性資料建置工具）。</summary>
public class ImportController : Controller
{
    private readonly MenuImportService _import;
    private readonly IWebHostEnvironment _env;
    public ImportController(MenuImportService import, IWebHostEnvironment env)
    {
        _import = import;
        _env = env;
    }

    [HttpGet]
    public async Task<IActionResult> Original()
    {
        if (!_env.IsDevelopment())
            return Content("僅限開發環境執行。", "text/plain; charset=utf-8");

        var planPath = Path.Combine(_env.ContentRootPath, "Templates", "ue-import-plan.json");
        if (!System.IO.File.Exists(planPath))
            return Content($"找不到匯入計畫：{planPath}", "text/plain; charset=utf-8");

        var result = await _import.ImportAsync(planPath);
        return View(result);
    }
}
