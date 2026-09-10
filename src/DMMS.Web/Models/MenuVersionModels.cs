namespace DMMS.Web.Models;

public class MenuVersion
{
    public int Id { get; set; }
    public string Name { get; set; } = "UE 菜單 V1";
    public string Platform { get; set; } = "UberEats";
    public string Status { get; set; } = "Draft";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? ExportedAt { get; set; }
    /// <summary>Uber Eats 店家 StoreUUID（GlobalSettings 用，首次匯出時從 UE 後台取得）。</summary>
    public string? StoreUuid { get; set; }
    /// <summary>UE 菜單外部 ID（Menus sheet 用，預設 全日菜單_Menu）。</summary>
    public string MenuExternalId { get; set; } = "全日菜單_Menu";
    /// <summary>UE 菜單顯示名稱（Menus sheet 用，預設 全日菜單 Menu）。</summary>
    public string MenuDisplayName { get; set; } = "全日菜單 Menu";
    /// <summary>每日營業時間（格式如 10:30--20:00，套用一～日）。</summary>
    public string OpenHours { get; set; } = "10:30--20:00";
    /// <summary>此菜單版本所屬價格區（北區／南區…）。匯出時以該區地區價為 Item 基礎價。</summary>
    public int? RegionId { get; set; }
    public Region? Region { get; set; }
    public ICollection<MenuVersionProduct> Products { get; set; } = new List<MenuVersionProduct>();
}

public class MenuVersionProduct
{
    public int MenuVersionId { get; set; }
    public MenuVersion MenuVersion { get; set; } = null!;
    public int ProductId { get; set; }
    public Product Product { get; set; } = null!;
}
