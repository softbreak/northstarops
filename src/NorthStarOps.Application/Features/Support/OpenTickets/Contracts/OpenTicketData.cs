namespace NorthStarOps.Application.Features.Support.OpenTickets.Contracts;

public sealed record OpenTicketData(
    string TicketNumber,
    string Subject,
    string TicketStatus,
    string Priority,
    DateTime CreatedAt);
