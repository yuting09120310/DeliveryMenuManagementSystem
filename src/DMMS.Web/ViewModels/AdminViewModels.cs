using System.ComponentModel.DataAnnotations;
using DMMS.Web.Models;

namespace DMMS.Web.ViewModels;

public sealed class DashboardViewModel
{
    public int ProductCount { get; init; }
    public int EnabledProductCount { get; init; }
    public int CategoryCount { get; init; }
    public int AddOnCount { get; init; }
    public int SpecialOptionCount { get; init; }
    public int IceOptionCount { get; init; }
    public int SweetOptionCount { get; init; }
    public int MissingCodeProductCount { get; init; }
    public IReadOnlyList<string> MissingCodeProductNames { get; init; } = [];
    public IReadOnlyList<MenuVersion> RecentVersions { get; init; } = [];
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
    /// <summary>各地區定價摘要（如「北區 NT$70、南區 NT$75」）。</summary>
    public string RegionPrices { get; init; } = "";
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
    [Display(Name = "預設基礎價（僅用於新地區預填，不參與匯出）")] public decimal BasePrice { get; set; }
    [Display(Name = "啟用商品")] public bool IsEnabled { get; set; } = true;
    [Display(Name = "排序")] public int SortOrder { get; set; }
    /// <summary>單一尺寸商品是否仍輸出「份量 Size」群組段（原版茶王$65 等單尺寸商品亦宣告 Size group；多多綠茶等則無）。</summary>
    [Display(Name = "單一尺寸時仍輸出「份量 Size」群組")] public bool HasSizeGroup { get; set; }
    /// <summary>甜度群組輸出位置：false＝每個尺寸段內各輸出一次(Nesting=2)；true＝尺寸段結束後商品層輸出一次(Nesting=1，原版經典綠茶/珍珠奶茶型)。</summary>
    [Display(Name = "甜度與尺寸無關（商品層輸出一次）")] public bool SweetnessAtProductLevel { get; set; }
    /// <summary>商品所屬分類（可多選；同商品可掛多個分類，匯出時於各分類下各輸出一次）。</summary>
    [Display(Name = "商品分類")]
    public List<int> CategoryIds { get; set; } = [];
    public List<ProductSizeInputModel> Sizes { get; set; } = [];
    public IReadOnlyList<Category> Categories { get; set; } = [];
    /// <summary>商品已勾選啟用的特口選項（商品層級，不區分尺寸）。</summary>
    public List<int> SpecialOptionIds { get; set; } = [];
    /// <summary>依群組分類的特口選項，供表單群組化勾選。</summary>
    public List<SpecialOptionGroupChoice> GroupChoices { get; set; } = [];
    /// <summary>商品已勾選的加料（商品層級，品號由加料主檔依尺寸定義）。</summary>
    public List<int> AddOnIds { get; set; } = [];
    public IReadOnlyList<AddOnChoiceItem> AvailableAddOns { get; set; } = [];
    /// <summary>各地區基礎價（＝中杯價）。留空＝匯出時回退 BasePrice。</summary>
    public List<ProductRegionPriceInputModel> RegionPrices { get; set; } = [];
    public string ExternalDataPreview => string.Join("、", Sizes.SelectMany(s => new[] { s.ColdBaseCode, s.HotBaseCode }).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct()) is var codes && !string.IsNullOrWhiteSpace(codes) ? codes : "尚未設定尺寸品號";
}

public sealed class ProductRegionPriceInputModel
{
    public int RegionId { get; set; }
    public string RegionName { get; set; } = "";
    /// <summary>該區基礎價（中杯）。null＝留空，匯出行回退 BasePrice。</summary>
    [Range(0, 999999, ErrorMessage = "地區價格不可小於 0")]
    public decimal? Price { get; set; }
    /// <summary>最後手動修改時間（未改過為 null）。</summary>
    public DateTime? ModifiedAt { get; set; }
}

public sealed class AddOnChoiceItem
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public string? EnglishName { get; init; }
    public string DefaultCode { get; init; } = "";
    public decimal DefaultPrice { get; init; }
    public bool IcedOnly { get; init; }
    public bool FixedRatio { get; init; }
    public string SizeSummary { get; init; } = "";
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

// ---------- 價格區（地區） ----------

public sealed class RegionListItemViewModel
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public int SortOrder { get; init; }
    public bool IsEnabled { get; init; }
    /// <summary>已建立地區價的商品數。</summary>
    public int PriceCount { get; init; }
    /// <summary>綁定此區的菜單版本數。</summary>
    public int MenuVersionCount { get; init; }
}

public sealed class RegionEditViewModel
{
    public int Id { get; set; }
    [Required(ErrorMessage = "請輸入地區名稱")]
    [Display(Name = "地區名稱")]
    public string Name { get; set; } = "";
    [Display(Name = "排序")]
    public int SortOrder { get; set; }
    [Display(Name = "啟用")]
    public bool IsEnabled { get; set; } = true;
    /// <summary>編輯時顯示：已建立地區價的商品數。</summary>
    public int PriceCount { get; set; }
    /// <summary>編輯時顯示：綁定此區的菜單版本數。</summary>
    public int MenuVersionCount { get; set; }
}
