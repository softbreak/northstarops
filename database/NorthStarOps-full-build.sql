/*
    NorthstarOps — Full Build
    =========================
    Kaynak: 01-18 numaralı güncel SQL scriptleri.
    Amaç: NorthstarOps veritabanını tek dosyadan oluşturmak, seed etmek ve doğrulamak.

    Not:
    - Bu dosya kaynak scriptlerin sırasını korur.
    - .bak kaynakları dahil edilmemiştir.
    - Mevcut NorthstarOps'u otomatik DROP etmez.
      Temiz build isteniyorsa önce veritabanını silin.
*/


-- ============================================================================
-- SOURCE: 01-create-database.sql
-- ============================================================================

USE master;
GO

-- NorthstarOps
-- GenAI Engineering müfredatı boyunca kullanılacak ana operasyon veritabanıdır.
-- Satış, destek, bilgi yönetimi, AI çalışmaları, değerlendirme ve yönetişim
-- verilerini aynı sistem içinde tutacaktır.
IF DB_ID(N'NorthstarOps') IS NULL
BEGIN
    CREATE DATABASE NorthstarOps;
END
GO


-- ============================================================================
-- SOURCE: 02-create-schemas.sql
-- ============================================================================

USE NorthstarOps;
GO

-- NorthstarOps iş alanlarını ayrı şemalar altında gruplar.
-- Identity şeması ileride ASP.NET Core Identity tarafından oluşturulacaktır.

-- Şirket organizasyonu, departmanlar ve çalışanlar.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Organization')
    EXEC(N'CREATE SCHEMA Organization AUTHORIZATION dbo');
GO

-- Ürün ve kategori verileri.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Catalog')
    EXEC(N'CREATE SCHEMA Catalog AUTHORIZATION dbo');
GO

-- Müşteri, sipariş ve ödeme verileri.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Sales')
    EXEC(N'CREATE SCHEMA Sales AUTHORIZATION dbo');
GO

-- Tedarikçi ve satın alma işlemleri.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Procurement')
    EXEC(N'CREATE SCHEMA Procurement AUTHORIZATION dbo');
GO

-- Depo, stok ve stok hareketleri.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Inventory')
    EXEC(N'CREATE SCHEMA Inventory AUTHORIZATION dbo');
GO

-- Sipariş sevkiyat ve teslimat işlemleri.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Fulfillment')
    EXEC(N'CREATE SCHEMA Fulfillment AUTHORIZATION dbo');
GO

-- Müşteri destek talepleri ve mesajları.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Support')
    EXEC(N'CREATE SCHEMA Support AUTHORIZATION dbo');
GO

-- Doküman ve RAG bilgi kaynakları.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Knowledge')
    EXEC(N'CREATE SCHEMA Knowledge AUTHORIZATION dbo');
GO

-- İade ve diğer iş operasyonları.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Operations')
    EXEC(N'CREATE SCHEMA Operations AUTHORIZATION dbo');
GO

-- AI çalışmaları, mesajları ve araç çağrıları.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'AI')
    EXEC(N'CREATE SCHEMA AI AUTHORIZATION dbo');
GO

-- AI kalite ölçümü ve test sonuçları.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Evaluation')
    EXEC(N'CREATE SCHEMA Evaluation AUTHORIZATION dbo');
GO

-- İnsan onayı, audit ve yetki takibi.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Governance')
    EXEC(N'CREATE SCHEMA Governance AUTHORIZATION dbo');
GO


-- ============================================================================
-- SOURCE: 03-create-organization-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Şirket departmanları.
IF OBJECT_ID(N'Organization.Departments', N'U') IS NULL
BEGIN
    CREATE TABLE Organization.Departments
    (
        -- Teknik benzersiz kimlik.
        DepartmentId    INT IDENTITY(1,1) NOT NULL,

        -- Departmanın benzersiz iş kodu.
        DepartmentCode  VARCHAR(20)       NOT NULL,

        -- Departman adı.
        DepartmentName  NVARCHAR(150)     NOT NULL,

        -- Departman açıklaması.
        Description     NVARCHAR(500)     NULL,

        -- Departmanın aktiflik durumu.
        IsActive        BIT               NOT NULL
            CONSTRAINT DF_Departments_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Departments_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Departments
            PRIMARY KEY (DepartmentId),

        -- Departman kodunun benzersiz olmasını sağlar.
        CONSTRAINT UQ_Departments_DepartmentCode
            UNIQUE (DepartmentCode),

        -- Departman adının benzersiz olmasını sağlar.
        CONSTRAINT UQ_Departments_DepartmentName
            UNIQUE (DepartmentName)
    );
END
GO


-- Şirket çalışanları.
IF OBJECT_ID(N'Organization.Employees', N'U') IS NULL
BEGIN
    CREATE TABLE Organization.Employees
    (
        -- Teknik benzersiz kimlik.
        EmployeeId          INT IDENTITY(1,1) NOT NULL,

        -- Çalışanın benzersiz iş kodu.
        EmployeeCode        VARCHAR(20)       NOT NULL,

        -- Ad.
        FirstName           NVARCHAR(100)     NOT NULL,

        -- Soyad.
        LastName            NVARCHAR(100)     NOT NULL,

        -- Kurumsal e-posta adresi.
        Email               VARCHAR(320)      NOT NULL,

        -- Görev unvanı.
        JobTitle            NVARCHAR(150)     NOT NULL,

        -- Çalışanın bağlı olduğu yönetici.
        -- Üst yöneticisi yoksa NULL olabilir.
        ManagerEmployeeId   INT               NULL,

        -- İşe başlangıç tarihi.
        HireDate            DATE              NOT NULL,

        -- Çalışanın aktiflik durumu.
        IsActive            BIT               NOT NULL
            CONSTRAINT DF_Employees_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt           DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Employees_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Employees
            PRIMARY KEY (EmployeeId),

        -- Çalışan kodunun benzersiz olmasını sağlar.
        CONSTRAINT UQ_Employees_EmployeeCode
            UNIQUE (EmployeeCode),

        -- Kurumsal e-posta adresinin benzersiz olmasını sağlar.
        CONSTRAINT UQ_Employees_Email
            UNIQUE (Email),

        -- Çalışanı varsa yöneticisine bağlar.
        CONSTRAINT FK_Employees_Manager
            FOREIGN KEY (ManagerEmployeeId)
            REFERENCES Organization.Employees (EmployeeId),

        -- Çalışanın kendi yöneticisi olarak atanmasını engeller.
        CONSTRAINT CK_Employees_Manager
            CHECK (ManagerEmployeeId IS NULL OR ManagerEmployeeId <> EmployeeId)
    );
END
GO


-- Çalışanlar ile departmanlar arasındaki ilişki.
IF OBJECT_ID(N'Organization.EmployeeDepartments', N'U') IS NULL
BEGIN
    CREATE TABLE Organization.EmployeeDepartments
    (
        -- Çalışan kimliği.
        EmployeeId      INT           NOT NULL,

        -- Departman kimliği.
        DepartmentId    INT           NOT NULL,

        -- Çalışanın bu departmandaki birincil üyeliği olup olmadığını belirtir.
        IsPrimary       BIT           NOT NULL
            CONSTRAINT DF_EmployeeDepartments_IsPrimary DEFAULT (0),

        -- Atamanın başladığı tarih.
        AssignedFrom    DATE          NOT NULL,

        -- Atamanın sona erdiği tarih.
        -- NULL ise atama devam ediyor olabilir.
        AssignedTo      DATE          NULL,

        -- Aynı çalışan-departman eşleşmesinin tekrar oluşturulmasını engeller.
        CONSTRAINT PK_EmployeeDepartments
            PRIMARY KEY (EmployeeId, DepartmentId),

        -- Çalışanı geçerli bir çalışan kaydına bağlar.
        CONSTRAINT FK_EmployeeDepartments_Employees
            FOREIGN KEY (EmployeeId)
            REFERENCES Organization.Employees (EmployeeId),

        -- Departmanı geçerli bir departman kaydına bağlar.
        CONSTRAINT FK_EmployeeDepartments_Departments
            FOREIGN KEY (DepartmentId)
            REFERENCES Organization.Departments (DepartmentId),

        -- Atama bitiş tarihinin başlangıç tarihinden önce olmasını engeller.
        CONSTRAINT CK_EmployeeDepartments_Dates
            CHECK (AssignedTo IS NULL OR AssignedTo >= AssignedFrom)
    );
END
GO


-- ============================================================================
-- SOURCE: 04-create-catalog-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Ürün kategorileri.
IF OBJECT_ID(N'Catalog.Categories', N'U') IS NULL
BEGIN
    CREATE TABLE Catalog.Categories
    (
        -- Teknik benzersiz kimlik.
        CategoryId      INT IDENTITY(1,1) NOT NULL,

        -- Kategori adı.
        CategoryName    NVARCHAR(150)     NOT NULL,

        -- Kategori açıklaması.
        Description     NVARCHAR(500)     NULL,

        -- Kategorinin aktiflik durumu.
        IsActive        BIT               NOT NULL
            CONSTRAINT DF_Categories_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Categories_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Categories
            PRIMARY KEY (CategoryId),

        -- Kategori adının benzersiz olmasını sağlar.
        CONSTRAINT UQ_Categories_CategoryName
            UNIQUE (CategoryName)
    );
END
GO


-- Satılan ürünler.
IF OBJECT_ID(N'Catalog.Products', N'U') IS NULL
BEGIN
    CREATE TABLE Catalog.Products
    (
        -- Teknik benzersiz kimlik.
        ProductId       INT IDENTITY(1,1) NOT NULL,

        -- Ürünün bağlı olduğu kategori.
        CategoryId      INT               NOT NULL,

        -- Ürünün benzersiz iş kodu.
        ProductCode     VARCHAR(30)       NOT NULL,

        -- Ürün adı.
        ProductName     NVARCHAR(200)     NOT NULL,

        -- Ürün açıklaması.
        Description     NVARCHAR(1000)    NULL,

        -- Güncel satış fiyatı.
        UnitPrice       DECIMAL(18,2)     NOT NULL,

        -- Ürünün aktiflik durumu.
        IsActive        BIT               NOT NULL
            CONSTRAINT DF_Products_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Products_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Products
            PRIMARY KEY (ProductId),

        -- Ürün kodunun benzersiz olmasını sağlar.
        CONSTRAINT UQ_Products_ProductCode
            UNIQUE (ProductCode),

        -- Negatif fiyat girilmesini engeller.
        CONSTRAINT CK_Products_UnitPrice
            CHECK (UnitPrice >= 0),

        -- Ürünü geçerli bir kategoriye bağlar.
        CONSTRAINT FK_Products_Categories
            FOREIGN KEY (CategoryId)
            REFERENCES Catalog.Categories (CategoryId)
    );
END
GO


-- ============================================================================
-- SOURCE: 05-create-sales-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Müşteri şirketleri.
IF OBJECT_ID(N'Sales.Customers', N'U') IS NULL
BEGIN
    CREATE TABLE Sales.Customers
    (
        -- Teknik benzersiz kimlik.
        CustomerId      INT IDENTITY(1,1) NOT NULL,

        -- Müşterinin benzersiz iş kodu.
        CustomerCode    VARCHAR(20)       NOT NULL,

        -- Şirket adı.
        CompanyName     NVARCHAR(200)     NOT NULL,

        -- Ana iletişim kişisi.
        ContactName     NVARCHAR(150)     NULL,

        -- İletişim e-posta adresi.
        Email           VARCHAR(320)      NULL,

        -- Telefon numarası.
        Phone           VARCHAR(30)       NULL,

        -- Ülke.
        Country         NVARCHAR(100)     NOT NULL,

        -- Şehir.
        City            NVARCHAR(100)     NULL,

        -- Müşterinin aktiflik durumu.
        IsActive        BIT               NOT NULL
            CONSTRAINT DF_Customers_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Customers_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Customers
            PRIMARY KEY (CustomerId),

        -- Müşteri kodunun benzersiz olmasını sağlar.
        CONSTRAINT UQ_Customers_CustomerCode
            UNIQUE (CustomerCode)
    );
END
GO


-- Müşteri siparişleri.
IF OBJECT_ID(N'Sales.Orders', N'U') IS NULL
BEGIN
    CREATE TABLE Sales.Orders
    (
        -- Teknik benzersiz kimlik.
        OrderId         INT IDENTITY(1,1) NOT NULL,

        -- Siparişi veren müşteri.
        CustomerId      INT               NOT NULL,

        -- Siparişin benzersiz iş numarası.
        OrderNumber     VARCHAR(30)       NOT NULL,

        -- Sipariş durumu.
        OrderStatus     VARCHAR(30)       NOT NULL,

        -- Siparişin oluşturulduğu zaman (UTC).
        OrderedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Orders_OrderedAt DEFAULT (SYSUTCDATETIME()),

        -- Siparişin toplam tutarı.
        TotalAmount     DECIMAL(18,2)     NOT NULL,

        CONSTRAINT PK_Orders
            PRIMARY KEY (OrderId),

        CONSTRAINT UQ_Orders_OrderNumber
            UNIQUE (OrderNumber),

        -- Negatif toplam tutarı engeller.
        CONSTRAINT CK_Orders_TotalAmount
            CHECK (TotalAmount >= 0),

        -- Siparişi geçerli bir müşteriye bağlar.
        CONSTRAINT FK_Orders_Customers
            FOREIGN KEY (CustomerId)
            REFERENCES Sales.Customers (CustomerId)
    );
END
GO


-- Sipariş içindeki ürün satırları.
IF OBJECT_ID(N'Sales.OrderItems', N'U') IS NULL
BEGIN
    CREATE TABLE Sales.OrderItems
    (
        -- Teknik benzersiz kimlik.
        OrderItemId     INT IDENTITY(1,1) NOT NULL,

        -- Bağlı olduğu sipariş.
        OrderId         INT               NOT NULL,

        -- Satılan ürün.
        ProductId       INT               NOT NULL,

        -- Satılan adet.
        Quantity        INT               NOT NULL,

        -- Sipariş anındaki birim fiyat.
        UnitPrice       DECIMAL(18,2)     NOT NULL,

        CONSTRAINT PK_OrderItems
            PRIMARY KEY (OrderItemId),

        -- Adedin sıfırdan büyük olmasını sağlar.
        CONSTRAINT CK_OrderItems_Quantity
            CHECK (Quantity > 0),

        -- Negatif fiyat girilmesini engeller.
        CONSTRAINT CK_OrderItems_UnitPrice
            CHECK (UnitPrice >= 0),

        -- Sipariş kalemini siparişe bağlar.
        CONSTRAINT FK_OrderItems_Orders
            FOREIGN KEY (OrderId)
            REFERENCES Sales.Orders (OrderId),

        -- Sipariş kalemini ürüne bağlar.
        CONSTRAINT FK_OrderItems_Products
            FOREIGN KEY (ProductId)
            REFERENCES Catalog.Products (ProductId)
    );
END
GO


-- Siparişlere ait ödeme kayıtları.
IF OBJECT_ID(N'Sales.Payments', N'U') IS NULL
BEGIN
    CREATE TABLE Sales.Payments
    (
        -- Teknik benzersiz kimlik.
        PaymentId       INT IDENTITY(1,1) NOT NULL,

        -- Ödemenin bağlı olduğu sipariş.
        OrderId         INT               NOT NULL,

        -- Ödeme yöntemi.
        PaymentMethod   VARCHAR(30)       NOT NULL,

        -- Ödeme durumu.
        PaymentStatus   VARCHAR(30)       NOT NULL,

        -- Ödenen tutar.
        Amount          DECIMAL(18,2)     NOT NULL,

        -- Ödemenin gerçekleştiği zaman (UTC).
        PaidAt          DATETIME2(0)      NULL,

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Payments_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Payments
            PRIMARY KEY (PaymentId),

        -- Negatif ödeme tutarını engeller.
        CONSTRAINT CK_Payments_Amount
            CHECK (Amount >= 0),

        -- Ödemeyi geçerli bir siparişe bağlar.
        CONSTRAINT FK_Payments_Orders
            FOREIGN KEY (OrderId)
            REFERENCES Sales.Orders (OrderId)
    );
END
GO

-- Müşterilere ait iletişim kişileri.
IF OBJECT_ID(N'Sales.CustomerContacts', N'U') IS NULL
BEGIN
    CREATE TABLE Sales.CustomerContacts
    (
        -- Teknik benzersiz kimlik.
        CustomerContactId INT IDENTITY(1,1) NOT NULL,

        -- İletişim kişisinin bağlı olduğu müşteri.
        CustomerId        INT               NOT NULL,

        -- Ad.
        FirstName         NVARCHAR(100)     NOT NULL,

        -- Soyad.
        LastName          NVARCHAR(100)     NOT NULL,

        -- Görev veya unvan.
        JobTitle          NVARCHAR(150)     NULL,

        -- E-posta adresi.
        Email             VARCHAR(320)      NULL,

        -- Telefon numarası.
        Phone             VARCHAR(30)       NULL,

        -- Birincil iletişim kişisi olup olmadığını belirtir.
        IsPrimary         BIT               NOT NULL
            CONSTRAINT DF_CustomerContacts_IsPrimary DEFAULT (0),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt         DATETIME2(0)      NOT NULL
            CONSTRAINT DF_CustomerContacts_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_CustomerContacts
            PRIMARY KEY (CustomerContactId),

        -- İletişim kişisini geçerli bir müşteriye bağlar.
        CONSTRAINT FK_CustomerContacts_Customers
            FOREIGN KEY (CustomerId)
            REFERENCES Sales.Customers (CustomerId)
    );
END
GO


-- Müşterilere ait fatura ve teslimat adresleri.
IF OBJECT_ID(N'Sales.CustomerAddresses', N'U') IS NULL
BEGIN
    CREATE TABLE Sales.CustomerAddresses
    (
        -- Teknik benzersiz kimlik.
        CustomerAddressId INT IDENTITY(1,1) NOT NULL,

        -- Adresin bağlı olduğu müşteri.
        CustomerId        INT               NOT NULL,

        -- Adres türü.
        -- Örnek: Billing, Shipping.
        AddressType       VARCHAR(30)       NOT NULL,

        -- Adres satırı.
        AddressLine       NVARCHAR(250)     NOT NULL,

        -- Şehir.
        City              NVARCHAR(100)     NOT NULL,

        -- İl, eyalet veya bölge.
        StateProvince     NVARCHAR(100)     NULL,

        -- Posta kodu.
        PostalCode        VARCHAR(20)       NULL,

        -- Ülke.
        Country           NVARCHAR(100)     NOT NULL,

        -- Varsayılan adres olup olmadığını belirtir.
        IsDefault         BIT               NOT NULL
            CONSTRAINT DF_CustomerAddresses_IsDefault DEFAULT (0),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt         DATETIME2(0)      NOT NULL
            CONSTRAINT DF_CustomerAddresses_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_CustomerAddresses
            PRIMARY KEY (CustomerAddressId),

        -- Adresi geçerli bir müşteriye bağlar.
        CONSTRAINT FK_CustomerAddresses_Customers
            FOREIGN KEY (CustomerId)
            REFERENCES Sales.Customers (CustomerId)
    );
END
GO


-- ============================================================================
-- SOURCE: 06-create-inventory-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Fiziksel veya mantıksal depolar.
IF OBJECT_ID(N'Inventory.Warehouses', N'U') IS NULL
BEGIN
    CREATE TABLE Inventory.Warehouses
    (
        -- Teknik benzersiz kimlik.
        WarehouseId     INT IDENTITY(1,1) NOT NULL,

        -- Deponun benzersiz iş kodu.
        WarehouseCode   VARCHAR(20)       NOT NULL,

        -- Depo adı.
        WarehouseName   NVARCHAR(150)     NOT NULL,

        -- Ülke.
        Country         NVARCHAR(100)     NOT NULL,

        -- Şehir.
        City            NVARCHAR(100)     NOT NULL,

        -- Deponun aktiflik durumu.
        IsActive        BIT               NOT NULL
            CONSTRAINT DF_Warehouses_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Warehouses_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Warehouses
            PRIMARY KEY (WarehouseId),

        -- Depo kodunun benzersiz olmasını sağlar.
        CONSTRAINT UQ_Warehouses_WarehouseCode
            UNIQUE (WarehouseCode)
    );
END
GO


-- Her ürünün depolardaki mevcut stok miktarı.
IF OBJECT_ID(N'Inventory.StockLevels', N'U') IS NULL
BEGIN
    CREATE TABLE Inventory.StockLevels
    (
        -- Depo.
        WarehouseId     INT               NOT NULL,

        -- Ürün.
        ProductId       INT               NOT NULL,

        -- Fiziksel olarak mevcut stok miktarı.
        QuantityOnHand  INT               NOT NULL
            CONSTRAINT DF_StockLevels_QuantityOnHand DEFAULT (0),

        -- Sipariş veya operasyonlar için ayrılmış stok miktarı.
        QuantityReserved INT              NOT NULL
            CONSTRAINT DF_StockLevels_QuantityReserved DEFAULT (0),

        -- Stok kaydının son güncellenme zamanı (UTC).
        UpdatedAt       DATETIME2(3)      NOT NULL
            CONSTRAINT DF_StockLevels_UpdatedAt DEFAULT (SYSUTCDATETIME()),

        -- Her ürün-depo eşleşmesi için tek stok kaydı tutulur.
        CONSTRAINT PK_StockLevels
            PRIMARY KEY (WarehouseId, ProductId),

        -- Negatif fiziksel stok miktarını engeller.
        CONSTRAINT CK_StockLevels_QuantityOnHand
            CHECK (QuantityOnHand >= 0),

        -- Negatif ayrılmış stok miktarını engeller.
        CONSTRAINT CK_StockLevels_QuantityReserved
            CHECK (QuantityReserved >= 0),

        -- Ayrılmış stok miktarının fiziksel stoktan fazla olmasını engeller.
        CONSTRAINT CK_StockLevels_Reserved
            CHECK (QuantityReserved <= QuantityOnHand),

        -- Stok kaydını geçerli bir depoya bağlar.
        CONSTRAINT FK_StockLevels_Warehouses
            FOREIGN KEY (WarehouseId)
            REFERENCES Inventory.Warehouses (WarehouseId),

        -- Stok kaydını katalogdaki ürüne bağlar.
        CONSTRAINT FK_StockLevels_Products
            FOREIGN KEY (ProductId)
            REFERENCES Catalog.Products (ProductId)
    );
END
GO


-- Fiziksel stok ve rezervasyon miktarındaki her değişimin hareket kaydı.
IF OBJECT_ID(N'Inventory.InventoryMovements', N'U') IS NULL
BEGIN
    CREATE TABLE Inventory.InventoryMovements
    (
        -- Teknik benzersiz kimlik.
        InventoryMovementId     BIGINT IDENTITY(1,1) NOT NULL,

        -- Hareketin gerçekleştiği depo.
        WarehouseId             INT                  NOT NULL,

        -- Hareketten etkilenen ürün.
        ProductId               INT                  NOT NULL,

        -- Stok hareketinin türü.
        -- Örnek: PurchaseReceipt, SaleReservation, Shipment,
        -- Return, Adjustment.
        MovementType            VARCHAR(40)          NOT NULL,

        -- Fiziksel stoktaki değişim.
        -- Pozitif: ürün depoya girer.
        -- Negatif: ürün depodan çıkar.
        -- 0: fiziksel stok değişmez.
        QuantityOnHandChange    INT                  NOT NULL
            CONSTRAINT DF_InventoryMovements_QuantityOnHandChange DEFAULT (0),

        -- Rezerve edilmiş stoktaki değişim.
        -- Pozitif: stok sipariş için rezerve edilir.
        -- Negatif: rezervasyon çözülür/tüketilir.
        -- 0: rezervasyon değişmez.
        QuantityReservedChange  INT                  NOT NULL
            CONSTRAINT DF_InventoryMovements_QuantityReservedChange DEFAULT (0),

        -- Harekete neden olan kaynak varlığın türü.
        -- Örnek: PurchaseReceipt, Order, Shipment, RefundRequest.
        ReferenceType           VARCHAR(50)          NULL,

        -- Kaynak kaydın kimliği.
        ReferenceId             BIGINT               NULL,

        -- Hareket hakkında ek açıklama.
        Notes                   NVARCHAR(1000)       NULL,

        -- Hareketin gerçekleştiği zaman (UTC).
        CreatedAt               DATETIME2(3)         NOT NULL
            CONSTRAINT DF_InventoryMovements_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_InventoryMovements
            PRIMARY KEY (InventoryMovementId),

        -- Hiçbir stok durumunu değiştirmeyen hareket kaydını engeller.
        CONSTRAINT CK_InventoryMovements_QuantityChanges
            CHECK (
                QuantityOnHandChange <> 0
                OR QuantityReservedChange <> 0
            ),

        -- Hareketi geçerli bir depoya bağlar.
        CONSTRAINT FK_InventoryMovements_Warehouses
            FOREIGN KEY (WarehouseId)
            REFERENCES Inventory.Warehouses (WarehouseId),

        -- Hareketi katalogdaki ürüne bağlar.
        CONSTRAINT FK_InventoryMovements_Products
            FOREIGN KEY (ProductId)
            REFERENCES Catalog.Products (ProductId)
    );
END
GO


-- ============================================================================
-- SOURCE: 07-create-procurement-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Ürünlerin satın alındığı tedarikçiler.
IF OBJECT_ID(N'Procurement.Suppliers', N'U') IS NULL
BEGIN
    CREATE TABLE Procurement.Suppliers
    (
        -- Teknik benzersiz kimlik.
        SupplierId      INT IDENTITY(1,1) NOT NULL,

        -- Tedarikçinin benzersiz iş kodu.
        SupplierCode    VARCHAR(20)       NOT NULL,

        -- Tedarikçi şirket adı.
        CompanyName     NVARCHAR(200)     NOT NULL,

        -- Ana iletişim kişisi.
        ContactName     NVARCHAR(150)     NULL,

        -- İletişim e-posta adresi.
        Email           VARCHAR(320)      NULL,

        -- Telefon numarası.
        Phone           VARCHAR(30)       NULL,

        -- Ülke.
        Country         NVARCHAR(100)     NOT NULL,

        -- Şehir.
        City            NVARCHAR(100)     NULL,

        -- Tedarikçinin aktiflik durumu.
        IsActive        BIT               NOT NULL
            CONSTRAINT DF_Suppliers_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Suppliers_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Suppliers
            PRIMARY KEY (SupplierId),

        -- Tedarikçi kodunun benzersiz olmasını sağlar.
        CONSTRAINT UQ_Suppliers_SupplierCode
            UNIQUE (SupplierCode)
    );
END
GO


-- Tedarikçilere verilen satın alma siparişleri.
IF OBJECT_ID(N'Procurement.PurchaseOrders', N'U') IS NULL
BEGIN
    CREATE TABLE Procurement.PurchaseOrders
    (
        -- Teknik benzersiz kimlik.
        PurchaseOrderId INT IDENTITY(1,1) NOT NULL,

        -- Siparişin verildiği tedarikçi.
        SupplierId      INT               NOT NULL,

        -- Satın alma işleminden sorumlu çalışan.
        EmployeeId      INT               NOT NULL,

        -- Satın alma siparişinin benzersiz iş numarası.
        PurchaseOrderNumber VARCHAR(30)   NOT NULL,

        -- Satın alma siparişinin durumu.
        -- Örnek: Draft, Ordered, PartiallyReceived, Received, Cancelled.
        OrderStatus     VARCHAR(30)       NOT NULL,

        -- Siparişin verildiği zaman (UTC).
        OrderedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_PurchaseOrders_OrderedAt DEFAULT (SYSUTCDATETIME()),

        -- Beklenen teslimat tarihi.
        ExpectedAt      DATETIME2(0)      NULL,

        -- Siparişin toplam maliyeti.
        TotalAmount     DECIMAL(18,2)     NOT NULL,

        CONSTRAINT PK_PurchaseOrders
            PRIMARY KEY (PurchaseOrderId),

        -- Satın alma sipariş numarasının benzersiz olmasını sağlar.
        CONSTRAINT UQ_PurchaseOrders_Number
            UNIQUE (PurchaseOrderNumber),

        -- Negatif toplam tutarı engeller.
        CONSTRAINT CK_PurchaseOrders_TotalAmount
            CHECK (TotalAmount >= 0),

        -- Siparişi geçerli bir tedarikçiye bağlar.
        CONSTRAINT FK_PurchaseOrders_Suppliers
            FOREIGN KEY (SupplierId)
            REFERENCES Procurement.Suppliers (SupplierId),

        -- Siparişi sorumlu çalışana bağlar.
        CONSTRAINT FK_PurchaseOrders_Employees
            FOREIGN KEY (EmployeeId)
            REFERENCES Organization.Employees (EmployeeId)
    );
END
GO


-- Satın alma siparişindeki ürün satırları.
IF OBJECT_ID(N'Procurement.PurchaseOrderItems', N'U') IS NULL
BEGIN
    CREATE TABLE Procurement.PurchaseOrderItems
    (
        -- Teknik benzersiz kimlik.
        PurchaseOrderItemId INT IDENTITY(1,1) NOT NULL,

        -- Bağlı olduğu satın alma siparişi.
        PurchaseOrderId     INT               NOT NULL,

        -- Satın alınan ürün.
        ProductId           INT               NOT NULL,

        -- Sipariş edilen adet.
        Quantity            INT               NOT NULL,

        -- Tedarikçiden alınan birim maliyet.
        UnitCost            DECIMAL(18,2)     NOT NULL,

        CONSTRAINT PK_PurchaseOrderItems
            PRIMARY KEY (PurchaseOrderItemId),

        -- Adedin sıfırdan büyük olmasını sağlar.
        CONSTRAINT CK_PurchaseOrderItems_Quantity
            CHECK (Quantity > 0),

        -- Negatif birim maliyeti engeller.
        CONSTRAINT CK_PurchaseOrderItems_UnitCost
            CHECK (UnitCost >= 0),

        -- Satırı satın alma siparişine bağlar.
        CONSTRAINT FK_PurchaseOrderItems_PurchaseOrders
            FOREIGN KEY (PurchaseOrderId)
            REFERENCES Procurement.PurchaseOrders (PurchaseOrderId),

        -- Satırı katalogdaki ürüne bağlar.
        CONSTRAINT FK_PurchaseOrderItems_Products
            FOREIGN KEY (ProductId)
            REFERENCES Catalog.Products (ProductId)
    );
END
GO

-- Tedarikçilerin sağlayabildiği ürünler.
IF OBJECT_ID(N'Procurement.SupplierProducts', N'U') IS NULL
BEGIN
    CREATE TABLE Procurement.SupplierProducts
    (
        -- Teknik benzersiz kimlik.
        SupplierProductId INT IDENTITY(1,1) NOT NULL,

        -- Tedarikçi.
        SupplierId        INT               NOT NULL,

        -- Tedarik edilen ürün.
        ProductId         INT               NOT NULL,

        -- Tedarikçinin kendi ürün kodu.
        SupplierProductCode VARCHAR(50)     NULL,

        -- Tedarikçinin güncel birim maliyeti.
        UnitCost          DECIMAL(18,2)     NOT NULL,

        -- Ortalama teslim süresi (gün).
        LeadTimeDays      INT               NULL,

        -- İlişkinin aktiflik durumu.
        IsActive          BIT               NOT NULL
            CONSTRAINT DF_SupplierProducts_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt         DATETIME2(0)      NOT NULL
            CONSTRAINT DF_SupplierProducts_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_SupplierProducts
            PRIMARY KEY (SupplierProductId),

        -- Aynı tedarikçi-ürün eşleşmesinin tekrar oluşturulmasını engeller.
        CONSTRAINT UQ_SupplierProducts_Supplier_Product
            UNIQUE (SupplierId, ProductId),

        -- Negatif maliyeti engeller.
        CONSTRAINT CK_SupplierProducts_UnitCost
            CHECK (UnitCost >= 0),

        -- Negatif teslim süresini engeller.
        CONSTRAINT CK_SupplierProducts_LeadTimeDays
            CHECK (LeadTimeDays IS NULL OR LeadTimeDays >= 0),

        CONSTRAINT FK_SupplierProducts_Suppliers
            FOREIGN KEY (SupplierId)
            REFERENCES Procurement.Suppliers (SupplierId),

        CONSTRAINT FK_SupplierProducts_Products
            FOREIGN KEY (ProductId)
            REFERENCES Catalog.Products (ProductId)
    );
END
GO


-- Satın alma siparişlerinden depoya yapılan teslim alma kayıtları.
IF OBJECT_ID(N'Procurement.PurchaseReceipts', N'U') IS NULL
BEGIN
    CREATE TABLE Procurement.PurchaseReceipts
    (
        -- Teknik benzersiz kimlik.
        PurchaseReceiptId BIGINT IDENTITY(1,1) NOT NULL,

        -- İlgili satın alma siparişi.
        PurchaseOrderId   INT                  NOT NULL,

        -- Ürünlerin teslim alındığı depo.
        WarehouseId       INT                  NOT NULL,

        -- Teslim alma işleminin benzersiz numarası.
        ReceiptNumber     VARCHAR(30)          NOT NULL,

        -- Teslim alma durumu.
        -- Örnek: Received, Partial, Rejected.
        ReceiptStatus     VARCHAR(30)          NOT NULL,

        -- Teslim alma zamanı (UTC).
        ReceivedAt        DATETIME2(3)         NOT NULL
            CONSTRAINT DF_PurchaseReceipts_ReceivedAt DEFAULT (SYSUTCDATETIME()),

        -- Ek açıklama.
        Notes             NVARCHAR(1000)       NULL,

        CONSTRAINT PK_PurchaseReceipts
            PRIMARY KEY (PurchaseReceiptId),

        CONSTRAINT UQ_PurchaseReceipts_ReceiptNumber
            UNIQUE (ReceiptNumber),

        CONSTRAINT FK_PurchaseReceipts_PurchaseOrders
            FOREIGN KEY (PurchaseOrderId)
            REFERENCES Procurement.PurchaseOrders (PurchaseOrderId),

        CONSTRAINT FK_PurchaseReceipts_Warehouses
            FOREIGN KEY (WarehouseId)
            REFERENCES Inventory.Warehouses (WarehouseId)
    );
END
GO


-- Teslim alma kaydındaki ürün satırları.
IF OBJECT_ID(N'Procurement.PurchaseReceiptItems', N'U') IS NULL
BEGIN
    CREATE TABLE Procurement.PurchaseReceiptItems
    (
        -- Teknik benzersiz kimlik.
        PurchaseReceiptItemId BIGINT IDENTITY(1,1) NOT NULL,

        -- Bağlı olduğu teslim alma kaydı.
        PurchaseReceiptId     BIGINT               NOT NULL,

        -- İlgili satın alma sipariş kalemi.
        PurchaseOrderItemId   INT                  NOT NULL,

        -- Gerçekte teslim alınan adet.
        QuantityReceived      INT                  NOT NULL,

        -- Reddedilen veya hasarlı adet.
        QuantityRejected      INT                  NOT NULL
            CONSTRAINT DF_PurchaseReceiptItems_QuantityRejected DEFAULT (0),

        CONSTRAINT PK_PurchaseReceiptItems
            PRIMARY KEY (PurchaseReceiptItemId),

        CONSTRAINT CK_PurchaseReceiptItems_QuantityReceived
            CHECK (QuantityReceived > 0),

        CONSTRAINT CK_PurchaseReceiptItems_QuantityRejected
            CHECK (QuantityRejected >= 0),

        -- Reddedilen adedin teslim alınan adetten fazla olmasını engeller.
        CONSTRAINT CK_PurchaseReceiptItems_RejectedVsReceived
            CHECK (QuantityRejected <= QuantityReceived),

        CONSTRAINT FK_PurchaseReceiptItems_PurchaseReceipts
            FOREIGN KEY (PurchaseReceiptId)
            REFERENCES Procurement.PurchaseReceipts (PurchaseReceiptId),

        CONSTRAINT FK_PurchaseReceiptItems_PurchaseOrderItems
            FOREIGN KEY (PurchaseOrderItemId)
            REFERENCES Procurement.PurchaseOrderItems (PurchaseOrderItemId)
    );
END
GO


-- ============================================================================
-- SOURCE: 08-create-fulfillment-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Müşteri siparişlerinin sevkiyat kayıtları.
IF OBJECT_ID(N'Fulfillment.Shipments', N'U') IS NULL
BEGIN
    CREATE TABLE Fulfillment.Shipments
    (
        -- Teknik benzersiz kimlik.
        ShipmentId      BIGINT IDENTITY(1,1) NOT NULL,

        -- Sevkiyatın bağlı olduğu müşteri siparişi.
        OrderId         INT                  NOT NULL,

        -- Sevkiyatın çıktığı depo.
        WarehouseId     INT                  NOT NULL,

        -- Sevkiyatın benzersiz iş numarası.
        ShipmentNumber  VARCHAR(30)          NOT NULL,

        -- Sevkiyat durumu.
        -- Örnek: Preparing, Shipped, InTransit, Delivered, Failed.
        ShipmentStatus  VARCHAR(30)          NOT NULL,

        -- Taşıyıcı firma adı.
        CarrierName     NVARCHAR(150)        NULL,

        -- Taşıyıcı tarafından verilen takip numarası.
        TrackingNumber  VARCHAR(100)         NULL,

        -- Sevkiyatın depodan çıktığı zaman (UTC).
        ShippedAt       DATETIME2(3)         NULL,

        -- Tahmini teslimat zamanı (UTC).
        EstimatedDeliveryAt DATETIME2(3)     NULL,

        -- Gerçek teslimat zamanı (UTC).
        DeliveredAt     DATETIME2(3)         NULL,

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(3)         NOT NULL
            CONSTRAINT DF_Shipments_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Shipments
            PRIMARY KEY (ShipmentId),

        -- Sevkiyat numarasının benzersiz olmasını sağlar.
        CONSTRAINT UQ_Shipments_ShipmentNumber
            UNIQUE (ShipmentNumber),

        -- Teslimat zamanının sevkiyat zamanından önce olmasını engeller.
        CONSTRAINT CK_Shipments_Dates
            CHECK (
                DeliveredAt IS NULL
                OR ShippedAt IS NULL
                OR DeliveredAt >= ShippedAt
            ),

        -- Sevkiyatı geçerli bir siparişe bağlar.
        CONSTRAINT FK_Shipments_Orders
            FOREIGN KEY (OrderId)
            REFERENCES Sales.Orders (OrderId),

        -- Sevkiyatı geçerli bir depoya bağlar.
        CONSTRAINT FK_Shipments_Warehouses
            FOREIGN KEY (WarehouseId)
            REFERENCES Inventory.Warehouses (WarehouseId)
    );
END
GO


-- Bir sevkiyat içinde gönderilen sipariş kalemleri.
IF OBJECT_ID(N'Fulfillment.ShipmentItems', N'U') IS NULL
BEGIN
    CREATE TABLE Fulfillment.ShipmentItems
    (
        -- Teknik benzersiz kimlik.
        ShipmentItemId  BIGINT IDENTITY(1,1) NOT NULL,

        -- Kalemin bağlı olduğu sevkiyat.
        ShipmentId      BIGINT               NOT NULL,

        -- Sevk edilen sipariş kalemi.
        OrderItemId     INT                  NOT NULL,

        -- Bu sevkiyatta gönderilen adet.
        Quantity        INT                  NOT NULL,

        CONSTRAINT PK_ShipmentItems
            PRIMARY KEY (ShipmentItemId),

        -- Adedin sıfırdan büyük olmasını sağlar.
        CONSTRAINT CK_ShipmentItems_Quantity
            CHECK (Quantity > 0),

        -- Aynı sipariş kaleminin aynı sevkiyata tekrar eklenmesini engeller.
        CONSTRAINT UQ_ShipmentItems_Shipment_OrderItem
            UNIQUE (ShipmentId, OrderItemId),

        -- Sevkiyat kalemini geçerli bir sevkiyata bağlar.
        CONSTRAINT FK_ShipmentItems_Shipments
            FOREIGN KEY (ShipmentId)
            REFERENCES Fulfillment.Shipments (ShipmentId),

        -- Sevkiyat kalemini geçerli bir sipariş kalemine bağlar.
        CONSTRAINT FK_ShipmentItems_OrderItems
            FOREIGN KEY (OrderItemId)
            REFERENCES Sales.OrderItems (OrderItemId)
    );
END
GO


-- ============================================================================
-- SOURCE: 09-create-support-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Müşteri destek talepleri.
IF_OBJECT_ID_PLACEHOLDER