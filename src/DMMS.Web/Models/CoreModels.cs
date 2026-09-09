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
    /// <summary>單一尺寸商品是否仍輸出「份量 Size」群組段（原版茶王$65 等單尺寸商品亦宣告 Size group；多多綠茶等則無）。</summary>
    public bool HasSizeGroup { get; set; }
    /// <summary>甜度群組輸出位置：false＝每個尺寸段內各輸出一次（原版 913茶王 型，Nesting=2）；true＝尺寸段結束後商品層輸出一次（原版 經典綠茶/珍珠奶茶 型，Nesting=1，與尺寸無關）。</summary>
    public bool SweetnessAtProductLevel { get; set; }
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
