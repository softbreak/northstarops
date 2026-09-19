namespace NorthStarOps.Application.Features.Inventory.AvailableStock;

public interface IAvailableStockCalculator
{
    AvailableStockResult Calculate(int quantityOnHand, int quantityReserved);
}
