using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class PurchaseReceiptItem
{
    public long PurchaseReceiptItemId { get; set; }

    public long PurchaseReceiptId { get; set; }

    public int PurchaseOrderItemId { get; set; }

    public int QuantityReceived { get; set; }

    public int QuantityRejected { get; set; }

    public virtual PurchaseOrderItem PurchaseOrderItem { get; set; } = null!;

    public virtual PurchaseReceipt PurchaseReceipt { get; set; } = null!;
}
