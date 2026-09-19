namespace NorthStarOps.Application.Features.Inventory.AvailableStock;

public sealed record AvailableStockResult(
    int QuantityOnHand,
    int QuantityReserved,
    int AvailableQuantity);
