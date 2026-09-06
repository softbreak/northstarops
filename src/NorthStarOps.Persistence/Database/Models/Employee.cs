using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class Employee
{
    public int EmployeeId { get; set; }

    public string EmployeeCode { get; set; } = null!;

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string JobTitle { get; set; } = null!;

    public int? ManagerEmployeeId { get; set; }

    public DateOnly HireDate { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<EmployeeDepartment> EmployeeDepartments { get; set; } = new List<EmployeeDepartment>();

    public virtual ICollection<HumanApproval> HumanApprovals { get; set; } = new List<HumanApproval>();

    public virtual ICollection<Employee> InverseManagerEmployee { get; set; } = new List<Employee>();

    public virtual Employee? ManagerEmployee { get; set; }

    public virtual ICollection<PurchaseOrder> PurchaseOrders { get; set; } = new List<PurchaseOrder>();
}
