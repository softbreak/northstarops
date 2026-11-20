using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NorthStarOps.Application.Features.Inventory.AvailableStock;
using NorthStarOps.Persistence.Database;

namespace NorthStarOps.Api.Features.Inventory.AvailableStock;

public static class AvailableStockEndpoint
{
    public static async Task<IResult> HandleAsync(
        int warehouseId,
        int productId,
        [FromServices] NorthStarOpsDbContext dbContext,
        [FromServices] IAvailableStockCalculator calculator,
        CancellationToken cancellationToken)
    {
        var quantities = await BuildQuery(dbContext, warehouseId, productId)
            .FirstOrDefaultAsync(cancellationToken);

        return BuildResult(quantities, calculator);
    }

    public static IQueryable<StockQuantities> BuildQuery(
        NorthStarOpsDbContext dbContext,
        int warehouseId,
        int productId)
    {
        return dbContext.StockLevels
            .AsNoTracking()
            .Where(stockLevel =>
                stockLevel.WarehouseId == warehouseId &&
                stockLevel.ProductId == productId)
            .Select(stockLevel => new StockQuantities(
                stockLevel.QuantityOnHand,
                stockLevel.QuantityReserved));
    }

    public static IResult BuildResult(
        StockQuantities? quantities,
        IAvailableStockCalculator calculator)
    {
        if (quantities is null)
        {
            return Results.NotFound();
        }

        return Results.Ok(calculator.Calculate(
            quantities.QuantityOnHand,
            quantities.QuantityReserved));
    }
}

public sealed record StockQuantities(int QuantityOnHand, int QuantityReserved);
