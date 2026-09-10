namespace DMMS.Web.Models;

public enum SpecialOptionKind { Temperature, Sweetness, Other }
public enum BeverageTemperature { Cold, Hot }
public enum ExternalDataMode { BaseCodeAndSuffix, Standalone }

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string? EnglishName { get; set; }
    public int SortOrder { get; set; }
    public string? SourceExternalId { get; set; }
    public ICollection<ProductCategory> ProductCategories { get; set; } = new List<ProductCategory>();
}

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string? EnglishName { get; set; }
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public decimal BasePrice { get; set; }
    public bool IsEnabled { get; set; } = true;
    public int SortOrder { get; set; }
    public string? SourceExternalId { get; set; }
    public string? SourceUuid { get; set; }
    public ICollection<ProductCategory> ProductCategories { get; set; } = new List<ProductCategory>();
    public ICollection<ProductSize> Sizes { get; set; } = new List<ProductSize>();
    public ICollection<ProductSpecialOption> SpecialOptions { get; set; } = new List<ProductSpecialOption>();
    public ICollection<ProductAddOn> AddOns { get; set; } = new List<ProductAddOn>();
    /// <summary>各地區定價（基礎價/中杯價）。</summary>
    public ICollection<ProductRegionPrice> RegionPrices { get; set; } = new List<ProductRegionPrice>();
}

public class ProductCategory { public int ProductId { get; set; } public Product Product { get; set; } = null!; public int CategoryId { get; set; } public Category Category { get; set; } = null!; }
public class ProductSize
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public Product? Product { get; set; }
    public string Name { get; set; } = "";
    public decimal PriceAdjustment { get; set; }
    public string? ColdBaseCode { get; set; }
    public string? HotBaseCode { get; set; }
    public bool IsEnabled { get; set; } = true;
    public int SortOrder { get; set; }
}

public class SpecialOptionGroup
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public int Min { get; set; }
    public int Max { get; set; } = 1;
    public ICollection<SpecialOption> Options { get; set; } = new List<SpecialOption>();
}
public class SpecialOption
{
    public int Id { get; set; }
    public int? SpecialOptionGroupId { get; set; }
    public SpecialOptionGroup? Group { get; set; }
    public SpecialOptionKind Kind { get; set; }
    public string Name { get; set; } = "";
    public string? EnglishName { get; set; }
    public ExternalDataMode ExternalDataMode { get; set; }
    public string? Suffix { get; set; }
    public string? StandaloneExternalData { get; set; }
    public BeverageTemperature? BeverageTemperature { get; set; }
    public bool IsEnabled { get; set; } = true;
    /// <summary>依尺寸特化的品號／價格（如甜度群組的醇香蜂蜜：中杯 @IT1812(20)/10、大杯 @IT1836(40)/15）。有此定義時匯出優先依尺寸輸出，ExternalDataMode/Suffix 僅供無尺寸特化時使用。</summary>
    public ICollection<SpecialOptionSize> Sizes { get; set; } = new List<SpecialOptionSize>();
}
/// <summary>特口選項依尺寸的品號／價格定義（例如醇香蜂蜜：中杯 @IT1812(20) NT$10、大杯 @IT1836(40) NT$15）。</summary>
public class SpecialOptionSize
{
    public int Id { get; set; }
    public int SpecialOptionId { get; set; }
    public SpecialOption? SpecialOption { get; set; }
    public string SizeName { get; set; } = "";
    public string ExternalData { get; set; } = "";
    public decimal Price { get; set; }
    public bool IsEnabled { get; set; } = true;
    public int SortOrder { get; set; }
}
public class ProductSpecialOption
{
    public int ProductId { get; set; } public Product Product { get; set; } = null!;
    public int SpecialOptionId { get; set; } public SpecialOption SpecialOption { get; set; } = null!;
    public bool IsEnabled { get; set; } = true;
}
public class AddOn
{
    public int Id { get; set; } public string Name { get; set; } = ""; public string? EnglishName { get; set; }
    /// <summary>預設加購價（未依尺寸特化時的 fallback）。</summary>
    public decimal Price { get; set; }
    /// <summary>預設品號（未依尺寸特化時的 fallback，含 @）。</summary>
    public string ExternalData { get; set; } = "";
    public bool IcedOnly { get; set; } public bool FixedRatio { get; set; } public bool IsEnabled { get; set; } = true;
    public int SortOrder { get; set; }
    public ICollection<AddOnSize> Sizes { get; set; } = new List<AddOnSize>();
}
/// <summary>加料依尺寸的品號／價格定義（如醇香蜂蜜 中杯 @IT1812(20)/10、大杯 @IT1836(40)/15）。</summary>
public class AddOnSize
{
    public int Id { get; set; }
    public int AddOnId { get; set; } public AddOn? AddOn { get; set; }
    public string SizeName { get; set; } = "";
    public string ExternalData { get; set; } = "";
    public decimal Price { get; set; }
    public bool IsEnabled { get; set; } = true;
    public int SortOrder { get; set; }
}
public class ProductAddOn
{
    public int ProductId { get; set; } public Product Product { get; set; } = null!;
    public int AddOnId { get; set; } public AddOn AddOn { get; set; } = null!;
    public bool IsEnabled { get; set; } = true;
}
public class PlatformProductMapping { public int Id { get; set; } public string Platform { get; set; } = ""; public string? OriginalExternalId { get; set; } public string? Uuid { get; set; } public string? OriginalName { get; set; } public string? SourceMetadata { get; set; } }
public class ExportHistory { public int Id { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; public string Platform { get; set; } = ""; }

/// <summary>匯出價格套用統計（Total＝Item 數、Defaulted＝回退 BasePrice 數、Zero＝0 元數）。</summary>
public sealed record MenuPriceStats(int Total, int Defaulted, int Zero);

/// <summary>價格區（北區／南區／未來中區…）。純價格維度，與 UE 店家/UUID 無關。</summary>
public class Region
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public int SortOrder { get; set; }
    public bool IsEnabled { get; set; } = true;
    public ICollection<ProductRegionPrice> ProductPrices { get; set; } = new List<ProductRegionPrice>();
}

/// <summary>商品在特定價格區的基礎價（＝中杯價；大杯＝本價 + ProductSize.PriceAdjustment）。
/// Price=null 表示留空，匯出時回退 Product.BasePrice。尺寸加價/加料/特口價不分區，全區共用。</summary>
public class ProductRegionPrice
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public Product? Product { get; set; }
    public int RegionId { get; set; }
    public Region? Region { get; set; }
    public decimal? Price { get; set; }
    /// <summary>最後手動修改時間（預填建立時為 null＝從未手動調整）。</summary>
    public DateTime? PriceModifiedAt { get; set; }
}
