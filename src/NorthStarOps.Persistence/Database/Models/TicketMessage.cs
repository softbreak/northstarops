using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class TicketMessage
{
    public int TicketMessageId { get; set; }

    public int TicketId { get; set; }

    public string SenderType { get; set; } = null!;

    public string MessageText { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public virtual Ticket Ticket { get; set; } = null!;
}
