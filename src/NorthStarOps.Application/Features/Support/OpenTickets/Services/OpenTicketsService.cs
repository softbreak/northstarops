using NorthStarOps.Application.Features.Support.OpenTickets.Contracts;

namespace NorthStarOps.Application.Features.Support.OpenTickets.Services;

public sealed class OpenTicketsService : IOpenTicketsService
{
    public IReadOnlyList<OpenTicketDto> OrderByNewestFirst(IEnumerable<OpenTicketData> tickets)
    {
        ArgumentNullException.ThrowIfNull(tickets);

        return tickets
            .OrderByDescending(ticket => ticket.CreatedAt)
            .Select(ticket => new OpenTicketDto(
                ticket.TicketNumber,
                ticket.Subject,
                ticket.TicketStatus,
                ticket.Priority))
            .ToList();
    }
}
