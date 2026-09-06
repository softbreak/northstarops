using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class RefundRequest
{
    public int RefundRequestId { get; set; }

    public int OrderId { get; set; }

    public string RequestNumber { get; set; } = null!;

    public string Reason { get; set; } = null!;

    public decimal RequestedAmount { get; set; }

    public string RequestStatus { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? ResolvedAt { get; set; }

    public virtual ICollection<HumanApproval> HumanApprovals { get; set; } = new List<HumanApproval>();

    public virtual Order Order { get; set; } = null!;

    public virtual ICollection<RefundAction> RefundActions { get; set; } = new List<RefundAction>();
}
