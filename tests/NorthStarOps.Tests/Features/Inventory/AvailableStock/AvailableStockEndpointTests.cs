using System.Linq.Expressions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;
using NorthStarOps.Api.Features.Inventory.AvailableStock;
using NorthStarOps.Application.Features.Inventory.AvailableStock;
using NorthStarOps.Persistence.Database;
using Xunit;

namespace NorthStarOps.Tests.Features.Inventory.AvailableStock;

public sealed class AvailableStockEndpointTests
{
    [Fact]
    public void BuildResult_ReturnsNotFound_WhenStockLevelIsMissing()
    {
        var result = AvailableStockEndpoint.BuildResult(
            quantities: null,
            calculator: new AvailableStockCalculator());

        Assert.IsType<NotFound>(result);

        var statusCodeResult = Assert.IsAssignableFrom<IStatusCodeHttpResult>(result);

        Assert.Equal(StatusCodes.Status404NotFound, statusCodeResult.StatusCode);
    }

    [Fact]
    public void BuildResult_ReturnsAvailableStock_WhenStockLevelExists()
    {
        var result = AvailableStockEndpoint.BuildResult(
            new StockQuantities(QuantityOnHand: 10, QuantityReserved: 3),
            new AvailableStockCalculator());

        var okResult = Assert.IsType<Ok<AvailableStockResult>>(result);
        var value = Assert.IsType<AvailableStockResult>(okResult.Value);

        Assert.Equal(10, value.QuantityOnHand);
        Assert.Equal(3, value.QuantityReserved);
        Assert.Equal(7, value.AvailableQuantity);
    }

    [Fact]
    public void BuildQuery_UsesAsNoTracking()
    {
        using var dbContext = CreateDbContext();

        var query = AvailableStockEndpoint.BuildQuery(
            dbContext,
            warehouseId: 1,
            productId: 2);

        var visitor = new AsNoTrackingVisitor();

        visitor.Visit(query.Expression);

        Assert.True(
            visitor.FoundAsNoTracking,
            "Sorgu AsNoTracking() kullanmalı.");
    }

    private static NorthStarOpsDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<NorthStarOpsDbContext>()
            .UseSqlServer(
                "Server=test-server;" +
                "Database=test-database;" +
                "User Id=test-user;" +
                "Password=test-password;")
            .Options;

        return new NorthStarOpsDbContext(options);
    }

    private sealed class AsNoTrackingVisitor : ExpressionVisitor
    {
        public bool FoundAsNoTracking { get; private set; }

        protected override Expression VisitMethodCall(MethodCallExpression node)
        {
            if (node.Method.DeclaringType == typeof(EntityFrameworkQueryableExtensions) &&
                node.Method.Name == nameof(EntityFrameworkQueryableExtensions.AsNoTracking))
            {
                FoundAsNoTracking = true;
            }

            return base.VisitMethodCall(node);
        }
    }
}
