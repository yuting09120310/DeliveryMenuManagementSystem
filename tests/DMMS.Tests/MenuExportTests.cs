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
    [Fact] public void Different_size_addon_codes_are_preserved() { var p = new Product { Name = "蜜茶" }; var m = new ProductSize { Id = 1, Name = "中杯", ColdBaseCode = "A" }; var l = new ProductSize { Id = 2, Name = "大杯", ColdBaseCode = "B" }; p.Sizes.Add(m); p.Sizes.Add(l); var a = new AddOn { Name = "蜂蜜" }; p.AddOns.Add(new ProductAddOn { ProductSize = m, ProductSizeId = 1, AddOn = a, ExternalData = "@IT1812(20)" }); p.AddOns.Add(new ProductAddOn { ProductSize = l, ProductSizeId = 2, AddOn = a, ExternalData = "@IT1836(40)" }); var rows = Service().BuildRows([p]); Assert.Contains(rows, x => x.ExternalData == "@IT1812(20)"); Assert.Contains(rows, x => x.ExternalData == "@IT1836(40)"); }
}
internal static class MenuExportTestExtensions { public static IEnumerable<MenuExportRow> RowsForTest(this MenuExportResult _) => []; }
