using DMMS.Web.Models;
using Microsoft.EntityFrameworkCore;

namespace DMMS.Web.Data;

public class DmmsDbContext(DbContextOptions<DmmsDbContext> options) : DbContext(options)
{
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<ProductCategory> ProductCategories => Set<ProductCategory>();
    public DbSet<ProductSize> ProductSizes => Set<ProductSize>();
    public DbSet<SpecialOptionGroup> SpecialOptionGroups => Set<SpecialOptionGroup>();
    public DbSet<SpecialOption> SpecialOptions => Set<SpecialOption>();
    public DbSet<ProductSpecialOption> ProductSpecialOptions => Set<ProductSpecialOption>();
    public DbSet<AddOn> AddOns => Set<AddOn>();
    public DbSet<ProductAddOn> ProductAddOns => Set<ProductAddOn>();
    public DbSet<PlatformProductMapping> PlatformProductMappings => Set<PlatformProductMapping>();
    public DbSet<ExportHistory> ExportHistories => Set<ExportHistory>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<ProductCategory>().HasKey(x => new { x.ProductId, x.CategoryId });
        b.Entity<ProductCategory>().HasOne(x => x.Product).WithMany(x => x.ProductCategories).HasForeignKey(x => x.ProductId);
        b.Entity<ProductCategory>().HasOne(x => x.Category).WithMany(x => x.ProductCategories).HasForeignKey(x => x.CategoryId);
        b.Entity<ProductSpecialOption>().HasKey(x => new { x.ProductId, x.ProductSizeId, x.SpecialOptionId });
        b.Entity<ProductAddOn>().HasKey(x => new { x.ProductId, x.AddOnId, x.ProductSizeId });
        b.Entity<Product>().Property(x => x.BasePrice).HasPrecision(18, 2);
        b.Entity<ProductSize>().Property(x => x.PriceAdjustment).HasPrecision(18, 2);
        b.Entity<AddOn>().Property(x => x.Price).HasPrecision(18, 2);
    }
}
