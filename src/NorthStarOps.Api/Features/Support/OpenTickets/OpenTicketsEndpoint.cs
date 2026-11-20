using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NorthStarOps.Api.Modules;
using NorthStarOps.Application.Features.Support.OpenTickets.Contracts;
using NorthStarOps.Application.Features.Support.OpenTickets.Services;
using NorthStarOps.Persistence.Database;
using NorthStarOps.Persistence.Database.Models;

namespace NorthStarOps.Api.Features.Support.OpenTickets;

public sealed class OpenTicketsEndpoint : IEndpointModule
{
    public void MapEndpoints(IEndpointRouteBuilder endpoints)
    {
        endpoints.MapGet("/api/support/tickets/open", HandleAsync);
    }

    public static async Task<IResult> HandleAsync(
        [FromServices] NorthStarOpsDbContext db,
        [FromServices] IOpenTicketsService service,
        CancellationToken cancellationToken)
    {
        var rows = await ApplyNewestFirstOrdering(ApplyOpenFilter(db.Tickets.AsNoTracking()))
            .Select(ticket => new OpenTicketData(
                ticket.TicketNumber,
                ticket.Subject,
                ticket.TicketStatus,
                ticket.Priority,
                ticket.CreatedAt))
            .ToListAsync(cancellationToken);

        var result = service.OrderByNewestFirst(rows);

        return Results.Ok(result);
    }

    public static IQueryable<Ticket> ApplyOpenFilter(IQueryable<Ticket> query)
    {
        ArgumentNullException.ThrowIfNull(query);

        return query.Where(ticket => ticket.ClosedAt == null);
    }

    public static IQueryable<Ticket> ApplyNewestFirstOrdering(IQueryable<Ticket> query)
    {
        ArgumentNullException.ThrowIfNull(query);

        return query.OrderByDescending(ticket => ticket.CreatedAt);
    }
}
