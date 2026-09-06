using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class Result
{
    public long EvaluationResultId { get; set; }

    public long EvaluationRunId { get; set; }

    public int EvaluationCaseId { get; set; }

    public long? AirunId { get; set; }

    public bool Passed { get; set; }

    public decimal? Score { get; set; }

    public string? ActualOutcome { get; set; }

    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Run? Airun { get; set; }

    public virtual Case EvaluationCase { get; set; } = null!;

    public virtual Run1 EvaluationRun { get; set; } = null!;
}
