using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using NorthStarOps.Api;
using NorthStarOps.Api.Features.Support.OpenTickets;
using NorthStarOps.Application.Features.Support.OpenTickets.Contracts;
using NorthStarOps.Application.Features.Support.OpenTickets.Services;
using NorthStarOps.Persistence.Database.Models;
using Xunit;

namespace NorthStarOps.Tests.Features.Support.OpenTickets;

public sealed class OpenTicketsEndpointTests
{
    private static Ticket OpenTicket(string number, DateTime createdAt) => new()
    {
        CustomerId = 1,
        TicketNumber = number,
        Subject = $"Subject {number}",
        TicketStatus = "Open",
        Priority = "High",
        CreatedAt = createdAt,
        ClosedAt = null,
    };

    private static Ticket ClosedTicket(string number, DateTime createdAt) => new()
    {
        CustomerId = 1,
        TicketNumber = number,
        Subject = $"Subject {number}",
        TicketStatus = "Closed",
        Priority = "Low",
        CreatedAt = createdAt,
        ClosedAt = createdAt.AddDays(1),
    };

    [Fact]
    public void ApplyOpenFilter_IncludesTicketsWithNullClosedAt()
    {
        var tickets = new[]
        {
            OpenTicket("T-001", new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)),
        }.AsQueryable();

        var result = OpenTicketsEndpoint.ApplyOpenFilter(tickets).ToList();

        Assert.Single(result);
        Assert.Equal("T-001", result[0].TicketNumber);
    }

    [Fact]
    public void ApplyOpenFilter_ExcludesTicketsWithClosedAt()
    {
        var tickets = new[]
        {
            ClosedTicket("T-999", new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)),
        }.AsQueryable();

        var result = OpenTicketsEndpoint.ApplyOpenFilter(tickets).ToList();

        Assert.Empty(result);
    }

    [Fact]
    public void ApplyNewestFirstOrdering_SortsByCreatedAtDescending()
    {
        var tickets = new[]
        {
            OpenTicket("T-OLD", new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)),
            OpenTicket("T-NEW", new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc)),
            OpenTicket("T-MID", new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc)),
        }.AsQueryable();

        var result = OpenTicketsEndpoint.ApplyNewestFirstOrdering(tickets).ToList();

        Assert.Equal(["T-NEW", "T-MID", "T-OLD"], result.Select(ticket => ticket.TicketNumber));
    }

    [Fact]
    public void OpenFlow_FilterPlusService_ReturnsOnlyOpenTicketsWithRequiredFieldsOrderedNewestFirst()
    {
        var tickets = new[]
        {
            OpenTicket("T-OLD", new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)),
            ClosedTicket("T-CLOSED", new DateTime(2026, 4, 1, 0, 0, 0, DateTimeKind.Utc)),
            OpenTicket("T-NEW", new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc)),
        }.AsQueryable();

        var filtered = OpenTicketsEndpoint
            .ApplyNewestFirstOrdering(OpenTicketsEndpoint.ApplyOpenFilter(tickets))
            .Select(ticket => new OpenTicketData(
                ticket.TicketNumber,
                ticket.Subject,
                ticket.TicketStatus,
                ticket.Priority,
                ticket.CreatedAt))
            .ToList();

        IOpenTicketsService service = new OpenTicketsService();
        var result = service.OrderByNewestFirst(filtered);

        Assert.Equal(2, result.Count);
        Assert.DoesNotContain(result, item => item.TicketNumber == "T-CLOSED");
        Assert.Equal(["T-NEW", "T-OLD"], result.Select(item => item.TicketNumber));

        foreach (var item in result)
        {
            Assert.False(string.IsNullOrWhiteSpace(item.TicketNumber));
            Assert.False(string.IsNullOrWhiteSpace(item.Subject));
            Assert.False(string.IsNullOrWhiteSpace(item.TicketStatus));
            Assert.False(string.IsNullOrWhiteSpace(item.Priority));
        }
    }

    [Fact]
    public void OpenFlow_NoOpenTickets_ReturnsEmptyList()
    {
        var tickets = new[]
        {
            ClosedTicket("T-1", new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)),
        }.AsQueryable();

        var filtered = OpenTicketsEndpoint.ApplyOpenFilter(tickets)
            .Select(ticket => new OpenTicketData(
                ticket.TicketNumber,
                ticket.Subject,
                ticket.TicketStatus,
                ticket.Priority,
                ticket.CreatedAt))
            .ToList();

        IOpenTicketsService service = new OpenTicketsService();
        var result = service.OrderByNewestFirst(filtered);

        Assert.NotNull(result);
        Assert.Empty(result);
    }

    [Fact]
    public void MapEndpoints_RegistersOpenTicketsRoute()
    {
        var builder = WebApplication.CreateBuilder();
        builder.Services.AddScoped<IOpenTicketsService, OpenTicketsService>();
        var app = builder.Build();

        app.MapApplicationEndpoints(typeof(OpenTicketsEndpoint).Assembly);

        var routeEndpoints = ((IEndpointRouteBuilder)app).DataSources
            .SelectMany(dataSource => dataSource.Endpoints)
            .OfType<RouteEndpoint>();

        Assert.Contains(
            routeEndpoints,
            endpoint =>
                string.Equals(endpoint.RoutePattern.RawText, "/api/support/tickets/open", StringComparison.Ordinal) &&
                endpoint.Metadata.GetMetadata<HttpMethodMetadata>()?.HttpMethods
                    .Contains(HttpMethods.Get, StringComparer.OrdinalIgnoreCase) == true);
    }
}
