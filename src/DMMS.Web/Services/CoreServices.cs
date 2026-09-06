using DMMS.Web.Models;

namespace DMMS.Web.Services;

public sealed class ExternalDataCalculator
{
    public string CalculateTemperature(ProductSize size, SpecialOption option)
    {
        var baseCode = option.BeverageTemperature == BeverageTemperature.Hot ? size.HotBaseCode : size.ColdBaseCode;
        if (string.IsNullOrWhiteSpace(baseCode)) throw new InvalidOperationException("Temperature base code is required.");
        return baseCode + (option.Suffix ?? "");
    }
    public string CalculateSweetness(SpecialOption option) => option.StandaloneExternalData ?? "";
    public string CalculateAddOn(AddOn addOn) => addOn.ExternalData.StartsWith('@') ? addOn.ExternalData : "@" + addOn.ExternalData;
    /// <summary>以商品尺寸關聯的品號為準（支援不同尺寸不同品號，如醇香蜂蜜 中杯 @IT1812(20) / 大杯 @IT1836(40)）。</summary>
    public string CalculateAddOn(ProductAddOn pa) => pa.ExternalData.StartsWith('@') ? pa.ExternalData : "@" + pa.ExternalData;
}

public sealed record ProductValidationError(string Code, string Message);
public static class ProductValidationErrorCodes
{
    public const string MissingHotBaseCode = "MissingHotBaseCode";
    public const string MissingColdBaseCode = "MissingColdBaseCode";
}
public sealed class ProductValidationService
{
    public IReadOnlyList<ProductValidationError> Validate(Product product)
    {
        var errors = new List<ProductValidationError>();
        var enabledSizes = product.Sizes.Where(s => s.IsEnabled).ToList();
        if (enabledSizes.Count == 0) return errors;
        foreach (var link in product.SpecialOptions.Where(x => x.IsEnabled && x.SpecialOption.IsEnabled && x.SpecialOption.Kind == SpecialOptionKind.Temperature))
        {
            foreach (var size in enabledSizes)
            {
                if (link.SpecialOption.BeverageTemperature == BeverageTemperature.Hot && string.IsNullOrWhiteSpace(size.HotBaseCode))
                    errors.Add(new(ProductValidationErrorCodes.MissingHotBaseCode, $"商品「{product.Name}」尺寸「{size.Name}」啟用了熱飲溫度選項，但缺少 HotBaseCode。"));
                if (link.SpecialOption.BeverageTemperature == BeverageTemperature.Cold && string.IsNullOrWhiteSpace(size.ColdBaseCode))
                    errors.Add(new(ProductValidationErrorCodes.MissingColdBaseCode, $"商品「{product.Name}」尺寸「{size.Name}」啟用了冷飲溫度選項，但缺少 ColdBaseCode。"));
            }
        }
        return errors;
    }
}
