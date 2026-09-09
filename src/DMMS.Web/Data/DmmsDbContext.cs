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
    public DbSet<SpecialOptionSize> SpecialOptionSizes => Set<SpecialOptionSize>();
    public DbSet<ProductSpecialOption> ProductSpecialOptions => Set<ProductSpecialOption>();
    public DbSet<AddOn> AddOns => Set<AddOn>();
    public DbSet<AddOnSize> AddOnSizes => Set<AddOnSize>();
    public DbSet<ProductAddOn> ProductAddOns => Set<ProductAddOn>();
    public DbSet<PlatformProductMapping> PlatformProductMappings => Set<PlatformProductMapping>();
    public DbSet<ExportHistory> ExportHistories => Set<ExportHistory>();
    public DbSet<MenuVersion> MenuVersions => Set<MenuVersion>();
    public DbSet<MenuVersionProduct> MenuVersionProducts => Set<MenuVersionProduct>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.HasDefaultSchema("dmms");
        b.UsePropertyAccessMode(PropertyAccessMode.PreferFieldDuringConstruction);
        b.Entity<ProductCategory>().HasKey(x => new { x.ProductId, x.CategoryId });
        b.Entity<ProductCategory>().HasOne(x => x.Product).WithMany(x => x.ProductCategories).HasForeignKey(x => x.ProductId);
        b.Entity<ProductCategory>().HasOne(x => x.Category).WithMany(x => x.ProductCategories).HasForeignKey(x => x.CategoryId);
        b.Entity<ProductSpecialOption>().HasKey(x => new { x.ProductId, x.SpecialOptionId });
        b.Entity<ProductSpecialOption>().HasOne(x => x.Product).WithMany(x => x.SpecialOptions).HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.NoAction);
        b.Entity<ProductSpecialOption>().HasOne(x => x.SpecialOption).WithMany().HasForeignKey(x => x.SpecialOptionId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<ProductAddOn>().HasKey(x => new { x.ProductId, x.AddOnId });
        b.Entity<ProductAddOn>().HasOne(x => x.Product).WithMany(x => x.AddOns).HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.NoAction);
        b.Entity<ProductAddOn>().HasOne(x => x.AddOn).WithMany().HasForeignKey(x => x.AddOnId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<AddOnSize>().HasKey(x => x.Id);
        b.Entity<AddOnSize>().HasOne(x => x.AddOn).WithMany(x => x.Sizes).HasForeignKey(x => x.AddOnId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<SpecialOptionSize>().HasKey(x => x.Id);
        b.Entity<SpecialOptionSize>().HasOne(x => x.SpecialOption).WithMany(x => x.Sizes).HasForeignKey(x => x.SpecialOptionId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<AddOn>().Property(x => x.Price).HasPrecision(18, 2);
        b.Entity<AddOnSize>().Property(x => x.Price).HasPrecision(18, 2);
        b.Entity<SpecialOptionSize>().Property(x => x.Price).HasPrecision(18, 2);
        b.Entity<Product>().Property(x => x.BasePrice).HasPrecision(18, 2);
        b.Entity<ProductSize>().Property(x => x.PriceAdjustment).HasPrecision(18, 2);
        b.Entity<MenuVersionProduct>().HasKey(x => new { x.MenuVersionId, x.ProductId });
        b.Entity<MenuVersionProduct>().HasOne(x => x.MenuVersion).WithMany(x => x.Products).HasForeignKey(x => x.MenuVersionId).OnDelete(DeleteBehavior.Cascade);
        b.Entity<MenuVersionProduct>().HasOne(x => x.Product).WithMany().HasForeignKey(x => x.ProductId).OnDelete(DeleteBehavior.NoAction);
    }
}
