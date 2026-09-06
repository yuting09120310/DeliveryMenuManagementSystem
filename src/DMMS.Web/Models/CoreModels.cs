namespace DMMS.Web.Models;

public enum SpecialOptionKind { Temperature, Sweetness, Other }
public enum BeverageTemperature { Cold, Hot }
public enum ExternalDataMode { BaseCodeAndSuffix, Standalone }

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
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
    public decimal Price { get; set; } public string ExternalData { get; set; } = "";
    public bool IcedOnly { get; set; } public int? SizeOnlyId { get; set; } public bool FixedRatio { get; set; } public bool IsEnabled { get; set; } = true;
}
public class ProductAddOn
{
    public int Id { get; set; }
    public int ProductId { get; set; } public Product Product { get; set; } = null!;
    public int AddOnId { get; set; } public AddOn AddOn { get; set; } = null!;
    public int ProductSizeId { get; set; } public ProductSize ProductSize { get; set; } = null!;
    /// <summary>此尺寸實際輸出品號（含 @）。可由主檔帶入，也可覆寫（例如醇香蜂蜜 中杯 @IT1812(20) / 大杯 @IT1836(40)）。</summary>
    public string ExternalData { get; set; } = "";
    /// <summary>此尺寸實際加購價。可由主檔帶入，也可覆寫。</summary>
    public decimal Price { get; set; }
    public bool IsEnabled { get; set; } = true;
}
public class PlatformProductMapping { public int Id { get; set; } public string Platform { get; set; } = ""; public string? OriginalExternalId { get; set; } public string? Uuid { get; set; } public string? OriginalName { get; set; } public string? SourceMetadata { get; set; } }
public class ExportHistory { public int Id { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; public string Platform { get; set; } = ""; }
