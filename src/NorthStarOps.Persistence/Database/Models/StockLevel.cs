using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class StockLevel
{
    public int WarehouseId { get; set; }

    public int ProductId { get; set; }

    public int QuantityOnHand { get; set; }

    public int QuantityReserved { get; set; }

    public DateTime UpdatedAt { get; set; }

    public virtual Product Product { get; set; } = null!;

    public virtual Warehouse Warehouse { get; set; } = null!;
}
