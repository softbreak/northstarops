using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using NorthStarOps.Persistence.Database.Models;

namespace NorthStarOps.Persistence.Database;

public partial class NorthStarOpsDbContext : DbContext
{
    public NorthStarOpsDbContext(DbContextOptions<NorthStarOpsDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AuditEvent> AuditEvents { get; set; }

    public virtual DbSet<Case> Cases { get; set; }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<Customer> Customers { get; set; }

    public virtual DbSet<CustomerAddress> CustomerAddresses { get; set; }

    public virtual DbSet<CustomerContact> CustomerContacts { get; set; }

    public virtual DbSet<Department> Departments { get; set; }

    public virtual DbSet<Document> Documents { get; set; }

    public virtual DbSet<DocumentChunk> DocumentChunks { get; set; }

    public virtual DbSet<DocumentVersion> DocumentVersions { get; set; }

    public virtual DbSet<Employee> Employees { get; set; }

    public virtual DbSet<EmployeeDepartment> EmployeeDepartments { get; set; }

    public virtual DbSet<HumanApproval> HumanApprovals { get; set; }

    public virtual DbSet<InventoryMovement> InventoryMovements { get; set; }

    public virtual DbSet<Message> Messages { get; set; }

    public virtual DbSet<Order> Orders { get; set; }

    public virtual DbSet<OrderItem> OrderItems { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<Product> Products { get; set; }

    public virtual DbSet<PurchaseOrder> PurchaseOrders { get; set; }

    public virtual DbSet<PurchaseOrderItem> PurchaseOrderItems { get; set; }

    public virtual DbSet<PurchaseReceipt> PurchaseReceipts { get; set; }

    public virtual DbSet<PurchaseReceiptItem> PurchaseReceiptItems { get; set; }

    public virtual DbSet<RefundAction> RefundActions { get; set; }

    public virtual DbSet<RefundRequest> RefundRequests { get; set; }

    public virtual DbSet<Result> Results { get; set; }

    public virtual DbSet<Retrieval> Retrievals { get; set; }

    public virtual DbSet<Run> Runs { get; set; }

    public virtual DbSet<Run1> Runs1 { get; set; }

    public virtual DbSet<Shipment> Shipments { get; set; }

    public virtual DbSet<ShipmentItem> ShipmentItems { get; set; }

    public virtual DbSet<StockLevel> StockLevels { get; set; }

    public virtual DbSet<Supplier> Suppliers { get; set; }

    public virtual DbSet<SupplierProduct> SupplierProducts { get; set; }

    public virtual DbSet<Ticket> Tickets { get; set; }

    public virtual DbSet<TicketMessage> TicketMessages { get; set; }

    public virtual DbSet<ToolExecution> ToolExecutions { get; set; }

    public virtual DbSet<Warehouse> Warehouses { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AuditEvent>(entity =>
        {
            entity.ToTable("AuditEvents", "Governance");

            entity.HasIndex(e => e.AirunId, "IX_AuditEvents_AIRunId").HasFilter("([AIRunId] IS NOT NULL)");

            entity.HasIndex(e => new { e.EntityType, e.EntityId, e.CreatedAt }, "IX_AuditEvents_Entity").IsDescending(false, false, true);

            entity.Property(e => e.ActorType)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.ActorUserId).HasMaxLength(450);
            entity.Property(e => e.AirunId).HasColumnName("AIRunId");
            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_AuditEvents_CreatedAt");
            entity.Property(e => e.EntityType)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.EventType)
                .HasMaxLength(100)
                .IsUnicode(false);

            entity.HasOne(d => d.Airun).WithMany(p => p.AuditEvents)
                .HasForeignKey(d => d.AirunId)
                .HasConstraintName("FK_AuditEvents_AIRuns");
        });

        modelBuilder.Entity<Case>(entity =>
        {
            entity.HasKey(e => e.EvaluationCaseId).HasName("PK_EvaluationCases");

            entity.ToTable("Cases", "Evaluation");

            entity.HasIndex(e => new { e.EvaluationType, e.IsActive }, "IX_EvaluationCases_Type_IsActive");

            entity.HasIndex(e => e.CaseCode, "UQ_EvaluationCases_CaseCode").IsUnique();

            entity.Property(e => e.CaseCode)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.CaseName).HasMaxLength(200);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_EvaluationCases_CreatedAt");
            entity.Property(e => e.EvaluationType)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_EvaluationCases_IsActive");
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.ToTable("Categories", "Catalog");

            entity.HasIndex(e => e.CategoryName, "UQ_Categories_CategoryName").IsUnique();

            entity.Property(e => e.CategoryName).HasMaxLength(150);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Categories_CreatedAt");
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Categories_IsActive");
        });

        modelBuilder.Entity<Customer>(entity =>
        {
            entity.ToTable("Customers", "Sales");

            entity.HasIndex(e => e.CustomerCode, "UQ_Customers_CustomerCode").IsUnique();

            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.CompanyName).HasMaxLength(200);
            entity.Property(e => e.ContactName).HasMaxLength(150);
            entity.Property(e => e.Country).HasMaxLength(100);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Customers_CreatedAt");
            entity.Property(e => e.CustomerCode)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.Email)
                .HasMaxLength(320)
                .IsUnicode(false);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Customers_IsActive");
            entity.Property(e => e.Phone)
                .HasMaxLength(30)
                .IsUnicode(false);
        });

        modelBuilder.Entity<CustomerAddress>(entity =>
        {
            entity.ToTable("CustomerAddresses", "Sales");

            entity.HasIndex(e => new { e.CustomerId, e.AddressType }, "IX_CustomerAddresses_CustomerId_AddressType");

            entity.Property(e => e.AddressLine).HasMaxLength(250);
            entity.Property(e => e.AddressType)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.Country).HasMaxLength(100);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_CustomerAddresses_CreatedAt");
            entity.Property(e => e.PostalCode)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.StateProvince).HasMaxLength(100);

            entity.HasOne(d => d.Customer).WithMany(p => p.CustomerAddresses)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_CustomerAddresses_Customers");
        });

        modelBuilder.Entity<CustomerContact>(entity =>
        {
            entity.ToTable("CustomerContacts", "Sales");

            entity.HasIndex(e => e.CustomerId, "IX_CustomerContacts_CustomerId");

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_CustomerContacts_CreatedAt");
            entity.Property(e => e.Email)
                .HasMaxLength(320)
                .IsUnicode(false);
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.JobTitle).HasMaxLength(150);
            entity.Property(e => e.LastName).HasMaxLength(100);
            entity.Property(e => e.Phone)
                .HasMaxLength(30)
                .IsUnicode(false);

            entity.HasOne(d => d.Customer).WithMany(p => p.CustomerContacts)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_CustomerContacts_Customers");
        });

        modelBuilder.Entity<Department>(entity =>
        {
            entity.ToTable("Departments", "Organization");

            entity.HasIndex(e => e.DepartmentCode, "UQ_Departments_DepartmentCode").IsUnique();

            entity.HasIndex(e => e.DepartmentName, "UQ_Departments_DepartmentName").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Departments_CreatedAt");
            entity.Property(e => e.DepartmentCode)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.DepartmentName).HasMaxLength(150);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Departments_IsActive");
        });

        modelBuilder.Entity<Document>(entity =>
        {
            entity.ToTable("Documents", "Knowledge");

            entity.HasIndex(e => new { e.DocumentType, e.IsActive }, "IX_Documents_DocumentType_IsActive");

            entity.HasIndex(e => e.DocumentCode, "UQ_Documents_DocumentCode").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Documents_CreatedAt");
            entity.Property(e => e.DocumentCode)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.DocumentType)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Documents_IsActive");
            entity.Property(e => e.Title).HasMaxLength(250);
        });

        modelBuilder.Entity<DocumentChunk>(entity =>
        {
            entity.ToTable("DocumentChunks", "Knowledge");

            entity.HasIndex(e => new { e.DocumentVersionId, e.ChunkIndex }, "UQ_DocumentChunks_Version_Index").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_DocumentChunks_CreatedAt");

            entity.HasOne(d => d.DocumentVersion).WithMany(p => p.DocumentChunks)
                .HasForeignKey(d => d.DocumentVersionId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_DocumentChunks_DocumentVersions");
        });

        modelBuilder.Entity<DocumentVersion>(entity =>
        {
            entity.ToTable("DocumentVersions", "Knowledge");

            entity.HasIndex(e => new { e.DocumentId, e.EffectiveFrom }, "IX_DocumentVersions_DocumentId_EffectiveFrom").IsDescending(false, true);

            entity.HasIndex(e => new { e.DocumentId, e.VersionNumber }, "UQ_DocumentVersions_Document_Version").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_DocumentVersions_CreatedAt");
            entity.Property(e => e.EffectiveFrom).HasPrecision(0);
            entity.Property(e => e.EffectiveTo).HasPrecision(0);

            entity.HasOne(d => d.Document).WithMany(p => p.DocumentVersions)
                .HasForeignKey(d => d.DocumentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_DocumentVersions_Documents");
        });

        modelBuilder.Entity<Employee>(entity =>
        {
            entity.ToTable("Employees", "Organization");

            entity.HasIndex(e => e.ManagerEmployeeId, "IX_Employees_ManagerEmployeeId");

            entity.HasIndex(e => e.Email, "UQ_Employees_Email").IsUnique();

            entity.HasIndex(e => e.EmployeeCode, "UQ_Employees_EmployeeCode").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Employees_CreatedAt");
            entity.Property(e => e.Email)
                .HasMaxLength(320)
                .IsUnicode(false);
            entity.Property(e => e.EmployeeCode)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Employees_IsActive");
            entity.Property(e => e.JobTitle).HasMaxLength(150);
            entity.Property(e => e.LastName).HasMaxLength(100);

            entity.HasOne(d => d.ManagerEmployee).WithMany(p => p.InverseManagerEmployee)
                .HasForeignKey(d => d.ManagerEmployeeId)
                .HasConstraintName("FK_Employees_Manager");
        });

        modelBuilder.Entity<EmployeeDepartment>(entity =>
        {
            entity.HasKey(e => new { e.EmployeeId, e.DepartmentId });

            entity.ToTable("EmployeeDepartments", "Organization");

            entity.HasIndex(e => e.DepartmentId, "IX_EmployeeDepartments_DepartmentId");

            entity.HasOne(d => d.Department).WithMany(p => p.EmployeeDepartments)
                .HasForeignKey(d => d.DepartmentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_EmployeeDepartments_Departments");

            entity.HasOne(d => d.Employee).WithMany(p => p.EmployeeDepartments)
                .HasForeignKey(d => d.EmployeeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_EmployeeDepartments_Employees");
        });

        modelBuilder.Entity<HumanApproval>(entity =>
        {
            entity.ToTable("HumanApprovals", "Governance");

            entity.HasIndex(e => new { e.RefundRequestId, e.RequestedAt }, "IX_HumanApprovals_RefundRequestId").IsDescending(false, true);

            entity.HasIndex(e => new { e.ReviewedByEmployeeId, e.ReviewedAt }, "IX_HumanApprovals_ReviewedByEmployeeId")
                .IsDescending(false, true)
                .HasFilter("([ReviewedByEmployeeId] IS NOT NULL)");

            entity.HasIndex(e => new { e.ApprovalStatus, e.RequestedAt }, "IX_HumanApprovals_Status_RequestedAt");

            entity.Property(e => e.ApprovalStatus)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.DecisionNotes).HasMaxLength(2000);
            entity.Property(e => e.RequestedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_HumanApprovals_RequestedAt");
            entity.Property(e => e.ReviewedAt).HasPrecision(3);

            entity.HasOne(d => d.RefundRequest).WithMany(p => p.HumanApprovals)
                .HasForeignKey(d => d.RefundRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_HumanApprovals_RefundRequests");

            entity.HasOne(d => d.ReviewedByEmployee).WithMany(p => p.HumanApprovals)
                .HasForeignKey(d => d.ReviewedByEmployeeId)
                .HasConstraintName("FK_HumanApprovals_Employees");
        });

        modelBuilder.Entity<InventoryMovement>(entity =>
        {
            entity.ToTable("InventoryMovements", "Inventory");

            entity.HasIndex(e => new { e.ProductId, e.CreatedAt }, "IX_InventoryMovements_ProductId_CreatedAt").IsDescending(false, true);

            entity.HasIndex(e => new { e.ReferenceType, e.ReferenceId }, "IX_InventoryMovements_Reference");

            entity.HasIndex(e => new { e.WarehouseId, e.CreatedAt }, "IX_InventoryMovements_WarehouseId_CreatedAt").IsDescending(false, true);

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_InventoryMovements_CreatedAt");
            entity.Property(e => e.MovementType)
                .HasMaxLength(40)
                .IsUnicode(false);
            entity.Property(e => e.Notes).HasMaxLength(1000);
            entity.Property(e => e.ReferenceType)
                .HasMaxLength(50)
                .IsUnicode(false);

            entity.HasOne(d => d.Product).WithMany(p => p.InventoryMovements)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_InventoryMovements_Products");

            entity.HasOne(d => d.Warehouse).WithMany(p => p.InventoryMovements)
                .HasForeignKey(d => d.WarehouseId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_InventoryMovements_Warehouses");
        });

        modelBuilder.Entity<Message>(entity =>
        {
            entity.HasKey(e => e.MessageId).HasName("PK_AIMessages");

            entity.ToTable("Messages", "AI");

            entity.HasIndex(e => new { e.RunId, e.SequenceNumber }, "UQ_AIMessages_Run_Sequence").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_AIMessages_CreatedAt");
            entity.Property(e => e.Role)
                .HasMaxLength(30)
                .IsUnicode(false);

            entity.HasOne(d => d.Run).WithMany(p => p.Messages)
                .HasForeignKey(d => d.RunId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AIMessages_Runs");
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.ToTable("Orders", "Sales");

            entity.HasIndex(e => new { e.CustomerId, e.OrderedAt }, "IX_Orders_CustomerId_OrderedAt").IsDescending(false, true);

            entity.HasIndex(e => e.OrderNumber, "UQ_Orders_OrderNumber").IsUnique();

            entity.Property(e => e.OrderNumber)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.OrderStatus)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.OrderedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Orders_OrderedAt");
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Customer).WithMany(p => p.Orders)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Orders_Customers");
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.ToTable("OrderItems", "Sales");

            entity.HasIndex(e => e.OrderId, "IX_OrderItems_OrderId");

            entity.HasIndex(e => e.ProductId, "IX_OrderItems_ProductId");

            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Order).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_OrderItems_Orders");

            entity.HasOne(d => d.Product).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_OrderItems_Products");
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.ToTable("Payments", "Sales");

            entity.HasIndex(e => e.OrderId, "IX_Payments_OrderId");

            entity.Property(e => e.Amount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Payments_CreatedAt");
            entity.Property(e => e.PaidAt).HasPrecision(0);
            entity.Property(e => e.PaymentMethod)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.PaymentStatus)
                .HasMaxLength(30)
                .IsUnicode(false);

            entity.HasOne(d => d.Order).WithMany(p => p.Payments)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Payments_Orders");
        });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.ToTable("Products", "Catalog");

            entity.HasIndex(e => e.CategoryId, "IX_Products_CategoryId");

            entity.HasIndex(e => e.ProductCode, "UQ_Products_ProductCode").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Products_CreatedAt");
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Products_IsActive");
            entity.Property(e => e.ProductCode)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.ProductName).HasMaxLength(200);
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Category).WithMany(p => p.Products)
                .HasForeignKey(d => d.CategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Products_Categories");
        });

        modelBuilder.Entity<PurchaseOrder>(entity =>
        {
            entity.ToTable("PurchaseOrders", "Procurement");

            entity.HasIndex(e => e.EmployeeId, "IX_PurchaseOrders_EmployeeId");

            entity.HasIndex(e => new { e.SupplierId, e.OrderedAt }, "IX_PurchaseOrders_SupplierId_OrderedAt").IsDescending(false, true);

            entity.HasIndex(e => e.PurchaseOrderNumber, "UQ_PurchaseOrders_Number").IsUnique();

            entity.Property(e => e.ExpectedAt).HasPrecision(0);
            entity.Property(e => e.OrderStatus)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.OrderedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_PurchaseOrders_OrderedAt");
            entity.Property(e => e.PurchaseOrderNumber)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Employee).WithMany(p => p.PurchaseOrders)
                .HasForeignKey(d => d.EmployeeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PurchaseOrders_Employees");

            entity.HasOne(d => d.Supplier).WithMany(p => p.PurchaseOrders)
                .HasForeignKey(d => d.SupplierId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PurchaseOrders_Suppliers");
        });

        modelBuilder.Entity<PurchaseOrderItem>(entity =>
        {
            entity.ToTable("PurchaseOrderItems", "Procurement");

            entity.HasIndex(e => e.ProductId, "IX_PurchaseOrderItems_ProductId");

            entity.HasIndex(e => e.PurchaseOrderId, "IX_PurchaseOrderItems_PurchaseOrderId");

            entity.Property(e => e.UnitCost).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Product).WithMany(p => p.PurchaseOrderItems)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PurchaseOrderItems_Products");

            entity.HasOne(d => d.PurchaseOrder).WithMany(p => p.PurchaseOrderItems)
                .HasForeignKey(d => d.PurchaseOrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PurchaseOrderItems_PurchaseOrders");
        });

        modelBuilder.Entity<PurchaseReceipt>(entity =>
        {
            entity.ToTable("PurchaseReceipts", "Procurement");

            entity.HasIndex(e => e.PurchaseOrderId, "IX_PurchaseReceipts_PurchaseOrderId");

            entity.HasIndex(e => new { e.WarehouseId, e.ReceivedAt }, "IX_PurchaseReceipts_WarehouseId_ReceivedAt").IsDescending(false, true);

            entity.HasIndex(e => e.ReceiptNumber, "UQ_PurchaseReceipts_ReceiptNumber").IsUnique();

            entity.Property(e => e.Notes).HasMaxLength(1000);
            entity.Property(e => e.ReceiptNumber)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.ReceiptStatus)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.ReceivedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_PurchaseReceipts_ReceivedAt");

            entity.HasOne(d => d.PurchaseOrder).WithMany(p => p.PurchaseReceipts)
                .HasForeignKey(d => d.PurchaseOrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PurchaseReceipts_PurchaseOrders");

            entity.HasOne(d => d.Warehouse).WithMany(p => p.PurchaseReceipts)
                .HasForeignKey(d => d.WarehouseId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PurchaseReceipts_Warehouses");
        });

        modelBuilder.Entity<PurchaseReceiptItem>(entity =>
        {
            entity.ToTable("PurchaseReceiptItems", "Procurement");

            entity.HasIndex(e => e.PurchaseOrderItemId, "IX_PurchaseReceiptItems_PurchaseOrderItemId");

            entity.HasOne(d => d.PurchaseOrderItem).WithMany(p => p.PurchaseReceiptItems)
                .HasForeignKey(d => d.PurchaseOrderItemId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PurchaseReceiptItems_PurchaseOrderItems");

            entity.HasOne(d => d.PurchaseReceipt).WithMany(p => p.PurchaseReceiptItems)
                .HasForeignKey(d => d.PurchaseReceiptId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PurchaseReceiptItems_PurchaseReceipts");
        });

        modelBuilder.Entity<RefundAction>(entity =>
        {
            entity.ToTable("RefundActions", "Operations");

            entity.HasIndex(e => new { e.RefundRequestId, e.CreatedAt }, "IX_RefundActions_RefundRequestId_CreatedAt");

            entity.Property(e => e.ActionType)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.ActorType)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_RefundActions_CreatedAt");
            entity.Property(e => e.Notes).HasMaxLength(1000);

            entity.HasOne(d => d.RefundRequest).WithMany(p => p.RefundActions)
                .HasForeignKey(d => d.RefundRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RefundActions_RefundRequests");
        });

        modelBuilder.Entity<RefundRequest>(entity =>
        {
            entity.ToTable("RefundRequests", "Operations");

            entity.HasIndex(e => new { e.OrderId, e.CreatedAt }, "IX_RefundRequests_OrderId_CreatedAt").IsDescending(false, true);

            entity.HasIndex(e => new { e.RequestStatus, e.CreatedAt }, "IX_RefundRequests_Status_CreatedAt").IsDescending(false, true);

            entity.HasIndex(e => e.RequestNumber, "UQ_RefundRequests_RequestNumber").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_RefundRequests_CreatedAt");
            entity.Property(e => e.Reason).HasMaxLength(1000);
            entity.Property(e => e.RequestNumber)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.RequestStatus)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.RequestedAmount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ResolvedAt).HasPrecision(0);

            entity.HasOne(d => d.Order).WithMany(p => p.RefundRequests)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RefundRequests_Orders");
        });

        modelBuilder.Entity<Result>(entity =>
        {
            entity.HasKey(e => e.EvaluationResultId).HasName("PK_EvaluationResults");

            entity.ToTable("Results", "Evaluation");

            entity.HasIndex(e => e.AirunId, "IX_EvaluationResults_AIRunId").HasFilter("([AIRunId] IS NOT NULL)");

            entity.HasIndex(e => new { e.EvaluationRunId, e.EvaluationCaseId }, "UQ_EvaluationResults_Run_Case").IsUnique();

            entity.Property(e => e.AirunId).HasColumnName("AIRunId");
            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_EvaluationResults_CreatedAt");
            entity.Property(e => e.Notes).HasMaxLength(2000);
            entity.Property(e => e.Score).HasColumnType("decimal(9, 6)");

            entity.HasOne(d => d.Airun).WithMany(p => p.Results)
                .HasForeignKey(d => d.AirunId)
                .HasConstraintName("FK_EvaluationResults_AIRuns");

            entity.HasOne(d => d.EvaluationCase).WithMany(p => p.Results)
                .HasForeignKey(d => d.EvaluationCaseId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_EvaluationResults_Cases");

            entity.HasOne(d => d.EvaluationRun).WithMany(p => p.Results)
                .HasForeignKey(d => d.EvaluationRunId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_EvaluationResults_Runs");
        });

        modelBuilder.Entity<Retrieval>(entity =>
        {
            entity.HasKey(e => e.RetrievalId).HasName("PK_AIRetrievals");

            entity.ToTable("Retrievals", "AI");

            entity.HasIndex(e => e.DocumentChunkId, "IX_AIRetrievals_DocumentChunkId");

            entity.HasIndex(e => new { e.RunId, e.RankPosition }, "IX_AIRetrievals_RunId_RankPosition");

            entity.HasIndex(e => new { e.RunId, e.DocumentChunkId }, "UQ_AIRetrievals_Run_Chunk").IsUnique();

            entity.Property(e => e.RetrievedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_AIRetrievals_RetrievedAt");
            entity.Property(e => e.Score).HasColumnType("decimal(18, 8)");

            entity.HasOne(d => d.DocumentChunk).WithMany(p => p.Retrievals)
                .HasForeignKey(d => d.DocumentChunkId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AIRetrievals_DocumentChunks");

            entity.HasOne(d => d.Run).WithMany(p => p.Retrievals)
                .HasForeignKey(d => d.RunId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AIRetrievals_Runs");
        });

        modelBuilder.Entity<Run>(entity =>
        {
            entity.HasKey(e => e.RunId).HasName("PK_AIRuns");

            entity.ToTable("Runs", "AI");

            entity.HasIndex(e => new { e.Purpose, e.StartedAt }, "IX_AIRuns_Purpose_StartedAt").IsDescending(false, true);

            entity.HasIndex(e => new { e.RunStatus, e.StartedAt }, "IX_AIRuns_RunStatus_StartedAt").IsDescending(false, true);

            entity.HasIndex(e => e.CorrelationId, "UQ_AIRuns_CorrelationId").IsUnique();

            entity.Property(e => e.CompletedAt).HasPrecision(3);
            entity.Property(e => e.CorrelationId).HasDefaultValueSql("(newid())", "DF_AIRuns_CorrelationId");
            entity.Property(e => e.CostUsd).HasColumnType("decimal(18, 6)");
            entity.Property(e => e.ErrorMessage).HasMaxLength(2000);
            entity.Property(e => e.ModelName)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Provider)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Purpose)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.RunStatus)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.StartedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_AIRuns_StartedAt");
        });

        modelBuilder.Entity<Run1>(entity =>
        {
            entity.HasKey(e => e.EvaluationRunId).HasName("PK_EvaluationRuns");

            entity.ToTable("Runs", "Evaluation");

            entity.HasIndex(e => e.StartedAt, "IX_EvaluationRuns_StartedAt").IsDescending();

            entity.HasIndex(e => e.CorrelationId, "UQ_EvaluationRuns_CorrelationId").IsUnique();

            entity.Property(e => e.CompletedAt).HasPrecision(3);
            entity.Property(e => e.CorrelationId).HasDefaultValueSql("(newid())", "DF_EvaluationRuns_CorrelationId");
            entity.Property(e => e.RunName).HasMaxLength(200);
            entity.Property(e => e.RunStatus)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.StartedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_EvaluationRuns_StartedAt");
        });

        modelBuilder.Entity<Shipment>(entity =>
        {
            entity.ToTable("Shipments", "Fulfillment");

            entity.HasIndex(e => e.OrderId, "IX_Shipments_OrderId");

            entity.HasIndex(e => e.TrackingNumber, "IX_Shipments_TrackingNumber").HasFilter("([TrackingNumber] IS NOT NULL)");

            entity.HasIndex(e => new { e.WarehouseId, e.CreatedAt }, "IX_Shipments_WarehouseId_CreatedAt").IsDescending(false, true);

            entity.HasIndex(e => e.ShipmentNumber, "UQ_Shipments_ShipmentNumber").IsUnique();

            entity.Property(e => e.CarrierName).HasMaxLength(150);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Shipments_CreatedAt");
            entity.Property(e => e.DeliveredAt).HasPrecision(3);
            entity.Property(e => e.EstimatedDeliveryAt).HasPrecision(3);
            entity.Property(e => e.ShipmentNumber)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.ShipmentStatus)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.ShippedAt).HasPrecision(3);
            entity.Property(e => e.TrackingNumber)
                .HasMaxLength(100)
                .IsUnicode(false);

            entity.HasOne(d => d.Order).WithMany(p => p.Shipments)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Shipments_Orders");

            entity.HasOne(d => d.Warehouse).WithMany(p => p.Shipments)
                .HasForeignKey(d => d.WarehouseId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Shipments_Warehouses");
        });

        modelBuilder.Entity<ShipmentItem>(entity =>
        {
            entity.ToTable("ShipmentItems", "Fulfillment");

            entity.HasIndex(e => e.OrderItemId, "IX_ShipmentItems_OrderItemId");

            entity.HasIndex(e => new { e.ShipmentId, e.OrderItemId }, "UQ_ShipmentItems_Shipment_OrderItem").IsUnique();

            entity.HasOne(d => d.OrderItem).WithMany(p => p.ShipmentItems)
                .HasForeignKey(d => d.OrderItemId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ShipmentItems_OrderItems");

            entity.HasOne(d => d.Shipment).WithMany(p => p.ShipmentItems)
                .HasForeignKey(d => d.ShipmentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ShipmentItems_Shipments");
        });

        modelBuilder.Entity<StockLevel>(entity =>
        {
            entity.HasKey(e => new { e.WarehouseId, e.ProductId });

            entity.ToTable("StockLevels", "Inventory");

            entity.HasIndex(e => e.ProductId, "IX_StockLevels_ProductId");

            entity.Property(e => e.UpdatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_StockLevels_UpdatedAt");

            entity.HasOne(d => d.Product).WithMany(p => p.StockLevels)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_StockLevels_Products");

            entity.HasOne(d => d.Warehouse).WithMany(p => p.StockLevels)
                .HasForeignKey(d => d.WarehouseId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_StockLevels_Warehouses");
        });

        modelBuilder.Entity<Supplier>(entity =>
        {
            entity.ToTable("Suppliers", "Procurement");

            entity.HasIndex(e => e.SupplierCode, "UQ_Suppliers_SupplierCode").IsUnique();

            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.CompanyName).HasMaxLength(200);
            entity.Property(e => e.ContactName).HasMaxLength(150);
            entity.Property(e => e.Country).HasMaxLength(100);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Suppliers_CreatedAt");
            entity.Property(e => e.Email)
                .HasMaxLength(320)
                .IsUnicode(false);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Suppliers_IsActive");
            entity.Property(e => e.Phone)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.SupplierCode)
                .HasMaxLength(20)
                .IsUnicode(false);
        });

        modelBuilder.Entity<SupplierProduct>(entity =>
        {
            entity.ToTable("SupplierProducts", "Procurement");

            entity.HasIndex(e => e.ProductId, "IX_SupplierProducts_ProductId");

            entity.HasIndex(e => new { e.SupplierId, e.ProductId }, "UQ_SupplierProducts_Supplier_Product").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_SupplierProducts_CreatedAt");
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_SupplierProducts_IsActive");
            entity.Property(e => e.SupplierProductCode)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.UnitCost).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Product).WithMany(p => p.SupplierProducts)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SupplierProducts_Products");

            entity.HasOne(d => d.Supplier).WithMany(p => p.SupplierProducts)
                .HasForeignKey(d => d.SupplierId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SupplierProducts_Suppliers");
        });

        modelBuilder.Entity<Ticket>(entity =>
        {
            entity.ToTable("Tickets", "Support");

            entity.HasIndex(e => new { e.CustomerId, e.CreatedAt }, "IX_Tickets_CustomerId_CreatedAt").IsDescending(false, true);

            entity.HasIndex(e => e.OrderId, "IX_Tickets_OrderId").HasFilter("([OrderId] IS NOT NULL)");

            entity.HasIndex(e => new { e.TicketStatus, e.Priority, e.CreatedAt }, "IX_Tickets_Status_Priority_CreatedAt").IsDescending(false, false, true);

            entity.HasIndex(e => e.TicketNumber, "UQ_Tickets_TicketNumber").IsUnique();

            entity.Property(e => e.ClosedAt).HasPrecision(0);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Tickets_CreatedAt");
            entity.Property(e => e.Priority)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.Subject).HasMaxLength(250);
            entity.Property(e => e.TicketNumber)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.TicketStatus)
                .HasMaxLength(30)
                .IsUnicode(false);

            entity.HasOne(d => d.Customer).WithMany(p => p.Tickets)
                .HasForeignKey(d => d.CustomerId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Tickets_Customers");

            entity.HasOne(d => d.Order).WithMany(p => p.Tickets)
                .HasForeignKey(d => d.OrderId)
                .HasConstraintName("FK_Tickets_Orders");
        });

        modelBuilder.Entity<TicketMessage>(entity =>
        {
            entity.ToTable("TicketMessages", "Support");

            entity.HasIndex(e => new { e.TicketId, e.CreatedAt }, "IX_TicketMessages_TicketId_CreatedAt");

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_TicketMessages_CreatedAt");
            entity.Property(e => e.SenderType)
                .HasMaxLength(30)
                .IsUnicode(false);

            entity.HasOne(d => d.Ticket).WithMany(p => p.TicketMessages)
                .HasForeignKey(d => d.TicketId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TicketMessages_Tickets");
        });

        modelBuilder.Entity<ToolExecution>(entity =>
        {
            entity.HasKey(e => e.ToolExecutionId).HasName("PK_AIToolExecutions");

            entity.ToTable("ToolExecutions", "AI");

            entity.HasIndex(e => new { e.ToolName, e.StartedAt }, "IX_AIToolExecutions_ToolName_StartedAt").IsDescending(false, true);

            entity.HasIndex(e => new { e.RunId, e.SequenceNumber }, "UQ_AIToolExecutions_Run_Sequence").IsUnique();

            entity.Property(e => e.CompletedAt).HasPrecision(3);
            entity.Property(e => e.ErrorMessage).HasMaxLength(2000);
            entity.Property(e => e.ExecutionStatus)
                .HasMaxLength(30)
                .IsUnicode(false);
            entity.Property(e => e.StartedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_AIToolExecutions_StartedAt");
            entity.Property(e => e.ToolName)
                .HasMaxLength(150)
                .IsUnicode(false);

            entity.HasOne(d => d.Run).WithMany(p => p.ToolExecutions)
                .HasForeignKey(d => d.RunId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AIToolExecutions_Runs");
        });

        modelBuilder.Entity<Warehouse>(entity =>
        {
            entity.ToTable("Warehouses", "Inventory");

            entity.HasIndex(e => e.WarehouseCode, "UQ_Warehouses_WarehouseCode").IsUnique();

            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.Country).HasMaxLength(100);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Warehouses_CreatedAt");
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Warehouses_IsActive");
            entity.Property(e => e.WarehouseCode)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.WarehouseName).HasMaxLength(150);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
