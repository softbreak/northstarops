using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class ToolExecution
{
    public long ToolExecutionId { get; set; }

    public long RunId { get; set; }

    public int SequenceNumber { get; set; }

    public string ToolName { get; set; } = null!;

    public string? ArgumentsJson { get; set; }

    public string? ResultJson { get; set; }

    public string ExecutionStatus { get; set; } = null!;

    public string? ErrorMessage { get; set; }

    public DateTime StartedAt { get; set; }

    public DateTime? CompletedAt { get; set; }

    public virtual Run Run { get; set; } = null!;
}
