using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using NorthStarOps.Api;
using NorthStarOps.Api.Features.Inventory.AvailableStock;
using NorthStarOps.Application;
using NorthStarOps.Application.Features.Inventory.AvailableStock;
using Xunit;

namespace NorthStarOps.Tests.Features.Inventory.AvailableStock;

public sealed class AvailableStockRegistrationTests
{
    [Fact]
    public void AddApplication_RegistersAvailableStockCalculator()
    {
        var services = new ServiceCollection();

        services.AddApplication(typeof(AvailableStockCalculator).Assembly);

        Assert.Contains(
            services,
            descriptor =>
                descriptor.ServiceType == typeof(IAvailableStockCalculator) &&
                descriptor.ImplementationType == typeof(AvailableStockCalculator));
    }

    [Fact]
    public void MapApplicationEndpoints_MapsAvailableStockEndpoint()
    {
        var builder = WebApplication.CreateBuilder();

        var app = builder.Build();

        app.MapApplicationEndpoints(
            typeof(AvailableStockEndpointModule).Assembly);

        var routeBuilder = (IEndpointRouteBuilder)app;

        var endpoint = routeBuilder.DataSources
            .SelectMany(dataSource => dataSource.Endpoints)
            .OfType<RouteEndpoint>()
            .SingleOrDefault(candidate =>
                candidate.RoutePattern.RawText ==
                AvailableStockEndpointModule.RoutePattern);

        Assert.NotNull(endpoint);

        var httpMethods = endpoint.Metadata
            .GetMetadata<IHttpMethodMetadata>();

        Assert.NotNull(httpMethods);
        Assert.Equal([HttpMethods.Get], httpMethods.HttpMethods);
    }
}
