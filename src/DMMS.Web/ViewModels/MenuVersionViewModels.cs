using System.ComponentModel.DataAnnotations;
using DMMS.Web.Models;

namespace DMMS.Web.ViewModels;
public sealed class MenuVersionEditViewModel
{
    public int Id { get; set; }
    [Required(ErrorMessage = "請輸入菜單版本名稱")]
    public string Name { get; set; } = "UE 菜單";
    [Required(ErrorMessage = "請選擇地區")]
    [Display(Name = "地區")]
    public int? RegionId { get; set; }
    public IReadOnlyList<Region> Regions { get; set; } = [];
    /// <summary>版本列表顯示用（Dashboard／Index）。</summary>
    public string? RegionName { get; set; }
    public List<int> SelectedProductIds { get; set; } = [];
    public IReadOnlyList<Product> Products { get; set; } = [];
}
public sealed class MenuVersionPreviewViewModel
{
    public MenuVersion Version { get; init; } = null!;
    public IReadOnlyList<string> Errors { get; init; } = [];
    public IReadOnlyList<string> Warnings { get; init; } = [];
    public IReadOnlyDictionary<string,int> RowCounts { get; init; } = new Dictionary<string,int>();
    public IReadOnlyList<string> SheetNames { get; init; } = [];
    public string? RegionName { get; init; }
    /// <summary>套用結果統計：總品項／使用預設基礎價／0 元。</summary>
    public MenuPriceStats PriceStats { get; init; } = new(0, 0, 0);
}
