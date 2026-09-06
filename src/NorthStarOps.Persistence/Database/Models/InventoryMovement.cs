using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class InventoryMovement
{
    public long InventoryMovementId { get; set; }

    public int WarehouseId { get; set; }

    public int ProductId { get; set; }

    public string MovementType { get; set; } = null!;

    public int QuantityOnHandChange { get; set; }

    public int QuantityReservedChange { get; set; }

    public string? ReferenceType { get; set; }

    public long? ReferenceId { get; set; }

    public string? Notes { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Product Product { get; set; } = null!;

    public virtual Warehouse Warehouse { get; set; } = null!;
}
