using DMMS.Web.Data;
using DMMS.Web.Models;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace DMMS.Web.Services;

/// <summary>
/// 從原版 UE 校稿檔匯入計畫 JSON（Templates/ue-import-plan.json）建立/同步分類與商品主檔。
/// 反向於 MenuExportService：把 UE 展開結構收斂回 DMMS 主檔關聯（尺寸/冷熱品號/特口勾選/加料勾選）。
/// 可重複執行：以 (中文名+英文名+價格) 定位商品，存在則同步欄位與關聯（旗標/尺寸/特口/加料/分類），
/// 不存在則新建——因此產線 JSON 更新後重新執行即可對齊，不會重複建檔。
/// </summary>
public class MenuImportService
{
    private readonly DmmsDbContext _db;
    public MenuImportService(DmmsDbContext db) => _db = db;

    public sealed class PlanCategory { public string Zh { get; set; } = ""; public string En { get; set; } = ""; }
    public sealed class PlanSize { public string Name { get; set; } = ""; public decimal Adj { get; set; } public string Cold { get; set; } = ""; public string Hot { get; set; } = ""; public int Sort { get; set; } }
    public sealed class PlanSweetExtra { public string Zh { get; set; } = ""; public string Ed { get; set; } = ""; public decimal Price { get; set; } }
    public sealed class PlanItem
    {
        public string Zh { get; set; } = ""; public string En { get; set; } = "";
        public decimal Price { get; set; }
        public string Desc { get; set; } = ""; public string Img { get; set; } = "";
        public List<string> Cats { get; set; } = new();
        public bool HasSize { get; set; }
        public List<PlanSize> Sizes { get; set; } = new();
        public List<string> TempSem { get; set; } = new();   // 標準冰/少冰/去冰/溫/熱
        public List<string> SweetSem { get; set; } = new();  // 標準甜/7 分甜/5 分甜/3 分甜/無糖
        public string? HoneySize { get; set; }               // 大杯/中杯（有醇香蜂蜜時）
        public List<string> AddonEds { get; set; } = new();  // @IT1810(19) 等
        public List<PlanSweetExtra> SweetExtra { get; set; } = new(); // 甜度群組內的特殊選項（減冬瓜 (39) 等）
        /// <summary>true＝甜度群組在商品層輸出一次(Nesting=1，與尺寸無關)；false＝每個尺寸段內各一次(Nesting=2)。</summary>
        public bool SweetAtProductLevel { get; set; }
    }
    public sealed class ImportResult
    {
        public int CategoriesCreated { get; set; }
        public int ProductsCreated { get; set; }
        public int ProductsUpdated { get; set; }
        public List<string> Messages { get; set; } = new();
    }

    private static readonly string[] TempOrder = { "標準冰", "少冰", "去冰", "溫", "熱" };
    private static readonly string[] SweetOrder = { "標準甜", "7 分甜", "5 分甜", "3 分甜", "無糖" };

    public async Task<ImportResult> ImportAsync(string planJsonPath, CancellationToken ct = default)
    {
        var result = new ImportResult();
        var json = await File.ReadAllTextAsync(planJsonPath, ct);
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;
        var cats = root.GetProperty("cats").EnumerateArray()
            .Select(c => new PlanCategory { Zh = c.GetProperty("zh").GetString() ?? "", En = c.GetProperty("en").GetString() ?? "" }).ToList();
        var items = root.GetProperty("items").EnumerateArray().Select(ParseItem).ToList();

        // ---------- 分類（by Name upsert） ----------
        var catSort = 0;
        foreach (var pc in cats)
        {
            var cat = await _db.Categories.FirstOrDefaultAsync(c => c.Name == pc.Zh, ct);
            if (cat is null)
            {
                cat = new Category { Name = pc.Zh, EnglishName = pc.En, SortOrder = catSort };
                _db.Categories.Add(cat);
                result.CategoriesCreated++;
            }
            else if (string.IsNullOrEmpty(cat.EnglishName)) cat.EnglishName = pc.En;
            catSort++;
        }
        await _db.SaveChangesAsync(ct);

        // ---------- 主檔快取 ----------
        var tempOptions = await _db.SpecialOptions.Where(o => o.Kind == SpecialOptionKind.Temperature).ToListAsync(ct);
        var sweetOptions = await _db.SpecialOptions.Include(o => o.Sizes).Where(o => o.Kind == SpecialOptionKind.Sweetness).ToListAsync(ct);
        var sweetGroups = await _db.SpecialOptionGroups.Where(g => g.Options.Any(o => o.Kind == SpecialOptionKind.Sweetness)).ToListAsync(ct);
        var addons = await _db.AddOns.ToListAsync(ct);
        var categories = await _db.Categories.ToListAsync(ct);

        // ---------- 甜度群組內特殊選項（減冬瓜 (39) 等）by (Name + StandaloneExternalData) upsert ----------
        var sweetGroup = sweetGroups.FirstOrDefault();
        foreach (var pi in items)
        {
            foreach (var se in pi.SweetExtra)
            {
                var exists = sweetOptions.FirstOrDefault(o => o.Name == se.Zh && o.StandaloneExternalData == se.Ed);
                if (exists is null)
                {
                    var opt = new SpecialOption
                    {
                        SpecialOptionGroupId = sweetGroup?.Id,
                        Kind = SpecialOptionKind.Sweetness,
                        Name = se.Zh,
                        EnglishName = null,
                        ExternalDataMode = ExternalDataMode.Standalone,
                        StandaloneExternalData = se.Ed,
                    };
                    _db.SpecialOptions.Add(opt);
                    result.Messages.Add($"新增甜度特殊選項主檔：{se.Zh} ({se.Ed})");
                }
            }
        }
        await _db.SaveChangesAsync(ct);
        sweetOptions = await _db.SpecialOptions.Where(o => o.Kind == SpecialOptionKind.Sweetness).ToListAsync(ct);

        int sort = 0;
        foreach (var pi in items)
        {
            var product = await _db.Products
                .Include(p => p.ProductCategories)
                .Include(p => p.Sizes)
                .Include(p => p.SpecialOptions)
                .Include(p => p.AddOns)
                .FirstOrDefaultAsync(p => p.Name == pi.Zh && p.EnglishName == pi.En && p.BasePrice == pi.Price, ct);
            bool isNew = product is null;
            if (isNew) product = new Product { IsEnabled = true };

            product.Name = pi.Zh;
            product.EnglishName = pi.En;
            product.Description = string.IsNullOrWhiteSpace(pi.Desc) ? null : pi.Desc;
            product.ImageUrl = string.IsNullOrWhiteSpace(pi.Img) ? null : pi.Img;
            product.BasePrice = pi.Price;
            if (isNew) product.SortOrder = sort;
            product.HasSizeGroup = pi.HasSize;
            product.SweetnessAtProductLevel = pi.SweetAtProductLevel;

            // 尺寸：清空重建
            product.Sizes.Clear();
            int sizeOrder = 0;
            foreach (var ps in pi.Sizes)
            {
                product.Sizes.Add(new ProductSize
                {
                    Name = ps.Name,
                    PriceAdjustment = ps.Adj,
                    ColdBaseCode = string.IsNullOrWhiteSpace(ps.Cold) ? null : ps.Cold,
                    HotBaseCode = string.IsNullOrWhiteSpace(ps.Hot) ? null : ps.Hot,
                    SortOrder = sizeOrder++,
                });
            }

            // 特口勾選：清空重建（溫度＋甜度＋甜度群組特殊選項）
            product.SpecialOptions.Clear();
            foreach (var sem in TempOrder)
            {
                if (!pi.TempSem.Contains(sem)) continue;
                var opt = tempOptions.FirstOrDefault(o => o.Name == sem);
                if (opt is null) { result.Messages.Add($"缺少溫度選項主檔：{sem}"); continue; }
                product.SpecialOptions.Add(new ProductSpecialOption { SpecialOptionId = opt.Id });
            }
            foreach (var sem in SweetOrder)
            {
                if (!pi.SweetSem.Contains(sem)) continue;
                var opt = sweetOptions.FirstOrDefault(o => o.Name == sem);
                if (opt is null) { result.Messages.Add($"缺少甜度選項主檔：{sem}"); continue; }
                product.SpecialOptions.Add(new ProductSpecialOption { SpecialOptionId = opt.Id });
            }
            foreach (var se in pi.SweetExtra)
            {
                var opt = sweetOptions.FirstOrDefault(o => o.Name == se.Zh && o.StandaloneExternalData == se.Ed);
                if (opt is null) { result.Messages.Add($"缺少甜度特殊選項主檔：{se.Zh}"); continue; }
                product.SpecialOptions.Add(new ProductSpecialOption { SpecialOptionId = opt.Id });
            }
            // 醇香蜂蜜：甜度群組選項（依尺寸品號/價格定義於 SpecialOptionSize；商品層勾選即可，匯出依尺寸自動帶品號）
            if (!string.IsNullOrWhiteSpace(pi.HoneySize))
            {
                var honeyOpt = sweetOptions.FirstOrDefault(x => x.Name == "醇香蜂蜜" && (x.Sizes ?? []).Any(s => s.IsEnabled));
                if (honeyOpt is null) result.Messages.Add("缺少甜度群組「醇香蜂蜜」選項主檔（含依尺寸品號定義）");
                else if (!product.SpecialOptions.Any(x => x.SpecialOptionId == honeyOpt.Id))
                    product.SpecialOptions.Add(new ProductSpecialOption { SpecialOptionId = honeyOpt.Id });
            }

            // 加料勾選：清空重建
            product.AddOns.Clear();
            foreach (var ed in pi.AddonEds)
            {
                var a = addons.FirstOrDefault(x => x.ExternalData == ed);
                if (a is null) { result.Messages.Add($"缺少加料主檔：{ed}"); continue; }
                product.AddOns.Add(new ProductAddOn { AddOnId = a.Id });
            }

            // 分類關聯：清空重建
            product.ProductCategories.Clear();
            foreach (var cname in pi.Cats)
            {
                var cat = categories.FirstOrDefault(c => c.Name == cname);
                if (cat is null) { result.Messages.Add($"缺少分類：{cname}"); continue; }
                product.ProductCategories.Add(new ProductCategory { CategoryId = cat.Id });
            }

            if (isNew) { _db.Products.Add(product); result.ProductsCreated++; }
            else result.ProductsUpdated++;
            sort++;
        }

        await _db.SaveChangesAsync(ct);
        result.Messages.Add($"分類 {result.CategoriesCreated} 新增；商品新增 {result.ProductsCreated}、更新 {result.ProductsUpdated}");
        return result;
    }

    private static PlanItem ParseItem(JsonElement e) => new()
    {
        Zh = e.GetProperty("zh").GetString() ?? "",
        En = e.GetProperty("en").GetString() ?? "",
        Price = e.GetProperty("price").GetDecimal(),
        Desc = e.GetProperty("desc").GetString() ?? "",
        Img = e.GetProperty("img").GetString() ?? "",
        Cats = e.GetProperty("cats").EnumerateArray().Select(x => x.GetString() ?? "").ToList(),
        HasSize = e.GetProperty("hasSize").GetBoolean(),
        Sizes = e.GetProperty("sizes").EnumerateArray().Select(s => new PlanSize
        {
            Name = s.GetProperty("name").GetString() ?? "",
            Adj = s.GetProperty("adj").GetDecimal(),
            Cold = s.GetProperty("cold").GetString() ?? "",
            Hot = s.GetProperty("hot").GetString() ?? "",
            Sort = s.GetProperty("sort").GetInt32(),
        }).ToList(),
        TempSem = e.GetProperty("tempSem").EnumerateArray().Select(x => x.GetString() ?? "").ToList(),
        SweetSem = e.GetProperty("sweetSem").EnumerateArray().Select(x => x.GetString() ?? "").ToList(),
        HoneySize = e.TryGetProperty("honeySize", out var h) && h.ValueKind == JsonValueKind.String ? h.GetString() : null,
        AddonEds = e.GetProperty("addonEds").EnumerateArray().Select(x => x.GetString() ?? "").ToList(),
        SweetExtra = e.TryGetProperty("sweetExtra", out var sx) && sx.ValueKind == JsonValueKind.Array
            ? sx.EnumerateArray().Select(x => new PlanSweetExtra
            {
                Zh = x.GetProperty("zh").GetString() ?? "",
                Ed = x.GetProperty("ed").GetString() ?? "",
                Price = x.TryGetProperty("price", out var pr) ? pr.GetDecimal() : 0m,
            }).ToList()
            : new List<PlanSweetExtra>(),
        SweetAtProductLevel = e.TryGetProperty("sweetAtProductLevel", out var sp) && sp.ValueKind == JsonValueKind.True,
    };
}
