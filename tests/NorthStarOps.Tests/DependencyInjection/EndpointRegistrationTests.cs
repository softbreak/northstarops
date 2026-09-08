using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using NorthStarOps.Api;
using NorthStarOps.Api.Modules;
using Xunit;

namespace NorthStarOps.Tests.DependencyInjection;

public sealed class EndpointRegistrationTests
{
    [Fact]
    public void MapApplicationEndpoints_MapsDiscoveredEndpointModules()
    {
        var builder = WebApplication.CreateBuilder();

        var app = builder.Build();

        app.MapApplicationEndpoints(
            typeof(EndpointRegistrationTests).Assembly);

        var routeBuilder = (IEndpointRouteBuilder)app;

        var endpoints = routeBuilder.DataSources
            .SelectMany(dataSource => dataSource.Endpoints);

        Assert.Contains(
            endpoints,
            endpoint => endpoint.DisplayName == "Test endpoint");
    }

    private sealed class TestEndpointModule : IEndpointModule
    {
        public void MapEndpoints(IEndpointRouteBuilder endpoints)
        {
            endpoints
                .MapGet("/test-endpoint", () => Results.Ok())
                .WithDisplayName("Test endpoint");
        }
    }
}