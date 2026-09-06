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
        foreach (var link in product.SpecialOptions.Where(x => x.IsEnabled && x.SpecialOption.IsEnabled && x.SpecialOption.Kind == SpecialOptionKind.Temperature))
        {
            var size = link.ProductSize ?? product.Sizes.SingleOrDefault();
            if (size is null) continue;
            if (link.SpecialOption.BeverageTemperature == BeverageTemperature.Hot && string.IsNullOrWhiteSpace(size.HotBaseCode))
                errors.Add(new(ProductValidationErrorCodes.MissingHotBaseCode, $"商品「{product.Name}」尺寸「{size.Name}」缺少 HotBaseCode。"));
            if (link.SpecialOption.BeverageTemperature == BeverageTemperature.Cold && string.IsNullOrWhiteSpace(size.ColdBaseCode))
                errors.Add(new(ProductValidationErrorCodes.MissingColdBaseCode, $"商品「{product.Name}」尺寸「{size.Name}」缺少 ColdBaseCode。"));
        }
        return errors;
    }
}
