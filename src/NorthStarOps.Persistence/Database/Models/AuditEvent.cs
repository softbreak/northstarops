using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class AuditEvent
{
    public long AuditEventId { get; set; }

    public string ActorType { get; set; } = null!;

    public string? ActorUserId { get; set; }

    public long? AirunId { get; set; }

    public string EventType { get; set; } = null!;

    public string? EntityType { get; set; }

    public long? EntityId { get; set; }

    public string? DetailsJson { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Run? Airun { get; set; }
}
