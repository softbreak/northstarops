using NorthStarOps.Application.Features.Inventory.AvailableStock;
using Xunit;

namespace NorthStarOps.Tests.Features.Inventory.AvailableStock;

public sealed class AvailableStockCalculatorTests
{
    [Fact]
    public void Calculate_SubtractsReservedQuantityFromQuantityOnHand()
    {
        var calculator = new AvailableStockCalculator();

        var result = calculator.Calculate(
            quantityOnHand: 10,
            quantityReserved: 3);

        Assert.Equal(10, result.QuantityOnHand);
        Assert.Equal(3, result.QuantityReserved);
        Assert.Equal(7, result.AvailableQuantity);
    }

    [Fact]
    public void Calculate_ReturnsQuantityOnHand_WhenNothingIsReserved()
    {
        var calculator = new AvailableStockCalculator();

        var result = calculator.Calculate(
            quantityOnHand: 10,
            quantityReserved: 0);

        Assert.Equal(10, result.QuantityOnHand);
        Assert.Equal(0, result.QuantityReserved);
        Assert.Equal(result.QuantityOnHand, result.AvailableQuantity);
    }
}
