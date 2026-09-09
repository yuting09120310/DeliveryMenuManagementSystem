using ClosedXML.Excel;
using DMMS.Web.Models;

namespace DMMS.Web.Services;

public sealed record MenuExportResult(byte[]? File, IReadOnlyList<string> Errors, IReadOnlyList<string> Warnings, IReadOnlyDictionary<string, int> RowCounts, IReadOnlyList<string> SheetNames);

/// <summary>
/// Uber Eats 菜單匯出。格式基準＝天仁 UE 校稿檔 Categories&amp;Items&amp;Modifiers（新莊-6/高雄）。
/// 規則（逐列對照附件）：
///  - Row1 = 88 欄 header（讀自模板；寫入時以 header 名稱找欄位，不寫死欄號）
///  - Row2 = Menu 列：ExternalID / Menu / UUID
///  - 每分類一列 Category（ExternalID / Category / UUID），其下接該分類商品
///  - Item 列：ExternalID / Item(中文 English) / Delivery Price(基礎價) / Description / IsEntree=False /
///    AlcoholicItemCount=0 / HasAlcoholicItems=False / ImageURL / UUID / uber_product_traits=[]
///  - 多尺寸商品：每個尺寸一段子樹 →「份量 Size」群組列(Nesting=1, 全尺寸同 ExternalID/UUID) +
///    尺寸選項列 + 特口群組(Nesting=2)：
///      飲料溫度群組 → 冰度選項（ExternalData = Cold/HotBaseCode + Suffix）
///      甜度群組 → 甜度選項（Standalone ExternalData）+ FixedRatio 加料併入尾端（依尺寸品號）
///    所有尺寸段結束後輸出「加點 Add-Ons」群組(Nesting=1, Max=1) + 一般加料(非 FixedRatio)。
///  - 單尺寸商品：不加 Size 群組，特口群組直接 Nesting=1。
///  - GlobalSettings：A1=StoreUUID B1=店家UUID、A2=DisableItemInstructions B2=True、A3=Tax(%)、A4=VatRate
///  - Menus：ExternalID/Menu/Monday..Sunday(營業時間)/ExternalNotes
///  - UUID 以實體 key 產生確定性 UUIDv5（同一商品重複匯出 UUID 不變，UE 才不會重複新增）。
/// </summary>
public sealed class MenuExportService(IWebHostEnvironment environment)
{
    private static readonly string[] FallbackHeaders =
    [
        "ExternalID","Menu","Category","Item","Modifier Group","Modifier Option","Nesting Level","Delivery Price","Other Price",
        "Offered Delivery (blank / null = TRUE)","Offered Other","Tax(%)","VatRate","Description","Min","Max","DefaultQuantity",
        "Calories","Joules","HasSide","IsEntree","AlcoholicItemCount","HasAlcoholicItems","IsVegetarian","IsVegan","IsGlutenFree",
        "ExternalData","ImageURL","ExternalNotes","Notes","GroupExternalID","EndorsementIcon","EndorsementText","SuspensionInterval",
        "SuspendUntil","StartDate","EndDate","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday","UUID",
        "uber_product_traits","uber_product_type"
    ];

    private string SourcePath => Path.Combine(environment.ContentRootPath, "Templates", "ue-source.xlsx");

    public IReadOnlyList<string> ReadHeaders()
    {
        if (!File.Exists(SourcePath)) return FallbackHeaders;
        try
        {
            using var workbook = new XLWorkbook(SourcePath);
            var sheet = workbook.Worksheets.FirstOrDefault(x => x.Name == "Categories&Items&Modifiers") ?? workbook.Worksheets.Last();
            return sheet.Row(1).CellsUsed().Select(x => x.GetString()).Where(x => !string.IsNullOrWhiteSpace(x)).ToArray();
        }
        catch { return FallbackHeaders; }
    }

    public MenuExportResult Build(Product[] products, MenuVersion? version = null)
    {
        var errors = new List<string>();
        var warnings = new List<string>();
        var storeUuid = version?.StoreUuid;
        var menuDisplay = string.IsNullOrWhiteSpace(version?.MenuDisplayName) ? "全日菜單 Menu" : version!.MenuDisplayName!;
        var menuExtId = string.IsNullOrWhiteSpace(version?.MenuExternalId) ? "全日菜單_Menu" : version!.MenuExternalId!;
        var openHours = string.IsNullOrWhiteSpace(version?.OpenHours) ? "10:30--20:00" : version!.OpenHours!;
        if (products.Length == 0) errors.Add("至少選擇一項商品才能匯出。");
        if (string.IsNullOrWhiteSpace(storeUuid)) warnings.Add("尚未設定 StoreUUID（GlobalSettings 欄位），請在「菜單建置」編輯頁填入 Uber Eats 店家 UUID。");
        var headers = ReadHeaders();
        if (headers.Count < 45) warnings.Add($"Categories&Items&Modifiers 來源標題讀到 {headers.Count} 欄（預期 88），未對應欄位將留空。");
        if (errors.Count > 0) return new(null, errors, warnings, new Dictionary<string, int>(), []);

        var cells = new CellWriter(headers.ToArray());
        using var workbook = new XLWorkbook();
        // ---- GlobalSettings（附件：無標題列，A1=StoreUUID 起，共 4 列 key/value）----
        var g = workbook.Worksheets.Add("GlobalSettings");
        g.Cell(1, 1).Value = "StoreUUID"; g.Cell(1, 2).Value = storeUuid ?? "";
        g.Cell(2, 1).Value = "DisableItemInstructions"; g.Cell(2, 2).Value = "True";
        g.Cell(3, 1).Value = "Tax(%)";
        g.Cell(4, 1).Value = "VatRate";

        // ---- Menus ----
        var m = workbook.Worksheets.Add("Menus");
        var menuCols = new[] { "ExternalID", "Menu", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "ExternalNotes" };
        for (var i = 0; i < menuCols.Length; i++) m.Cell(1, i + 1).Value = menuCols[i];
        m.Cell(2, 1).Value = menuExtId; m.Cell(2, 2).Value = menuDisplay;
        for (var d = 3; d <= 9; d++) m.Cell(2, d).Value = openHours;

        // ---- Categories&Items&Modifiers ----
        var s = workbook.Worksheets.Add("Categories&Items&Modifiers");
        for (var i = 0; i < headers.Count; i++) s.Cell(1, i + 1).Value = headers[i];
        ApplyReferenceColumnVisibility(s); // 比照原版隱藏 ExternalID/Other Price/DefaultQuantity 等欄
        var r = 2;
        // Menu 層列
        cells.Set(s, r, "ExternalID", menuExtId);
        cells.Set(s, r, "Menu", menuDisplay);
        cells.Set(s, r, "UUID", StableUuid($"menu|{menuExtId}"));
        r++;

        var grouped = GroupByCategory(products, warnings);
        foreach (var (category, items) in grouped)
        {
            cells.Set(s, r, "ExternalID", ExtId(category.Name, category.EnglishName, null));
            cells.Set(s, r, "Category", Display(category.Name, category.EnglishName));
            cells.Set(s, r, "UUID", StableUuid($"category|{category.Id}"));
            r++;
            foreach (var p in items) WriteProduct(s, cells, ref r, p, warnings);
        }

        var rowTotal = r - 1;
        var stream = new MemoryStream();
        workbook.SaveAs(stream);
        return new(stream.ToArray(), errors, warnings, new Dictionary<string, int> { ["GlobalSettings"] = 4, ["Menus"] = 1, ["Categories&Items&Modifiers"] = rowTotal }, ["GlobalSettings", "Menus", "Categories&Items&Modifiers"]);
    }

    /// <summary>
    /// 比照原版校稿檔：Categories&Items&Modifiers 隱藏 UE 匯入不需人工檢視的欄位
    /// （col1 ExternalID、col9-13 Other Price~VatRate、col17-26 DefaultQuantity~IsGlutenFree）。
    /// 欄位值仍在檔案中（廠商匯入讀取不受影響），僅 Excel 顯示時隱藏，外觀與原版一致。
    /// </summary>
    public static void ApplyReferenceColumnVisibility(IXLWorksheet sheet)
    {
        sheet.Column(1).Hide();
        sheet.Columns(9, 13).Hide();
        sheet.Columns(17, 26).Hide();
    }

    private static List<(Category Category, List<Product> Items)> GroupByCategory(Product[] products, List<string> warnings)
    {
        var groups = new List<(Category, List<Product>)>();
        foreach (var p in products.OrderBy(x => x.SortOrder).ThenBy(x => x.Id))
        {
            var cats = p.ProductCategories?.Select(x => x.Category).Where(c => c is not null).ToList() ?? [];
            if (cats.Count == 0) { warnings.Add($"商品「{p.Name}」尚未設定分類，不會輸出 Category/Item 列。"); continue; }
            foreach (var c in cats.OrderBy(c => c.SortOrder).ThenBy(c => c.Name))
            {
                var g = groups.FirstOrDefault(x => x.Item1.Id == c.Id);
                if (g.Item1 is null) { g = (c, []); groups.Add(g); }
                g.Item2.Add(p);
            }
        }
        return groups;
    }

    private void WriteProduct(IXLWorksheet s, CellWriter cells, ref int r, Product p, List<string> warnings)
    {
        var sizes = (p.Sizes ?? []).Where(x => x.IsEnabled).OrderBy(x => x.SortOrder).ThenBy(x => x.Id).ToList();
        if (sizes.Count == 0) { warnings.Add($"商品「{p.Name}」沒有啟用尺寸，已略過。"); return; }
        // Item 層
        cells.Set(s, r, "ExternalID", ExtId(p.Name, p.EnglishName, null));
        cells.Set(s, r, "Item", Display(p.Name, p.EnglishName));
        cells.Set(s, r, "Delivery Price", (double)p.BasePrice);
        cells.Set(s, r, "Description", p.Description);
        cells.Set(s, r, "IsEntree", false);
        cells.Set(s, r, "AlcoholicItemCount", 0);
        cells.Set(s, r, "HasAlcoholicItems", false);
        cells.Set(s, r, "ImageURL", p.ImageUrl);
        cells.Set(s, r, "UUID", StableUuid($"product|{p.Id}"));
        cells.Set(s, r, "uber_product_traits", "[]");
        r++;

        var specialOptions = (p.SpecialOptions ?? []).Where(x => x.IsEnabled && x.SpecialOption is { IsEnabled: true }).Select(x => x.SpecialOption!).ToList();
        var addOns = (p.AddOns ?? []).Where(x => x.IsEnabled && x.AddOn is not null).Select(x => x.AddOn!).ToList();

        if (sizes.Count == 1 && !p.HasSizeGroup)
        {
            WriteSpecialGroups(s, cells, ref r, p, sizes[0], specialOptions, addOns, nestLevel: 1);
            WriteAddOnsGroup(s, cells, ref r, p, addOns);
        }
        else
        {
            foreach (var size in sizes)
            {
                // B 型商品（甜度與尺寸無關）：尺寸段只輸出溫度特口，甜度群組商品層最後一次輸出
                var sizeOpts = p.SweetnessAtProductLevel
                    ? specialOptions.Where(o => o.Kind != SpecialOptionKind.Sweetness).ToList()
                    : specialOptions;
                WriteSizeSegment(s, cells, ref r, p, size, sizeOpts, addOns);
            }
            if (p.SweetnessAtProductLevel)
                WriteProductLevelSweetness(s, cells, ref r, p, specialOptions);
            WriteAddOnsGroup(s, cells, ref r, p, addOns);
        }
    }

    /// <summary>尺寸段：份量 Size 群組列(Nesting=1) → 尺寸選項 → 特口群組(Nesting=2)。</summary>
    private void WriteSizeSegment(IXLWorksheet s, CellWriter cells, ref int r, Product p, ProductSize size, List<SpecialOption> options, List<AddOn> addOns)
    {
        // 份量 Size 群組：同商品所有尺寸共用同一 ExternalID/UUID（附件 份量_Size_89304 於各尺寸段重複）
        var sizeGroupUuid = StableUuid($"sizegroup|{p.Id}");
        cells.Set(s, r, "ExternalID", $"份量_Size_{Code5(sizeGroupUuid)}");
        cells.Set(s, r, "Modifier Group", "份量 Size");
        cells.Set(s, r, "Nesting Level", 1);
        cells.Set(s, r, "Min", 1); cells.Set(s, r, "Max", 1);
        cells.Set(s, r, "UUID", sizeGroupUuid);
        r++;
        // 尺寸選項（原版中杯/大杯列固定帶 IsEntree/AlcoholicItemCount/HasAlcoholicItems）
        cells.Set(s, r, "ExternalID", ExtId(size.Name, SizeEnglish(size.Name), null));
        cells.Set(s, r, "Modifier Option", Display(size.Name, SizeEnglish(size.Name)));
        cells.Set(s, r, "Delivery Price", (double)size.PriceAdjustment);
        cells.Set(s, r, "Max", 1);
        cells.Set(s, r, "IsEntree", false);
        cells.Set(s, r, "AlcoholicItemCount", 0);
        cells.Set(s, r, "HasAlcoholicItems", false);
        cells.Set(s, r, "UUID", StableUuid($"sizeoption|{p.Id}|{size.Id}"));
        r++;
        WriteSpecialGroups(s, cells, ref r, p, size, options, addOns, nestLevel: 2);
    }

    private void WriteSpecialGroups(IXLWorksheet s, CellWriter cells, ref int r, Product p, ProductSize size, List<SpecialOption> options, List<AddOn> addOns, int nestLevel)
    {
        foreach (var grp in options.GroupBy(o => o.SpecialOptionGroupId ?? 0).OrderBy(g => g.First().Kind).ThenBy(g => g.Key))
        {
            var group = grp.First().Group;
            var groupUuid = StableUuid($"group|{p.Id}|{size.Id}|{group?.Id ?? 0}");
            var groupName = group?.Name ?? "選項";
            cells.Set(s, r, "ExternalID", ExtId(groupName, null, Code5(groupUuid)));
            cells.Set(s, r, "Modifier Group", groupName);
            cells.Set(s, r, "Nesting Level", nestLevel);
            if (group is { Min: > 0 }) cells.Set(s, r, "Min", group.Min);
            if (group is { Max: > 0 }) cells.Set(s, r, "Max", group.Max);
            cells.Set(s, r, "UUID", groupUuid);
            r++;
            var isSweetness = grp.First().Kind == SpecialOptionKind.Sweetness;
            foreach (var o in grp.OrderBy(o => o.Id))
            {
                // 依尺寸特化選項（如甜度群組的醇香蜂蜜：中杯 @IT1812(20)/10、大杯 @IT1836(40)/15）：
                // ExternalData/價格取自 SpecialOptionSize；名稱同主檔；UUID 含尺寸維度（跨商品共用、中杯/大杯各自穩定）
                var sizeDef = (o.Sizes ?? []).FirstOrDefault(x => x.IsEnabled && x.SizeName == size.Name);
                if (sizeDef is not null)
                {
                    var optUuid = StableUuid($"option|{o.Id}|{size.Name}");
                    var code = sizeDef.ExternalData.StartsWith('@') ? sizeDef.ExternalData : "@" + sizeDef.ExternalData;
                    cells.Set(s, r, "ExternalID", ExtId(o.Name, o.EnglishName, Code5(optUuid)));
                    cells.Set(s, r, "Modifier Option", Display(o.Name, o.EnglishName));
                    cells.Set(s, r, "Delivery Price", (double)sizeDef.Price);
                    cells.Set(s, r, "Max", 1);
                    cells.Set(s, r, "ExternalData", code);
                    cells.Set(s, r, "UUID", optUuid);
                    r++;
                    continue;
                }
                // Standalone（甜度）ExternalData 不隨尺寸/商品變 → 全檔共用同一 ExternalID/UUID
                // （附件：標準甜_Regular_Sugar 跨尺寸同 UUID 3f7a4d32、無數字後綴）；
                // BaseCodeAndSuffix（冰度）品號隨尺寸 base code 變 → 每 (商品,尺寸) 獨立 UUID + 後綴。
                if (o.ExternalDataMode == ExternalDataMode.Standalone)
                {
                    var optUuid = StableUuid($"option|{o.Id}");
                    cells.Set(s, r, "ExternalID", ExtId(o.Name, o.EnglishName, null));
                    cells.Set(s, r, "Modifier Option", Display(o.Name, o.EnglishName));
                    cells.Set(s, r, "Delivery Price", 0d);
                    cells.Set(s, r, "Max", 1);
                    cells.Set(s, r, "ExternalData", o.StandaloneExternalData ?? "");
                    cells.Set(s, r, "UUID", optUuid);
                }
                else
                {
                    var optUuid = StableUuid($"option|{p.Id}|{size.Id}|{o.Id}");
                    cells.Set(s, r, "ExternalID", ExtId(o.Name, o.EnglishName, Code5(optUuid)));
                    cells.Set(s, r, "Modifier Option", Display(o.Name, o.EnglishName));
                    cells.Set(s, r, "Delivery Price", 0d);
                    cells.Set(s, r, "Max", 1);
                    cells.Set(s, r, "ExternalData", ResolveExternalData(size, o));
                    cells.Set(s, r, "UUID", optUuid);
                }
                r++;
            }
        }
    }

    /// <summary>B 型商品：甜度群組在商品層輸出一次（附件 Nesting=1、UUID 不隨尺寸變）。選項 Standalone 跨商品共用 UUID；依尺寸特化選項（醇香蜂蜜）於此型商品不存在，忽略。</summary>
    private void WriteProductLevelSweetness(IXLWorksheet s, CellWriter cells, ref int r, Product p, List<SpecialOption> options)
    {
        foreach (var grp in options.Where(o => o.Kind == SpecialOptionKind.Sweetness && !(o.Sizes ?? []).Any(x => x.IsEnabled))
                     .GroupBy(o => o.SpecialOptionGroupId ?? 0).OrderBy(g => g.Key))
        {
            var group = grp.First().Group;
            var groupUuid = StableUuid($"group|{p.Id}|0|{group?.Id ?? 0}");
            var groupName = group?.Name ?? "選項";
            cells.Set(s, r, "ExternalID", ExtId(groupName, null, Code5(groupUuid)));
            cells.Set(s, r, "Modifier Group", groupName);
            cells.Set(s, r, "Nesting Level", 1);
            if (group is { Min: > 0 }) cells.Set(s, r, "Min", group.Min);
            if (group is { Max: > 0 }) cells.Set(s, r, "Max", group.Max);
            cells.Set(s, r, "UUID", groupUuid);
            r++;
            foreach (var o in grp.OrderBy(o => o.Id))
            {
                var optUuid = StableUuid($"option|{o.Id}");
                cells.Set(s, r, "ExternalID", ExtId(o.Name, o.EnglishName, null));
                cells.Set(s, r, "Modifier Option", Display(o.Name, o.EnglishName));
                cells.Set(s, r, "Delivery Price", 0d);
                cells.Set(s, r, "Max", 1);
                cells.Set(s, r, "ExternalData", o.StandaloneExternalData ?? "");
                cells.Set(s, r, "UUID", optUuid);
                r++;
            }
        }
    }

    /// <summary>加點 Add-Ons 群組（附件：Nesting=1、只有 Max=1 沒有 Min）＋一般加料（非 FixedRatio）。</summary>
    private void WriteAddOnsGroup(IXLWorksheet s, CellWriter cells, ref int r, Product p, List<AddOn> addOns)
    {
        var normal = addOns.Where(x => !x.FixedRatio).ToList();
        if (normal.Count == 0) return;
        var grpUuid = StableUuid($"addongroup|{p.Id}");
        cells.Set(s, r, "ExternalID", $"加點_Add-Ons_{Code5(grpUuid)}");
        cells.Set(s, r, "Modifier Group", "加點 Add-Ons");
        cells.Set(s, r, "Nesting Level", 1);
        cells.Set(s, r, "Max", 1);
        cells.Set(s, r, "UUID", grpUuid);
        r++;
        foreach (var a in normal)
        {
            var uuid = StableUuid($"addon|{p.Id}|{a.Id}");
            cells.Set(s, r, "ExternalID", ExtId(a.Name, a.EnglishName, Code5(uuid)));
            cells.Set(s, r, "Modifier Option", Display(a.Name, a.EnglishName));
            cells.Set(s, r, "Delivery Price", (double)a.Price);
            cells.Set(s, r, "Max", 1);
            cells.Set(s, r, "ExternalData", a.ExternalData.StartsWith('@') ? a.ExternalData : "@" + a.ExternalData);
            cells.Set(s, r, "UUID", uuid);
            r++;
        }
    }

    private static string ResolveExternalData(ProductSize size, SpecialOption o)
    {
        if (o.ExternalDataMode == ExternalDataMode.Standalone) return o.StandaloneExternalData ?? "";
        var cold = o.BeverageTemperature != BeverageTemperature.Hot;
        var baseCode = cold ? size.ColdBaseCode : size.HotBaseCode;
        if (string.IsNullOrWhiteSpace(baseCode)) return "";
        return string.IsNullOrWhiteSpace(o.Suffix) ? baseCode : baseCode + o.Suffix;
    }

    // ---------- helpers ----------

    private sealed class CellWriter(string[] headers)
    {
        private readonly Dictionary<string, int> _map = BuildMap(headers);
        private static Dictionary<string, int> BuildMap(string[] headers)
        {
            var map = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            for (var i = 0; i < headers.Length; i++) map.TryAdd(headers[i], i + 1);
            return map;
        }
        public void Set(IXLWorksheet s, int row, string header, string? value)
        {
            if (string.IsNullOrWhiteSpace(value)) return;
            if (_map.TryGetValue(header, out var c)) s.Cell(row, c).Value = value;
        }
        public void Set(IXLWorksheet s, int row, string header, double value)
        {
            if (_map.TryGetValue(header, out var c)) s.Cell(row, c).Value = value;
        }
        public void Set(IXLWorksheet s, int row, string header, int value)
        {
            if (_map.TryGetValue(header, out var c)) s.Cell(row, c).Value = value;
        }
        public void Set(IXLWorksheet s, int row, string header, bool value)
        {
            if (_map.TryGetValue(header, out var c)) s.Cell(row, c).Value = value;
        }
    }

    private static string Display(string zh, string? en) => string.IsNullOrWhiteSpace(en) ? zh : $"{zh} {en}".Trim();
    private static string ExtId(string? zh, string? en, string? suffix)
    {
        var raw = Slug($"{zh}_{en}".Trim('_'));
        if (suffix is null) return raw;
        var cap = raw.Length > 34 ? raw[..34].TrimEnd('_') : raw;
        return $"{cap}_{suffix}";
    }

    private static string Slug(string s)
    {
        if (string.IsNullOrWhiteSpace(s)) return "";
        var sb = new System.Text.StringBuilder();
        var prevSpace = false;
        foreach (var ch in s.Trim())
        {
            if (char.IsWhiteSpace(ch)) { if (!prevSpace && sb.Length > 0) sb.Append('_'); prevSpace = true; continue; }
            if (char.IsLetterOrDigit(ch) || ch is '_' or '-' or '(' or ')' or '%' or '／' or '/') { sb.Append(ch); prevSpace = false; }
        }
        return sb.ToString().Trim('_');
    }

    private static string SizeEnglish(string zh)
    {
        return zh switch { "中杯" => "Medium", "大杯" => "Large", "小杯" => "Small", _ => "" };
    }

    /// <summary>確定性 UUIDv5：同一 key 永遠得到同一 UUID（UE 靠 UUID 判斷同一實體，避免每次匯出被視為新增）。</summary>
    internal static string StableUuid(string key)
    {
        var ns = System.Security.Cryptography.MD5.HashData("dmms.ue.menu"u8);
        var bytes = System.Security.Cryptography.MD5.HashData([.. ns, .. System.Text.Encoding.UTF8.GetBytes(key)]);
        bytes[6] = (byte)((bytes[6] & 0x0F) | 0x50);
        bytes[8] = (byte)((bytes[8] & 0x3F) | 0x80);
        return new Guid(bytes).ToString();
    }

    private static string Code5(string uuid)
    {
        var hex = uuid.Replace("-", "");
        long n = 0; foreach (var ch in hex) n = (n * 31 + ch) % 90000;
        return (n + 10000).ToString();
    }
}
