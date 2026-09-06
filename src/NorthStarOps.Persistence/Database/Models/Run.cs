using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class Run
{
    public long RunId { get; set; }

    public Guid CorrelationId { get; set; }

    public string Provider { get; set; } = null!;

    public string ModelName { get; set; } = null!;

    public string Purpose { get; set; } = null!;

    public string RunStatus { get; set; } = null!;

    public int? InputTokens { get; set; }

    public int? OutputTokens { get; set; }

    public decimal? CostUsd { get; set; }

    public int? LatencyMs { get; set; }

    public string? ErrorMessage { get; set; }

    public DateTime StartedAt { get; set; }

    public DateTime? CompletedAt { get; set; }

    public virtual ICollection<AuditEvent> AuditEvents { get; set; } = new List<AuditEvent>();

    public virtual ICollection<Message> Messages { get; set; } = new List<Message>();

    public virtual ICollection<Result> Results { get; set; } = new List<Result>();

    public virtual ICollection<Retrieval> Retrievals { get; set; } = new List<Retrieval>();

    public virtual ICollection<ToolExecution> ToolExecutions { get; set; } = new List<ToolExecution>();
}
