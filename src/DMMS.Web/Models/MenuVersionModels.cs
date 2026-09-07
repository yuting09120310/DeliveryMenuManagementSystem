namespace DMMS.Web.Models;

public class MenuVersion
{
    public int Id { get; set; }
    public string Name { get; set; } = "UE 菜單 V1";
    public string Platform { get; set; } = "UberEats";
    public string Status { get; set; } = "Draft";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ExportedAt { get; set; }
    public ICollection<MenuVersionProduct> Products { get; set; } = new List<MenuVersionProduct>();
}

public class MenuVersionProduct
{
    public int MenuVersionId { get; set; }
    public MenuVersion MenuVersion { get; set; } = null!;
    public int ProductId { get; set; }
    public Product Product { get; set; } = null!;
}
