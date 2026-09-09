using System.ComponentModel.DataAnnotations;

namespace DMMS.Web.ViewModels;

public sealed class CategoryListViewModel
{
    public IReadOnlyList<CategoryListItemViewModel> Categories { get; init; } = [];
    public string? DataError { get; init; }
}

public sealed class CategoryListItemViewModel
{
    public int Id { get; init; }
    public string Name { get; init; } = "";
    public string? EnglishName { get; init; }
    public int SortOrder { get; init; }
    public int ProductCount { get; init; }
}

public sealed class CategoryEditViewModel
{
    public int Id { get; set; }
    [Required(ErrorMessage = "請輸入分類名稱")]
    [Display(Name = "分類名稱")]
    public string Name { get; set; } = "";
    [Display(Name = "英文名稱")]
    public string? EnglishName { get; set; }
    [Display(Name = "排序")]
    public int SortOrder { get; set; }
}
