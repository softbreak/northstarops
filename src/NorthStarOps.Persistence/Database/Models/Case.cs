using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class Case
{
    public int EvaluationCaseId { get; set; }

    public string CaseCode { get; set; } = null!;

    public string CaseName { get; set; } = null!;

    public string EvaluationType { get; set; } = null!;

    public string InputText { get; set; } = null!;

    public string ExpectedOutcome { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<Result> Results { get; set; } = new List<Result>();
}
