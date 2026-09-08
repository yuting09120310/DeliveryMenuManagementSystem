using ClosedXML.Excel;
using DMMS.Web.Models;

namespace DMMS.Web.Services;

public sealed record MenuExportResult(byte[]? File, IReadOnlyList<string> Errors, IReadOnlyList<string> Warnings, IReadOnlyDictionary<string, int> RowCounts, IReadOnlyList<string> SheetNames);
public sealed record MenuExportRow(string Kind, string ProductName, string SizeName, string ModifierName, string ExternalData, decimal Price);

public sealed class MenuExportService(IWebHostEnvironment environment)
{
    private static readonly string[] FallbackHeaders = ["ExternalID", "Menu", "Category", "Item", "Modifier Group", "Modifier Option", "Nesting Level", "Delivery Price", "Other Price", "Offered Delivery (blank / null = TRUE)"];
    private string SourcePath => Path.Combine(environment.ContentRootPath, "Templates", "ue-source.xlsx");
    private string AttachmentPath => "/home/alexvm/.hermes/attachments/天仁釀茶所 新莊店校稿20260723-5.xlsx";

    public IReadOnlyList<string> ReadHeaders()
    {
        var path = File.Exists(SourcePath) ? SourcePath : AttachmentPath;
        if (!File.Exists(path)) return FallbackHeaders;
        using var workbook = new XLWorkbook(path);
        var sheet = workbook.Worksheets.FirstOrDefault(x => x.Name == "Categories&Items&Modifiers") ?? workbook.Worksheets.Last();
        return sheet.Row(1).CellsUsed().Select(x => x.GetString()).Where(x => !string.IsNullOrWhiteSpace(x)).ToArray();
    }

    public IReadOnlyList<MenuExportRow> BuildRows(IEnumerable<Product> products)
    {
        var rows = new List<MenuExportRow>();
        foreach (var product in products.OrderBy(x => x.SortOrder).ThenBy(x => x.Id))
        {
            foreach (var size in product.Sizes.Where(x => x.IsEnabled).OrderBy(x => x.SortOrder))
            {
                rows.Add(new("ProductSize", product.Name, size.Name, "", size.ColdBaseCode ?? size.HotBaseCode ?? $"PRODUCT-{product.Id}-SIZE-{size.Id}", product.BasePrice + size.PriceAdjustment));
                foreach (var option in product.SpecialOptions.Where(x => x.IsEnabled && x.SpecialOption.IsEnabled).Select(x => x.SpecialOption))
                    rows.Add(new("SpecialOption", product.Name, size.Name, option.Name, option.ExternalDataMode == ExternalDataMode.Standalone ? option.StandaloneExternalData ?? "" : option.Suffix ?? "", 0));
                // 加料：商品層級勾選 → 依尺寸查 AddOn 主檔的 AddOnSize（找不到 fallback 主檔預設品號/價格）
                foreach (var pa in product.AddOns.Where(x => x.IsEnabled))
                {
                    var addOn = pa.AddOn;
                    var sizeDef = addOn?.Sizes?.FirstOrDefault(s => s.IsEnabled && s.SizeName == size.Name);
                    var code = !string.IsNullOrWhiteSpace(sizeDef?.ExternalData) ? sizeDef.ExternalData : addOn?.ExternalData ?? "";
                    var price = !string.IsNullOrWhiteSpace(sizeDef?.ExternalData) ? sizeDef.Price : addOn?.Price ?? 0;
                    rows.Add(new("ProductAddOn", product.Name, size.Name, addOn?.Name ?? $"加料#{pa.AddOnId}", code.StartsWith('@') ? code : "@" + code, price));
                }
            }
        }
        return rows;
    }

    public MenuExportResult Build(Product[] products)
    {
        var errors = new List<string>();
        var warnings = new List<string>();
        if (products.Length == 0) errors.Add("至少選擇一項商品才能匯出。");
        var headers = ReadHeaders();
        if (headers.Count != 88) warnings.Add($"Categories&Items&Modifiers 來源標題實際讀到 {headers.Count} 欄，未可靠映射的欄位留空；請確認來源模板。");
        var rows = BuildRows(products);
        if (rows.Count == 0 && products.Length > 0) warnings.Add("選取商品沒有啟用尺寸，因此沒有可展開的商品列。");
        var counts = new Dictionary<string, int> { ["GlobalSettings"] = 2, ["Menus"] = 1, ["Categories&Items&Modifiers"] = rows.Count };
        if (errors.Count > 0) return new(null, errors, warnings, counts, ["GlobalSettings", "Menus", "Categories&Items&Modifiers"]);

        using var workbook = new XLWorkbook();
        var global = workbook.Worksheets.Add("GlobalSettings"); global.Cell(1, 1).Value = "Key"; global.Cell(1, 2).Value = "Value"; global.Cell(2, 1).Value = "DisableItemInstructions"; global.Cell(2, 2).Value = "TRUE";
        var menus = workbook.Worksheets.Add("Menus"); var menuHeaders = new[] { "ExternalID", "Menu", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "ExternalNotes" }; for (var i = 0; i < menuHeaders.Length; i++) menus.Cell(1, i + 1).Value = menuHeaders[i]; menus.Cell(2, 1).Value = "UE菜單V1_Menu"; menus.Cell(2, 2).Value = "UE菜單V1";
        var items = workbook.Worksheets.Add("Categories&Items&Modifiers"); for (var i = 0; i < headers.Count; i++) items.Cell(1, i + 1).Value = headers[i];
        for (var r = 0; r < rows.Count; r++) { var row = rows[r]; items.Cell(r + 2, 1).Value = $"PRODUCT-{products.First(x => x.Name == row.ProductName).Id}-{row.Kind}-{r + 1}"; items.Cell(r + 2, 2).Value = "UE菜單V1"; items.Cell(r + 2, 4).Value = row.ProductName; items.Cell(r + 2, 5).Value = row.Kind; items.Cell(r + 2, 6).Value = row.ModifierName; items.Cell(r + 2, 7).Value = row.SizeName; items.Cell(r + 2, 8).Value = row.Price; items.Cell(r + 2, 28).Value = row.ExternalData; }
        using var stream = new MemoryStream(); workbook.SaveAs(stream); return new(stream.ToArray(), errors, warnings, counts, workbook.Worksheets.Select(x => x.Name).ToArray());
    }
}
