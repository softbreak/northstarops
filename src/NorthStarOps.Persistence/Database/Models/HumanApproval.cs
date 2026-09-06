using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class HumanApproval
{
    public long HumanApprovalId { get; set; }

    public int RefundRequestId { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public int? ReviewedByEmployeeId { get; set; }

    public string? DecisionNotes { get; set; }

    public DateTime RequestedAt { get; set; }

    public DateTime? ReviewedAt { get; set; }

    public virtual RefundRequest RefundRequest { get; set; } = null!;

    public virtual Employee? ReviewedByEmployee { get; set; }
}
