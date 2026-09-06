using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class EmployeeDepartment
{
    public int EmployeeId { get; set; }

    public int DepartmentId { get; set; }

    public bool IsPrimary { get; set; }

    public DateOnly AssignedFrom { get; set; }

    public DateOnly? AssignedTo { get; set; }

    public virtual Department Department { get; set; } = null!;

    public virtual Employee Employee { get; set; } = null!;
}
