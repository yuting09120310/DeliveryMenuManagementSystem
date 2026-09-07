using System.ComponentModel.DataAnnotations;
using DMMS.Web.Models;

namespace DMMS.Web.ViewModels;
public sealed class MenuVersionEditViewModel
{
    public int Id { get; set; }
    [Required] public string Name { get; set; } = "UE 菜單 V1";
    public string Platform { get; set; } = "UberEats";
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
