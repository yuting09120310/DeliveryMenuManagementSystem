using System.ComponentModel.DataAnnotations;
using DMMS.Web.Models;

namespace DMMS.Web.ViewModels;

public sealed class DashboardViewModel
{
    public int ProductCount { get; init; }
    public int EnabledProductCount { get; init; }
    public int CategoryCount { get; init; }
    public int SpecialOptionGroupCount { get; init; }
    public int AddOnCount { get; init; }
    public int MissingCodeProductCount { get; init; }
    public string? DataError { get; init; }
}

public sealed class ProductListItemViewModel
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public string? EnglishName { get; init; }
    public decimal BasePrice { get; init; }
    public bool IsEnabled { get; init; }
    public string Categories { get; init; } = "未分類";
    public int SizeCount { get; init; }
    public bool MissingCode { get; init; }
    public int SpecialOptionCount { get; init; }
    public int AddOnCount { get; init; }
}

public sealed class ProductListViewModel
{
    public IReadOnlyList<ProductListItemViewModel> Products { get; init; } = [];
    public string? DataError { get; init; }
}

public sealed class ProductEditViewModel
{
    public int Id { get; set; }
    [Required(ErrorMessage = "請輸入商品名稱")]
    [Display(Name = "商品名稱")]
    public string Name { get; set; } = "";
    [Display(Name = "英文名稱")] public string? EnglishName { get; set; }
    [Display(Name = "商品描述")] public string? Description { get; set; }
    [Display(Name = "圖片網址")] public string? ImageUrl { get; set; }
    [Range(0, 999999, ErrorMessage = "基礎價格不可小於 0")]
    [Display(Name = "基礎價格")] public decimal BasePrice { get; set; }
    [Display(Name = "啟用商品")] public bool IsEnabled { get; set; } = true;
    [Display(Name = "排序")] public int SortOrder { get; set; }
    [Display(Name = "來源 External ID")] public string? SourceExternalId { get; set; }
    [Display(Name = "來源 UUID")] public string? SourceUuid { get; set; }
    public int? CategoryId { get; set; }
    public List<ProductSizeInputModel> Sizes { get; set; } = [];
    public IReadOnlyList<Category> Categories { get; set; } = [];
    /// <summary>商品已勾選啟用的特口選項（商品層級，不區分尺寸）。</summary>
    public List<int> SpecialOptionIds { get; set; } = [];
    /// <summary>依群組分類的特口選項，供表單群組化勾選。</summary>
    public List<SpecialOptionGroupChoice> GroupChoices { get; set; } = [];
    /// <summary>商品加料關聯（每尺寸一列，含品號/價格覆寫）。</summary>
    public List<ProductAddOnInputModel> AddOns { get; set; } = [];
    public IReadOnlyList<AddOn> AvailableAddOns { get; set; } = [];
    public string ExternalDataPreview => string.Join("、", Sizes.SelectMany(s => new[] { s.ColdBaseCode, s.HotBaseCode }).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct()) is var codes && !string.IsNullOrWhiteSpace(codes) ? codes : "尚未設定尺寸品號";
}

public sealed class SpecialOptionGroupChoice
{
    public int GroupId { get; init; }
    public string GroupName { get; init; } = "";
    public int Min { get; init; }
    public int Max { get; init; }
    public List<SpecialOptionChoice> Options { get; init; } = [];
}

public sealed class SpecialOptionChoice
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public string? EnglishName { get; init; }
    public string KindLabel { get; init; } = "";
}

public sealed class ProductAddOnInputModel
{
    public int Id { get; set; }
    public int AddOnId { get; set; }
    public string AddOnName { get; set; } = "";
    public int ProductSizeId { get; set; }
    public string SizeName { get; set; } = "";
    /// <summary>主檔預設品號（顯示用，不含 @）。</summary>
    public string DefaultExternalData { get; set; } = "";
    /// <summary>此尺寸實際輸出品號（含 @）。</summary>
    public string ExternalData { get; set; } = "";
    /// <summary>此尺寸實際加購價。</summary>
    public decimal Price { get; set; }
    /// <summary>主檔預設價格（顯示用）。</summary>
    public decimal DefaultPrice { get; set; }
    public bool IsEnabled { get; set; }
}

public sealed class ProductSizeInputModel
{
    public int Id { get; set; }
    [Required(ErrorMessage = "請輸入尺寸名稱")] public string Name { get; set; } = "";
    [Range(0, 999999, ErrorMessage = "價格加價不可小於 0")] public decimal PriceAdjustment { get; set; }
    public string? ColdBaseCode { get; set; }
    public string? HotBaseCode { get; set; }
    public bool IsEnabled { get; set; } = true;
    public int SortOrder { get; set; }
}
