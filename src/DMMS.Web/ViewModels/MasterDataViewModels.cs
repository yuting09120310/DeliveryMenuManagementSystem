using System.ComponentModel.DataAnnotations;
using DMMS.Web.Models;

namespace DMMS.Web.ViewModels;

public sealed class SpecialOptionGroupListViewModel
{
    public IReadOnlyList<SpecialOptionGroupListItemViewModel> Groups { get; init; } = [];
    public string? DataError { get; init; }
}

public sealed class SpecialOptionGroupListItemViewModel
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public int Min { get; init; }
    public int Max { get; init; }
    public int OptionCount { get; init; }
    public int EnabledOptionCount { get; init; }
    public bool HasProductLinks { get; init; }
}

public sealed class SpecialOptionGroupEditViewModel
{
    public int Id { get; set; }
    [Required(ErrorMessage = "請輸入群組名稱")]
    [Display(Name = "群組名稱")]
    public string Name { get; set; } = "";
    [Display(Name = "最少選擇數 Min")]
    public int Min { get; set; } = 0;
    [Display(Name = "最多選擇數 Max")]
    public int Max { get; set; } = 1;
    [Display(Name = "選項")]
    public List<SpecialOptionInputModel> Options { get; set; } = [];
    public bool InUseByProducts { get; set; }
    public string? Error { get; set; }
}

public sealed class SpecialOptionInputModel
{
    public int Id { get; set; }
    [Required(ErrorMessage = "請輸入選項名稱")]
    [Display(Name = "選項名稱")]
    public string Name { get; set; } = "";
    [Display(Name = "英文名稱")] public string? EnglishName { get; set; }
    [Display(Name = "類型")] public SpecialOptionKind Kind { get; set; } = SpecialOptionKind.Temperature;
    [Display(Name = "輸出模式")] public ExternalDataMode ExternalDataMode { get; set; } = ExternalDataMode.BaseCodeAndSuffix;
    [Display(Name = "冷/熱")] public BeverageTemperature? BeverageTemperature { get; set; }
    [Display(Name = "後綴 Suffix")] public string? Suffix { get; set; }
    [Display(Name = "獨立 ExternalData")] public string? StandaloneExternalData { get; set; }
    [Display(Name = "啟用")] public bool IsEnabled { get; set; } = true;
}

public sealed class AddOnListViewModel
{
    public IReadOnlyList<AddOnListItemViewModel> AddOns { get; init; } = [];
    public string? DataError { get; init; }
}

public sealed class AddOnListItemViewModel
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public string? EnglishName { get; init; }
    public decimal Price { get; init; }
    public string ExternalData { get; init; } = "";
    public string ExternalDataDisplay { get; init; } = "";
    public bool IcedOnly { get; init; }
    public bool FixedRatio { get; init; }
    public bool IsEnabled { get; init; }
}

public sealed class AddOnEditViewModel
{
    public int Id { get; set; }
    [Required(ErrorMessage = "請輸入加料名稱")]
    [Display(Name = "加料名稱")] public string Name { get; set; } = "";
    [Display(Name = "英文名稱")] public string? EnglishName { get; set; }
    [Range(0, 999999, ErrorMessage = "價格不可小於 0")]
    [Display(Name = "加購價格")] public decimal Price { get; set; }
    [Required(ErrorMessage = "請輸入 ExternalData")]
    [Display(Name = "ExternalData")] public string ExternalData { get; set; } = "";
    [Display(Name = "僅限冰飲")] public bool IcedOnly { get; set; }
    [Display(Name = "固定比例")] public bool FixedRatio { get; set; }
    [Display(Name = "啟用")] public bool IsEnabled { get; set; } = true;
}
