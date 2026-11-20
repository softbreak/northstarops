namespace NorthStarOps.Application.Features.Inventory.AvailableStock;

public sealed class AvailableStockCalculator : IAvailableStockCalculator
{
    public AvailableStockResult Calculate(int quantityOnHand, int quantityReserved)
    {
        return new AvailableStockResult(
            quantityOnHand,
            quantityReserved,
            quantityOnHand - quantityReserved);
    }
}
