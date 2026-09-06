using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class CustomerContact
{
    public int CustomerContactId { get; set; }

    public int CustomerId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string? JobTitle { get; set; }

    public string? Email { get; set; }

    public string? Phone { get; set; }

    public bool IsPrimary { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Customer Customer { get; set; } = null!;
}
