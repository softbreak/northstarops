using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class Run1
{
    public long EvaluationRunId { get; set; }

    public Guid CorrelationId { get; set; }

    public string RunName { get; set; } = null!;

    public string RunStatus { get; set; } = null!;

    public DateTime StartedAt { get; set; }

    public DateTime? CompletedAt { get; set; }

    public virtual ICollection<Result> Results { get; set; } = new List<Result>();
}
