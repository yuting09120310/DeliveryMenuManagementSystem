using DMMS.Web.Models;
using DMMS.Web.Services;

namespace DMMS.Tests;
public class MenuExportTests
{
    private static MenuExportService Service() => new(new TestEnvironment());
    private sealed class TestEnvironment : Microsoft.AspNetCore.Hosting.IWebHostEnvironment
    {
        public string ApplicationName { get; set; } = "Tests";
        public string EnvironmentName { get; set; } = "Testing";
        public string WebRootPath { get; set; } = "/tmp";
        public Microsoft.Extensions.FileProviders.IFileProvider WebRootFileProvider { get; set; } = new Microsoft.Extensions.FileProviders.PhysicalFileProvider("/tmp");
        public string ContentRootPath { get; set; } = "/tmp";
        public Microsoft.Extensions.FileProviders.IFileProvider ContentRootFileProvider { get; set; } = new Microsoft.Extensions.FileProviders.PhysicalFileProvider("/tmp");
    }
    [Fact] public void Empty_selection_is_blocked() { var r = Service().Build([]); Assert.Contains(r.Errors, x => x.Contains("至少選擇")); }
    [Fact] public void Selected_product_builds_size_rows() { var p = new Product { Name = "茶" }; p.Sizes.Add(new ProductSize { Id = 1, ProductId = 1, Name = "中杯", ColdBaseCode = "IT1" }); var rows = Service().BuildRows([p]); Assert.Contains(rows, x => x.Kind == "ProductSize" && x.ProductName == "茶"); }
    [Fact]
    public void Different_size_addon_codes_are_preserved_from_addon_master()
    {
        // 醇香蜂蜜：主檔定義 中杯 @IT1812(20)/10、大杯 @IT1836(40)/15；商品只勾選該加料
        var p = new Product { Name = "蜜茶" };
        p.Sizes.Add(new ProductSize { Id = 1, Name = "中杯", ColdBaseCode = "A" });
        p.Sizes.Add(new ProductSize { Id = 2, Name = "大杯", ColdBaseCode = "B" });
        var addOn = new AddOn
        {
            Name = "醇香蜂蜜", ExternalData = "@IT1812(20)", Price = 10,
            Sizes =
            {
                new AddOnSize { SizeName = "中杯", ExternalData = "@IT1812(20)", Price = 10 },
                new AddOnSize { SizeName = "大杯", ExternalData = "@IT1836(40)", Price = 15 }
            }
        };
        p.AddOns.Add(new ProductAddOn { AddOnId = 1, AddOn = addOn, IsEnabled = true });
        var rows = Service().BuildRows([p]);
        Assert.Contains(rows, x => x.Kind == "ProductAddOn" && x.SizeName == "中杯" && x.ExternalData == "@IT1812(20)" && x.Price == 10);
        Assert.Contains(rows, x => x.Kind == "ProductAddOn" && x.SizeName == "大杯" && x.ExternalData == "@IT1836(40)" && x.Price == 15);
    }
    [Fact]
    public void Addon_without_size_definition_falls_back_to_master_code()
    {
        var p = new Product { Name = "紅茶" };
        p.Sizes.Add(new ProductSize { Id = 1, Name = "中杯", ColdBaseCode = "A" });
        p.Sizes.Add(new ProductSize { Id = 2, Name = "大杯", ColdBaseCode = "B" });
        var addOn = new AddOn { Name = "珍珠", ExternalData = "@IT1810(19)", Price = 10 };
        p.AddOns.Add(new ProductAddOn { AddOn = addOn, IsEnabled = true });
        var rows = Service().BuildRows([p]);
        Assert.Equal(2, rows.Count(x => x.Kind == "ProductAddOn" && x.ExternalData == "@IT1810(19)" && x.Price == 10));
    }
}
