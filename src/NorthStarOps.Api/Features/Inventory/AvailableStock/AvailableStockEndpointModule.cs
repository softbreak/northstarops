using NorthStarOps.Api.Modules;

namespace NorthStarOps.Api.Features.Inventory.AvailableStock;

public sealed class AvailableStockEndpointModule : IEndpointModule
{
    public const string RoutePattern =
        "/api/inventory/available-stock/{warehouseId:int}/{productId:int}";

    public void MapEndpoints(IEndpointRouteBuilder endpoints)
    {
        endpoints.MapGet(RoutePattern, AvailableStockEndpoint.HandleAsync);
    }
}
