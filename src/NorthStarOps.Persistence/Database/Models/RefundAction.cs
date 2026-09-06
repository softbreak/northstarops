using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class RefundAction
{
    public int RefundActionId { get; set; }

    public int RefundRequestId { get; set; }

    public string ActionType { get; set; } = null!;

    public string ActorType { get; set; } = null!;

    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual RefundRequest RefundRequest { get; set; } = null!;
}
