using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class Shipment
{
    public long ShipmentId { get; set; }

    public int OrderId { get; set; }

    public int WarehouseId { get; set; }

    public string ShipmentNumber { get; set; } = null!;

    public string ShipmentStatus { get; set; } = null!;

    public string? CarrierName { get; set; }

    public string? TrackingNumber { get; set; }

    public DateTime? ShippedAt { get; set; }

    public DateTime? EstimatedDeliveryAt { get; set; }

    public DateTime? DeliveredAt { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Order Order { get; set; } = null!;

    public virtual ICollection<ShipmentItem> ShipmentItems { get; set; } = new List<ShipmentItem>();

    public virtual Warehouse Warehouse { get; set; } = null!;
}
