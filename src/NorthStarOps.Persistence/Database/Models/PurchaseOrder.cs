using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class PurchaseOrder
{
    public int PurchaseOrderId { get; set; }

    public int SupplierId { get; set; }

    public int EmployeeId { get; set; }

    public string PurchaseOrderNumber { get; set; } = null!;

    public string OrderStatus { get; set; } = null!;

    public DateTime OrderedAt { get; set; }

    public DateTime? ExpectedAt { get; set; }

    public decimal TotalAmount { get; set; }

    public virtual Employee Employee { get; set; } = null!;

    public virtual ICollection<PurchaseOrderItem> PurchaseOrderItems { get; set; } = new List<PurchaseOrderItem>();

    public virtual ICollection<PurchaseReceipt> PurchaseReceipts { get; set; } = new List<PurchaseReceipt>();

    public virtual Supplier Supplier { get; set; } = null!;
}
