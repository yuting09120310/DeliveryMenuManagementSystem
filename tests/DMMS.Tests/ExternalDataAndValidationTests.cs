using DMMS.Web.Data;
using DMMS.Web.Models;
using DMMS.Web.Services;
using Microsoft.EntityFrameworkCore;

namespace DMMS.Tests;

public class ExternalDataAndValidationTests
{
    private static ProductSize Size(string cold = "IT0005-U", string? hot = "IT6005-U") =>
        new() { Name = "中杯", ColdBaseCode = cold, HotBaseCode = hot };

    [Fact]
    public void Temperature_uses_base_code_and_suffix()
    {
        var size = Size();
        var option = new SpecialOption { Kind = SpecialOptionKind.Temperature, BeverageTemperature = BeverageTemperature.Cold, Suffix = "(02)" };

        var result = new ExternalDataCalculator().CalculateTemperature(size, option);

        Assert.Equal("IT0005-U(02)", result);
    }

    [Fact]
    public void Sweetness_is_standalone_external_data()
    {
        var option = new SpecialOption { Kind = SpecialOptionKind.Sweetness, StandaloneExternalData = "(05)" };

        var result = new ExternalDataCalculator().CalculateSweetness(option);

        Assert.Equal("(05)", result);
    }

    [Fact]
    public void AddOn_uses_at_code()
    {
        var addOn = new AddOn { Name = "珍珠", ExternalData = "IT1810(19)" };

        var result = new ExternalDataCalculator().CalculateAddOn(addOn);

        Assert.Equal("@IT1810(19)", result);
    }

    [Fact]
    public void Hot_temperature_without_hot_base_code_is_invalid()
    {
        var product = new Product { Name = "紅茶" };
        var size = Size(hot: null);
        product.Sizes.Add(size);
        product.SpecialOptions.Add(new ProductSpecialOption
        {
            SpecialOption = new SpecialOption { Kind = SpecialOptionKind.Temperature, BeverageTemperature = BeverageTemperature.Hot, Suffix = "(11)", IsEnabled = true }
        });

        var errors = new ProductValidationService().Validate(product);

        Assert.Contains(errors, e => e.Code == ProductValidationErrorCodes.MissingHotBaseCode);
    }

    [Fact]
    public void Cold_temperature_without_cold_base_code_is_invalid()
    {
        var product = new Product { Name = "奶茶" };
        var size = Size(cold: "", hot: "IT6005-U");
        product.Sizes.Add(size);
        product.SpecialOptions.Add(new ProductSpecialOption
        {
            SpecialOption = new SpecialOption { Kind = SpecialOptionKind.Temperature, BeverageTemperature = BeverageTemperature.Cold, Suffix = "(02)", IsEnabled = true }
        });

        var errors = new ProductValidationService().Validate(product);

        Assert.Contains(errors, e => e.Code == ProductValidationErrorCodes.MissingColdBaseCode);
    }

    [Fact]
    public void AddOn_size_definitions_differ_per_size()
    {
        // 醇香蜂蜜主檔：中杯 @IT1812(20)/10、大杯 @IT1836(40)/15
        var addOn = new AddOn
        {
            Name = "醇香蜂蜜", ExternalData = "@IT1812(20)", Price = 10,
            Sizes =
            {
                new AddOnSize { SizeName = "中杯", ExternalData = "@IT1812(20)", Price = 10 },
                new AddOnSize { SizeName = "大杯", ExternalData = "@IT1836(40)", Price = 15 }
            }
        };
        var mediumDef = addOn.Sizes.Single(s => s.SizeName == "中杯");
        var largeDef = addOn.Sizes.Single(s => s.SizeName == "大杯");

        Assert.Equal("@IT1812(20)", mediumDef.ExternalData);
        Assert.Equal(10, mediumDef.Price);
        Assert.Equal("@IT1836(40)", largeDef.ExternalData);
        Assert.Equal(15, largeDef.Price);
    }

    [Fact]
    public void DbContext_maps_core_normalized_entities()
    {
        var options = new DbContextOptionsBuilder<DmmsDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options;
        using var db = new DmmsDbContext(options);
        db.Products.Add(new Product { Name = "測試商品", Sizes = { Size() } });
        db.SaveChanges();

        Assert.Equal(1, db.Products.Count());
        Assert.Equal(1, db.ProductSizes.Count());
    }
}
