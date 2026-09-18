namespace NorthStarOps.Application.Features.Support.OpenTickets.Contracts;

public sealed record OpenTicketDto(
    string TicketNumber,
    string Subject,
    string TicketStatus,
    string Priority);
