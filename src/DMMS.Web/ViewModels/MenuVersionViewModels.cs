using System.ComponentModel.DataAnnotations;
using DMMS.Web.Models;

namespace DMMS.Web.ViewModels;
public sealed class MenuVersionEditViewModel
{
    public int Id { get; set; }
    [Required] public string Name { get; set; } = "UE 菜單 V1";
    public string Platform { get; set; } = "UberEats";
    [Display(Name = "StoreUUID（店家 UE UUID）")]
    public string? StoreUuid { get; set; }
    [Display(Name = "UE 菜單 ExternalID")]
    public string MenuExternalId { get; set; } = "全日菜單_Menu";
    [Display(Name = "UE 菜單顯示名稱")]
    public string MenuDisplayName { get; set; } = "全日菜單 Menu";
    [Display(Name = "每日營業時間")]
    public string OpenHours { get; set; } = "10:30--20:00";
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
}
