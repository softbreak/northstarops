using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class ShipmentItem
{
    public long ShipmentItemId { get; set; }

    public long ShipmentId { get; set; }

    public int OrderItemId { get; set; }

    public int Quantity { get; set; }

    public virtual OrderItem OrderItem { get; set; } = null!;

    public virtual Shipment Shipment { get; set; } = null!;
}
