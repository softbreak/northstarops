using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class SupplierProduct
{
    public int SupplierProductId { get; set; }

    public int SupplierId { get; set; }

    public int ProductId { get; set; }

    public string? SupplierProductCode { get; set; }

    public decimal UnitCost { get; set; }

    public int? LeadTimeDays { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Product Product { get; set; } = null!;

    public virtual Supplier Supplier { get; set; } = null!;
}
