using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class CustomerAddress
{
    public int CustomerAddressId { get; set; }

    public int CustomerId { get; set; }

    public string AddressType { get; set; } = null!;

    public string AddressLine { get; set; } = null!;

    public string City { get; set; } = null!;

    public string? StateProvince { get; set; }

    public string? PostalCode { get; set; }

    public string Country { get; set; } = null!;

    public bool IsDefault { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Customer Customer { get; set; } = null!;
}
