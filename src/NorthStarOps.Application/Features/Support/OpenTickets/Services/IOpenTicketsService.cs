using NorthStarOps.Application.Features.Support.OpenTickets.Contracts;

namespace NorthStarOps.Application.Features.Support.OpenTickets.Services;

public interface IOpenTicketsService
{
    IReadOnlyList<OpenTicketDto> OrderByNewestFirst(IEnumerable<OpenTicketData> tickets);
}
