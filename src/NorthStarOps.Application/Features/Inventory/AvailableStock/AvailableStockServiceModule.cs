using Microsoft.Extensions.DependencyInjection;
using NorthStarOps.Application.Modules;

namespace NorthStarOps.Application.Features.Inventory.AvailableStock;

public sealed class AvailableStockServiceModule : IServiceModule
{
    public void Register(IServiceCollection services)
    {
        services.AddSingleton<IAvailableStockCalculator, AvailableStockCalculator>();
    }
}
