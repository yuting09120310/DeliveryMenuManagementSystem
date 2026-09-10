using ClosedXML.Excel;
using DMMS.Web.Models;
using DMMS.Web.Services;

namespace DMMS.Tests;
public class MenuExportTests
{
    private static MenuExportService Service() => new(new TestEnvironment());
    private sealed class TestEnvironment : Microsoft.AspNetCore.Hosting.IWebHostEnvironment
    {
        public string ApplicationName { get; set; } = "Tests";
        public string EnvironmentName { get; set; } = "Testing";
        public string WebRootPath { get; set; } = "/tmp";
        public Microsoft.Extensions.FileProviders.IFileProvider WebRootFileProvider { get; set; } = new Microsoft.Extensions.FileProviders.PhysicalFileProvider("/tmp");
        public string ContentRootPath { get; set; } = "/tmp";
        public Microsoft.Extensions.FileProviders.IFileProvider ContentRootFileProvider { get; set; } = new Microsoft.Extensions.FileProviders.PhysicalFileProvider("/tmp");
    }
    private static Category Cat(string name, string? en = null, int id = 1) => new() { Id = id, Name = name, EnglishName = en };
    private static Product Product(string name, decimal price, Category cat, params ProductSize[] sizes)
    {
        var p = new Product { Id = 1, Name = name, EnglishName = name, BasePrice = price };
        foreach (var s in sizes) { s.Product = p; p.Sizes.Add(s); }
        p.ProductCategories.Add(new ProductCategory { Product = p, Category = cat });
        return p;
    }
    private static MenuVersion Version(string? uuid = null) => new() { Id = 1, StoreUuid = uuid ?? "59d870fa-c045-5906-935c-9f8a6adc265e", MenuExternalId = "全日菜單_Menu", MenuDisplayName = "全日菜單 Menu", OpenHours = "10:30--20:00" };

    private static T ReadSheet<T>(MenuExportResult r, string name, Func<IXLWorksheet, T> read)
    {
        Assert.NotNull(r.File);
        using var wb = new XLWorkbook(new MemoryStream(r.File));
        return read(wb.Worksheet(name));
    }

    [Fact] public void Empty_selection_is_blocked() { var r = Service().Build([]); Assert.Contains(r.Errors, x => x.Contains("至少選擇")); }
    [Fact] public void Product_without_category_warns_and_skips()
    {
        var p = new Product { Id = 1, Name = "茶", BasePrice = 50 }; p.Sizes.Add(new ProductSize { Id = 1, Name = "中杯", ColdBaseCode = "IT1" });
        var r = Service().Build([p], Version());
        Assert.Contains(r.Warnings, x => x.Contains("尚未設定分類"));
    }
    [Fact] public void Menu_and_category_rows_are_written()
    {
        var p = Product("紅茶", 50, Cat("原茶", "Classic Tea"));
        p.Sizes.Add(new ProductSize { Id = 1, ProductId = p.Id, Name = "中杯", ColdBaseCode = "IT1" });
        var r = Service().Build([p], Version());
        var rows = ReadSheet(r, "Categories&Items&Modifiers", ws =>
        {
            var list = new List<(string ext, string menu, string cat, string item)>();
            for (var i = 2; i <= ws.LastRowUsed()!.RowNumber(); i++)
                list.Add((ws.Cell(i, 1).GetString(), ws.Cell(i, 2).GetString(), ws.Cell(i, 3).GetString(), ws.Cell(i, 4).GetString()));
            return list;
        });
        Assert.Equal("全日菜單_Menu", rows[0].ext);          // Row2 = Menu 列
        Assert.Equal("全日菜單 Menu", rows[0].menu);
        Assert.Equal("原茶_Classic_Tea", rows[1].ext);         // Row3 = Category 列
        Assert.Equal("原茶 Classic Tea", rows[1].cat);
        Assert.Equal("紅茶 紅茶", rows[2].item);                // Row4 = Item 列
        Assert.Equal("全日菜單_Menu", rows[0].ext);
    }
    [Fact]
    public void Multi_size_product_emits_size_segments_and_addons_group()
    {
        // 醇香蜂蜜珍珠紅茶：中杯/大杯 + 冰度/甜度特口 + FixedRatio 蜂蜜(依尺寸) + 一般加料珍珠
        var p = Product("醇香蜂蜜珍珠紅茶", 60, Cat("人氣精選", "Popular Items"), 
            new ProductSize { Id = 1, Name = "中杯", ColdBaseCode = "IT0005-U", HotBaseCode = "IT6005-U" },
            new ProductSize { Id = 2, Name = "大杯", PriceAdjustment = 15, ColdBaseCode = "IT0006-U", HotBaseCode = "IT6006-U" });
        var tempGroup = new SpecialOptionGroup { Id = 1, Name = "飲料溫度 Beverage Temperature", Min = 1, Max = 1 };
        var sugarGroup = new SpecialOptionGroup { Id = 2, Name = "甜度 Sweetness Level", Min = 1, Max = 1 };
        var ice = new SpecialOption { Id = 1, Kind = SpecialOptionKind.Temperature, Name = "標準冰", EnglishName = "Regular Ice", BeverageTemperature = BeverageTemperature.Cold, Group = tempGroup, SpecialOptionGroupId = 1 };
        var hot = new SpecialOption { Id = 2, Kind = SpecialOptionKind.Temperature, Name = "熱", EnglishName = "Hot", BeverageTemperature = BeverageTemperature.Hot, Suffix = "(11)", Group = tempGroup, SpecialOptionGroupId = 1 };
        var noSugar = new SpecialOption { Id = 3, Kind = SpecialOptionKind.Sweetness, Name = "無糖", EnglishName = "Sugar Free", ExternalDataMode = ExternalDataMode.Standalone, StandaloneExternalData = "(08)", Group = sugarGroup, SpecialOptionGroupId = 2 };
        var honey = new SpecialOption { Id = 4, Kind = SpecialOptionKind.Sweetness, Name = "醇香蜂蜜", EnglishName = "Honey", Group = sugarGroup, SpecialOptionGroupId = 2 };
        honey.Sizes.Add(new SpecialOptionSize { SizeName = "中杯", ExternalData = "@IT1812(20)", Price = 10, SortOrder = 0 });
        honey.Sizes.Add(new SpecialOptionSize { SizeName = "大杯", ExternalData = "@IT1836(40)", Price = 15, SortOrder = 1 });
        foreach (var o in new[] { ice, hot, noSugar, honey }) p.SpecialOptions.Add(new ProductSpecialOption { Product = p, SpecialOption = o, IsEnabled = true });
        var boba = new AddOn { Id = 2, Name = "珍珠", EnglishName = "Tapioca", ExternalData = "@IT1810(19)", Price = 10 };
        p.AddOns.Add(new ProductAddOn { Product = p, AddOn = boba, IsEnabled = true });

        var r = Service().Build([p], Version());
        var rows = ReadSheet(r, "Categories&Items&Modifiers", ws =>
        {
            var list = new List<(string ext, string group, string opt, string item, string level, string extData)>();
            for (var i = 2; i <= ws.LastRowUsed()!.RowNumber(); i++)
                list.Add((ws.Cell(i, 1).GetString(), ws.Cell(i, 5).GetString(), ws.Cell(i, 6).GetString(), ws.Cell(i, 4).GetString(), ws.Cell(i, 7).GetString(), ws.Cell(i, 27).GetString()));
            return list;
        });
        // 定位 Item 列（col4 有值），其後才是 modifiers
        var start = rows.FindIndex(x => x.item != "") + 1;
        Assert.True(start > 0, "找不到 Item 列");
        var mods = rows.Skip(start).ToList();
        // 兩個「份量 Size」群組列（中杯段/大杯段）
        Assert.Equal(2, mods.Count(x => x.group == "份量 Size"));
        // 溫度群組出現兩次（每尺寸一次）
        Assert.Equal(2, mods.Count(x => x.group.Contains("飲料溫度")));
        // 甜度群組出現兩次 + 蜂蜜在甜度段（FixedRatio 併入）
        Assert.Equal(2, mods.Count(x => x.group.Contains("甜度")));
        Assert.Contains(mods, x => x.opt.Contains("醇香蜂蜜") && x.extData == "@IT1836(40)"); // 大杯蜂蜜品號
        // 一般加料珍珠放「加點 Add-Ons」群組（商品層，一組）
        var addonRows = mods.SkipWhile(x => x.group != "加點 Add-Ons").ToList();
        Assert.Contains(addonRows, x => x.opt.Contains("珍珠") && x.extData == "@IT1810(19)");
        // 中杯冰度 ExternalData = ColdBaseCode（無 suffix）
        Assert.Contains(mods, x => x.opt.Contains("標準冰") && x.extData == "IT0005-U");
        Assert.Contains(mods, x => x.opt.Contains("熱") && x.extData == "IT6005-U(11)");
    }
    [Fact]
    public void Single_size_product_still_emits_size_group_with_sweetness_inside()
    {
        // 統一結構：單一尺寸商品同樣輸出「份量 Size」群組段，特口（含甜度）在其尺寸段內 Nesting=2
        var p = Product("紅茶", 50, Cat("原茶", "Classic Tea"));
        p.Sizes.Add(new ProductSize { Id = 1, ProductId = p.Id, Name = "中杯", ColdBaseCode = "IT1" });
        var sugarGroup = new SpecialOptionGroup { Id = 2, Name = "甜度 Sweetness Level", Min = 1, Max = 1 };
        p.SpecialOptions.Add(new ProductSpecialOption { Product = p, SpecialOption = new SpecialOption { Id = 3, Kind = SpecialOptionKind.Sweetness, Name = "無糖", EnglishName = "Sugar Free", ExternalDataMode = ExternalDataMode.Standalone, StandaloneExternalData = "(08)", Group = sugarGroup, SpecialOptionGroupId = 2 }, IsEnabled = true });
        var r = Service().Build([p], Version());
        var mods = ReadSheet(r, "Categories&Items&Modifiers", ws =>
        {
            var list = new List<(string group, string opt, string level)>();
            for (var i = 2; i <= ws.LastRowUsed()!.RowNumber(); i++)
                list.Add((ws.Cell(i, 5).GetString(), ws.Cell(i, 6).GetString(), ws.Cell(i, 7).GetString()));
            return list;
        }).Where(x => x.group != "" || x.opt != "").ToList();
        Assert.Contains(mods, x => x.group == "份量 Size" && x.level == "1");
        Assert.Contains(mods, x => x.group.Contains("甜度") && x.level == "2");
    }
    [Fact]
    public void Global_settings_and_menus_match_template()
    {
        var p = Product("紅茶", 50, Cat("原茶", "Classic Tea"));
        p.Sizes.Add(new ProductSize { Id = 1, ProductId = p.Id, Name = "中杯", ColdBaseCode = "IT1" });
        var r = Service().Build([p], Version());
        ReadSheet(r, "GlobalSettings", ws =>
        {
            Assert.Equal("StoreUUID", ws.Cell(1, 1).GetString());
            Assert.Equal("59d870fa-c045-5906-935c-9f8a6adc265e", ws.Cell(1, 2).GetString());
            Assert.Equal("DisableItemInstructions", ws.Cell(2, 1).GetString());
            Assert.Equal("True", ws.Cell(2, 2).GetString());
            Assert.Equal("Tax(%)", ws.Cell(3, 1).GetString());
            Assert.Equal("VatRate", ws.Cell(4, 1).GetString());
            return true;
        });
        ReadSheet(r, "Menus", ws =>
        {
            Assert.Equal("全日菜單 Menu", ws.Cell(2, 2).GetString());
            Assert.Equal("10:30--20:00", ws.Cell(2, 3).GetString()); // Monday
            Assert.Equal("10:30--20:00", ws.Cell(2, 9).GetString()); // Sunday
            return true;
        });
    }
    [Fact]
    public void Export_is_deterministic_same_product_same_uuid()
    {
        var p = Product("紅茶", 50, Cat("原茶", "Classic Tea"));
        p.Sizes.Add(new ProductSize { Id = 1, ProductId = p.Id, Name = "中杯", ColdBaseCode = "IT1" });
        var a = Service().Build([p], Version());
        var b = Service().Build([p], Version());
        var u1 = ReadSheet(a, "Categories&Items&Modifiers", ws => ws.Cell(4, 45).GetString()); // Item UUID col45
        var u2 = ReadSheet(b, "Categories&Items&Modifiers", ws => ws.Cell(4, 45).GetString());
        Assert.Equal(u1, u2);
    }

    // ---------- 地區定價 ----------

    private static MenuVersion VersionForRegion(int regionId) => new()
    {
        Id = 1, StoreUuid = "59d870fa-c045-5906-935c-9f8a6adc265e", MenuExternalId = "全日菜單_Menu",
        MenuDisplayName = "全日菜單 Menu", OpenHours = "10:30--20:00",
        RegionId = regionId, Region = new Region { Id = regionId, Name = regionId == 2 ? "南區" : "北區" }
    };

    [Fact]
    public void Region_price_overrides_base_price_for_item_row_size_adjustment_unchanged()
    {
        // 913茶王：BasePrice 70（北區）；南區 75 → Item 75、大杯加價 10 全區共用（UE 顯示 85）
        var p = Product("913 茶王", 70, Cat("原茶", "Classic Tea"),
            new ProductSize { Id = 1, Name = "中杯", ColdBaseCode = "IT1" },
            new ProductSize { Id = 2, Name = "大杯", PriceAdjustment = 10, ColdBaseCode = "IT2" });
        p.RegionPrices.Add(new ProductRegionPrice { ProductId = p.Id, RegionId = 2, Price = 75 });
        var r = Service().Build([p], VersionForRegion(2));
        Assert.Equal(75, ReadSheet(r, "Categories&Items&Modifiers", ws => ws.Cell(4, 8).GetDouble())); // Item Delivery Price
        // 尺寸列：中杯/大杯各自一段（份量 Size 群組列 + 尺寸選項列）；加價全區共用不變
        var sizePrices = ReadSheet(r, "Categories&Items&Modifiers", ws =>
        {
            var list = new List<(string opt, double price)>();
            for (var i = 2; i <= ws.LastRowUsed()!.RowNumber(); i++)
            {
                var opt = ws.Cell(i, 6).GetString();
                if (opt.StartsWith("中杯") || opt.StartsWith("大杯")) list.Add((opt, ws.Cell(i, 8).GetDouble()));
            }
            return list;
        });
        Assert.Equal(0, sizePrices.Single(x => x.opt.StartsWith("中杯")).price);
        Assert.Equal(10, sizePrices.Single(x => x.opt.StartsWith("大杯")).price);
        Assert.Equal(1, r.PriceStats.Total);
        Assert.Equal(0, r.PriceStats.Defaulted);
        Assert.Equal(0, r.PriceStats.Zero);
    }

    [Fact]
    public void Missing_or_blank_region_price_falls_back_to_base_price_and_counts_as_defaulted()
    {
        var p = Product("紅茶", 50, Cat("原茶", "Classic Tea"));
        p.Sizes.Add(new ProductSize { Id = 1, ProductId = p.Id, Name = "中杯", ColdBaseCode = "IT1" });
        p.RegionPrices.Add(new ProductRegionPrice { ProductId = p.Id, RegionId = 1, Price = null }); // 留空
        var r = Service().Build([p], VersionForRegion(1));
        Assert.Equal(50, ReadSheet(r, "Categories&Items&Modifiers", ws => ws.Cell(4, 8).GetDouble()));
        Assert.Equal(1, r.PriceStats.Defaulted);
    }

    [Fact]
    public void Negative_region_price_blocks_export()
    {
        var p = Product("紅茶", 50, Cat("原茶", "Classic Tea"));
        p.Sizes.Add(new ProductSize { Id = 1, ProductId = p.Id, Name = "中杯", ColdBaseCode = "IT1" });
        p.RegionPrices.Add(new ProductRegionPrice { ProductId = p.Id, RegionId = 1, Price = -5 });
        var r = Service().Build([p], VersionForRegion(1));
        Assert.Null(r.File);
        Assert.Contains(r.Errors, x => x.Contains("負數"));
    }

    [Fact]
    public void Zero_region_price_is_allowed_but_counted()
    {
        var p = Product("贈品茶", 50, Cat("原茶", "Classic Tea"));
        p.Sizes.Add(new ProductSize { Id = 1, ProductId = p.Id, Name = "中杯", ColdBaseCode = "IT1" });
        p.RegionPrices.Add(new ProductRegionPrice { ProductId = p.Id, RegionId = 1, Price = 0 });
        var r = Service().Build([p], VersionForRegion(1));
        Assert.NotNull(r.File);
        Assert.Equal(1, r.PriceStats.Zero);
        Assert.Equal(0, r.PriceStats.Defaulted);
    }
}
