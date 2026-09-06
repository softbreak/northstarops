using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class PurchaseReceipt
{
    public long PurchaseReceiptId { get; set; }

    public int PurchaseOrderId { get; set; }

    public int WarehouseId { get; set; }

    public string ReceiptNumber { get; set; } = null!;

    public string ReceiptStatus { get; set; } = null!;

    public DateTime ReceivedAt { get; set; }

    public string? Notes { get; set; }

    public virtual PurchaseOrder PurchaseOrder { get; set; } = null!;

    public virtual ICollection<PurchaseReceiptItem> PurchaseReceiptItems { get; set; } = new List<PurchaseReceiptItem>();

    public virtual Warehouse Warehouse { get; set; } = null!;
}
