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
    public string ExternalDataPreview => string.Join("、", Sizes.SelectMany(s => new[] { s.ColdBaseCode, s.HotBaseCode }).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct()) is var codes && !string.IsNullOrWhiteSpace(codes) ? codes : "尚未設定尺寸品號";
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
