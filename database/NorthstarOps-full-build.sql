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
IF OBJECT_ID(N'Support.Tickets', N'U') IS NULL
BEGIN
    CREATE TABLE Support.Tickets
    (
        -- Teknik benzersiz kimlik.
        TicketId        INT IDENTITY(1,1) NOT NULL,

        -- Talebi oluşturan müşteri.
        CustomerId      INT               NOT NULL,

        -- İlgili sipariş. Siparişle ilişkili değilse boş olabilir.
        OrderId         INT               NULL,

        -- Ticket'ın benzersiz iş numarası.
        TicketNumber    VARCHAR(30)       NOT NULL,

        -- Destek talebinin konusu.
        Subject         NVARCHAR(250)     NOT NULL,

        -- Ticket durumu.
        TicketStatus    VARCHAR(30)       NOT NULL,

        -- Öncelik seviyesi.
        Priority        VARCHAR(20)       NOT NULL,

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Tickets_CreatedAt DEFAULT (SYSUTCDATETIME()),

        -- Ticket'ın kapatılma zamanı (UTC).
        ClosedAt        DATETIME2(0)      NULL,

        CONSTRAINT PK_Tickets
            PRIMARY KEY (TicketId),

        -- Ticket numarasının benzersiz olmasını sağlar.
        CONSTRAINT UQ_Tickets_TicketNumber
            UNIQUE (TicketNumber),

        -- Ticket'ı geçerli bir müşteriye bağlar.
        CONSTRAINT FK_Tickets_Customers
            FOREIGN KEY (CustomerId)
            REFERENCES Sales.Customers (CustomerId),

        -- Ticket'ı varsa ilgili siparişe bağlar.
        CONSTRAINT FK_Tickets_Orders
            FOREIGN KEY (OrderId)
            REFERENCES Sales.Orders (OrderId)
    );
END
GO


-- Destek taleplerindeki mesajlar.
IF OBJECT_ID(N'Support.TicketMessages', N'U') IS NULL
BEGIN
    CREATE TABLE Support.TicketMessages
    (
        -- Teknik benzersiz kimlik.
        TicketMessageId INT IDENTITY(1,1) NOT NULL,

        -- Mesajın bağlı olduğu ticket.
        TicketId        INT               NOT NULL,

        -- Mesajın kim tarafından gönderildiğini belirtir.
        -- Örnek: Customer, SupportAgent, System.
        SenderType      VARCHAR(30)       NOT NULL,

        -- Mesajın doğal dil içeriği.
        MessageText     NVARCHAR(MAX)     NOT NULL,

        -- Mesajın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_TicketMessages_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_TicketMessages
            PRIMARY KEY (TicketMessageId),

        -- Mesajı geçerli bir ticket'a bağlar.
        CONSTRAINT FK_TicketMessages_Tickets
            FOREIGN KEY (TicketId)
            REFERENCES Support.Tickets (TicketId)
    );
END
GO


-- ============================================================================
-- SOURCE: 10-create-knowledge-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Bilgi kaynağı olarak kullanılan dokümanlar.
IF OBJECT_ID(N'Knowledge.Documents', N'U') IS NULL
BEGIN
    CREATE TABLE Knowledge.Documents
    (
        -- Teknik benzersiz kimlik.
        DocumentId      INT IDENTITY(1,1) NOT NULL,

        -- Dokümanın benzersiz iş kodu.
        DocumentCode    VARCHAR(30)       NOT NULL,

        -- Doküman başlığı.
        Title           NVARCHAR(250)     NOT NULL,

        -- Doküman türü.
        -- Örnek: Policy, ProductGuide, Procedure, FAQ.
        DocumentType    VARCHAR(30)       NOT NULL,

        -- Dokümanın aktiflik durumu.
        IsActive        BIT               NOT NULL
            CONSTRAINT DF_Documents_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_Documents_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_Documents
            PRIMARY KEY (DocumentId),

        -- Doküman kodunun benzersiz olmasını sağlar.
        CONSTRAINT UQ_Documents_DocumentCode
            UNIQUE (DocumentCode)
    );
END
GO


-- Dokümanların zaman içindeki sürümleri.
IF OBJECT_ID(N'Knowledge.DocumentVersions', N'U') IS NULL
BEGIN
    CREATE TABLE Knowledge.DocumentVersions
    (
        -- Teknik benzersiz kimlik.
        DocumentVersionId INT IDENTITY(1,1) NOT NULL,

        -- Sürümün bağlı olduğu doküman.
        DocumentId        INT               NOT NULL,

        -- Dokümanın sürüm numarası.
        VersionNumber     INT               NOT NULL,

        -- Bu sürümün tam metin içeriği.
        Content           NVARCHAR(MAX)     NOT NULL,

        -- Sürümün geçerli olmaya başladığı zaman (UTC).
        EffectiveFrom     DATETIME2(0)      NOT NULL,

        -- Sürümün geçerliliğinin sona erdiği zaman (UTC).
        -- NULL ise sürüm hâlâ geçerli olabilir.
        EffectiveTo       DATETIME2(0)      NULL,

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt         DATETIME2(0)      NOT NULL
            CONSTRAINT DF_DocumentVersions_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_DocumentVersions
            PRIMARY KEY (DocumentVersionId),

        -- Aynı dokümanda aynı sürüm numarasının tekrar kullanılmasını engeller.
        CONSTRAINT UQ_DocumentVersions_Document_Version
            UNIQUE (DocumentId, VersionNumber),

        -- Sürümü geçerli bir dokümana bağlar.
        CONSTRAINT FK_DocumentVersions_Documents
            FOREIGN KEY (DocumentId)
            REFERENCES Knowledge.Documents (DocumentId),

        -- Geçerlilik bitişinin başlangıçtan önce olmasını engeller.
        CONSTRAINT CK_DocumentVersions_EffectiveDates
            CHECK (EffectiveTo IS NULL OR EffectiveTo >= EffectiveFrom)
    );
END
GO


-- Doküman sürümlerinden retrieval için oluşturulan metin parçaları.
IF OBJECT_ID(N'Knowledge.DocumentChunks', N'U') IS NULL
BEGIN
    CREATE TABLE Knowledge.DocumentChunks
    (
        -- Teknik benzersiz kimlik.
        DocumentChunkId   INT IDENTITY(1,1) NOT NULL,

        -- Chunk'ın bağlı olduğu doküman sürümü.
        DocumentVersionId INT               NOT NULL,

        -- Doküman içindeki parça sırası.
        ChunkIndex        INT               NOT NULL,

        -- Retrieval sırasında kullanılacak metin parçası.
        ChunkText         NVARCHAR(MAX)     NOT NULL,

        -- Chunk'ın oluşturulma zamanı (UTC).
        CreatedAt         DATETIME2(0)      NOT NULL
            CONSTRAINT DF_DocumentChunks_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_DocumentChunks
            PRIMARY KEY (DocumentChunkId),

        -- Aynı sürümde aynı chunk sırasının tekrar oluşmasını engeller.
        CONSTRAINT UQ_DocumentChunks_Version_Index
            UNIQUE (DocumentVersionId, ChunkIndex),

        -- Chunk'ı geçerli bir doküman sürümüne bağlar.
        CONSTRAINT FK_DocumentChunks_DocumentVersions
            FOREIGN KEY (DocumentVersionId)
            REFERENCES Knowledge.DocumentVersions (DocumentVersionId),

        -- Chunk sırasının negatif olmasını engeller.
        CONSTRAINT CK_DocumentChunks_ChunkIndex
            CHECK (ChunkIndex >= 0)
    );
END
GO


-- ============================================================================
-- SOURCE: 11-create-operations-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Müşteri iade talepleri.
IF OBJECT_ID(N'Operations.RefundRequests', N'U') IS NULL
BEGIN
    CREATE TABLE Operations.RefundRequests
    (
        -- Teknik benzersiz kimlik.
        RefundRequestId INT IDENTITY(1,1) NOT NULL,

        -- İadenin bağlı olduğu sipariş.
        OrderId         INT               NOT NULL,

        -- İade talebinin benzersiz iş numarası.
        RequestNumber   VARCHAR(30)       NOT NULL,

        -- İade talebinin nedeni.
        Reason          NVARCHAR(1000)    NOT NULL,

        -- Talep edilen iade tutarı.
        RequestedAmount DECIMAL(18,2)     NOT NULL,

        -- Talebin mevcut durumu.
        -- Örnek: Requested, PendingApproval, Approved, Rejected, Completed.
        RequestStatus   VARCHAR(30)       NOT NULL,

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_RefundRequests_CreatedAt DEFAULT (SYSUTCDATETIME()),

        -- Talebin sonuçlandığı zaman (UTC).
        ResolvedAt      DATETIME2(0)      NULL,

        CONSTRAINT PK_RefundRequests
            PRIMARY KEY (RefundRequestId),

        -- Talep numarasının benzersiz olmasını sağlar.
        CONSTRAINT UQ_RefundRequests_RequestNumber
            UNIQUE (RequestNumber),

        -- Negatif veya sıfır iade tutarını engeller.
        CONSTRAINT CK_RefundRequests_RequestedAmount
            CHECK (RequestedAmount > 0),

        -- İade talebini geçerli bir siparişe bağlar.
        CONSTRAINT FK_RefundRequests_Orders
            FOREIGN KEY (OrderId)
            REFERENCES Sales.Orders (OrderId)
    );
END
GO


-- İade talebi üzerinde gerçekleştirilen işlemler.
IF OBJECT_ID(N'Operations.RefundActions', N'U') IS NULL
BEGIN
    CREATE TABLE Operations.RefundActions
    (
        -- Teknik benzersiz kimlik.
        RefundActionId  INT IDENTITY(1,1) NOT NULL,

        -- İşlemin bağlı olduğu iade talebi.
        RefundRequestId INT               NOT NULL,

        -- Gerçekleştirilen işlem türü.
        -- Örnek: Submitted, Reviewed, Approved, Rejected, Refunded.
        ActionType      VARCHAR(30)       NOT NULL,

        -- İşlemin insan, AI veya sistem tarafından yapıldığını belirtir.
        ActorType       VARCHAR(30)       NOT NULL,

        -- İşleme ait kısa açıklama veya gerekçe.
        Notes           NVARCHAR(1000)    NULL,

        -- İşlemin gerçekleştiği zaman (UTC).
        CreatedAt       DATETIME2(0)      NOT NULL
            CONSTRAINT DF_RefundActions_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_RefundActions
            PRIMARY KEY (RefundActionId),

        -- İşlemi geçerli bir iade talebine bağlar.
        CONSTRAINT FK_RefundActions_RefundRequests
            FOREIGN KEY (RefundRequestId)
            REFERENCES Operations.RefundRequests (RefundRequestId)
    );
END
GO


-- ============================================================================
-- SOURCE: 12-create-ai-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Bir AI isteğinin baştan sona çalışma kaydı.
IF OBJECT_ID(N'AI.Runs', N'U') IS NULL
BEGIN
    CREATE TABLE AI.Runs
    (
        -- Teknik benzersiz kimlik.
        RunId           BIGINT IDENTITY(1,1) NOT NULL,

        -- Uygulama genelinde isteği takip etmek için kullanılan benzersiz kimlik.
        CorrelationId   UNIQUEIDENTIFIER     NOT NULL
            CONSTRAINT DF_AIRuns_CorrelationId DEFAULT (NEWID()),

        -- Kullanılan AI sağlayıcısı.
        -- Örnek: OpenAI, Anthropic, Google.
        Provider        VARCHAR(50)          NOT NULL,

        -- Kullanılan model.
        ModelName       VARCHAR(100)         NOT NULL,

        -- AI çalışmasının amacı.
        -- Örnek: SupportReply, Classification, RefundReview.
        Purpose         VARCHAR(100)         NOT NULL,

        -- Çalışmanın mevcut durumu.
        -- Örnek: Running, Completed, Failed.
        RunStatus       VARCHAR(30)          NOT NULL,

        -- Modele gönderilen toplam token sayısı.
        InputTokens     INT                  NULL,

        -- Model tarafından üretilen toplam token sayısı.
        OutputTokens    INT                  NULL,

        -- Çalışmanın tahmini maliyeti.
        CostUsd         DECIMAL(18,6)        NULL,

        -- Toplam çalışma süresi (milisaniye).
        LatencyMs       INT                  NULL,

        -- Hata oluştuysa hata açıklaması.
        ErrorMessage    NVARCHAR(2000)       NULL,

        -- Çalışmanın başladığı zaman (UTC).
        StartedAt       DATETIME2(3)         NOT NULL
            CONSTRAINT DF_AIRuns_StartedAt DEFAULT (SYSUTCDATETIME()),

        -- Çalışmanın tamamlandığı zaman (UTC).
        CompletedAt     DATETIME2(3)         NULL,

        CONSTRAINT PK_AIRuns
            PRIMARY KEY (RunId),

        -- CorrelationId değerinin benzersiz olmasını sağlar.
        CONSTRAINT UQ_AIRuns_CorrelationId
            UNIQUE (CorrelationId),

        -- Token, maliyet ve latency değerlerinin negatif olmasını engeller.
        CONSTRAINT CK_AIRuns_InputTokens
            CHECK (InputTokens IS NULL OR InputTokens >= 0),

        CONSTRAINT CK_AIRuns_OutputTokens
            CHECK (OutputTokens IS NULL OR OutputTokens >= 0),

        CONSTRAINT CK_AIRuns_CostUsd
            CHECK (CostUsd IS NULL OR CostUsd >= 0),

        CONSTRAINT CK_AIRuns_LatencyMs
            CHECK (LatencyMs IS NULL OR LatencyMs >= 0),

        -- Bitiş zamanının başlangıçtan önce olmasını engeller.
        CONSTRAINT CK_AIRuns_Dates
            CHECK (CompletedAt IS NULL OR CompletedAt >= StartedAt)
    );
END
GO


-- AI çalışması sırasında kullanılan mesajlar.
IF OBJECT_ID(N'AI.Messages', N'U') IS NULL
BEGIN
    CREATE TABLE AI.Messages
    (
        -- Teknik benzersiz kimlik.
        MessageId       BIGINT IDENTITY(1,1) NOT NULL,

        -- Mesajın bağlı olduğu AI çalışması.
        RunId           BIGINT               NOT NULL,

        -- Mesajın çalışma içindeki sırası.
        SequenceNumber  INT                  NOT NULL,

        -- Mesaj rolü.
        -- Örnek: system, user, assistant, tool.
        Role            VARCHAR(30)          NOT NULL,

        -- Mesaj içeriği.
        Content         NVARCHAR(MAX)        NOT NULL,

        -- Mesajın oluşturulma zamanı (UTC).
        CreatedAt       DATETIME2(3)         NOT NULL
            CONSTRAINT DF_AIMessages_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_AIMessages
            PRIMARY KEY (MessageId),

        -- Aynı run içinde aynı sıra numarasının tekrar kullanılmasını engeller.
        CONSTRAINT UQ_AIMessages_Run_Sequence
            UNIQUE (RunId, SequenceNumber),

        -- Sıra numarasının negatif olmasını engeller.
        CONSTRAINT CK_AIMessages_SequenceNumber
            CHECK (SequenceNumber >= 0),

        -- Mesajı geçerli bir AI çalışmasına bağlar.
        CONSTRAINT FK_AIMessages_Runs
            FOREIGN KEY (RunId)
            REFERENCES AI.Runs (RunId)
    );
END
GO


-- RAG sırasında AI çalışmasına getirilen doküman parçaları.
IF OBJECT_ID(N'AI.Retrievals', N'U') IS NULL
BEGIN
    CREATE TABLE AI.Retrievals
    (
        -- Teknik benzersiz kimlik.
        RetrievalId     BIGINT IDENTITY(1,1) NOT NULL,

        -- Retrieval işleminin bağlı olduğu AI çalışması.
        RunId           BIGINT               NOT NULL,

        -- Bulunan bilgi parçası.
        DocumentChunkId INT                  NOT NULL,

        -- Sonucun retrieval sıralamasındaki yeri.
        RankPosition    INT                  NOT NULL,

        -- Retrieval benzerlik veya relevance skoru.
        Score           DECIMAL(18,8)        NULL,

        -- Retrieval işleminin gerçekleştiği zaman (UTC).
        RetrievedAt     DATETIME2(3)         NOT NULL
            CONSTRAINT DF_AIRetrievals_RetrievedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_AIRetrievals
            PRIMARY KEY (RetrievalId),

        -- Aynı run içinde aynı chunk'ın tekrar kaydedilmesini engeller.
        CONSTRAINT UQ_AIRetrievals_Run_Chunk
            UNIQUE (RunId, DocumentChunkId),

        -- Retrieval sırasının sıfırdan büyük olmasını sağlar.
        CONSTRAINT CK_AIRetrievals_RankPosition
            CHECK (RankPosition > 0),

        -- Retrieval kaydını AI çalışmasına bağlar.
        CONSTRAINT FK_AIRetrievals_Runs
            FOREIGN KEY (RunId)
            REFERENCES AI.Runs (RunId),

        -- Retrieval sonucunu bilgi kaynağına bağlar.
        CONSTRAINT FK_AIRetrievals_DocumentChunks
            FOREIGN KEY (DocumentChunkId)
            REFERENCES Knowledge.DocumentChunks (DocumentChunkId)
    );
END
GO


-- AI tarafından çağrılan araçların çalışma kayıtları.
IF OBJECT_ID(N'AI.ToolExecutions', N'U') IS NULL
BEGIN
    CREATE TABLE AI.ToolExecutions
    (
        -- Teknik benzersiz kimlik.
        ToolExecutionId BIGINT IDENTITY(1,1) NOT NULL,

        -- Tool çağrısının bağlı olduğu AI çalışması.
        RunId           BIGINT               NOT NULL,

        -- Tool çağrısının çalışma içindeki sırası.
        SequenceNumber  INT                  NOT NULL,

        -- Çağrılan tool adı.
        ToolName        VARCHAR(150)         NOT NULL,

        -- Tool'a gönderilen argümanlar.
        ArgumentsJson   NVARCHAR(MAX)        NULL,

        -- Tool çalışmasının sonucu.
        ResultJson      NVARCHAR(MAX)        NULL,

        -- Tool çalışma durumu.
        -- Örnek: Running, Completed, Failed.
        ExecutionStatus VARCHAR(30)          NOT NULL,

        -- Hata oluştuysa hata açıklaması.
        ErrorMessage    NVARCHAR(2000)       NULL,

        -- Tool çağrısının başladığı zaman (UTC).
        StartedAt       DATETIME2(3)         NOT NULL
            CONSTRAINT DF_AIToolExecutions_StartedAt DEFAULT (SYSUTCDATETIME()),

        -- Tool çağrısının tamamlandığı zaman (UTC).
        CompletedAt     DATETIME2(3)         NULL,

        CONSTRAINT PK_AIToolExecutions
            PRIMARY KEY (ToolExecutionId),

        -- Aynı run içinde aynı sıra numarasının tekrar kullanılmasını engeller.
        CONSTRAINT UQ_AIToolExecutions_Run_Sequence
            UNIQUE (RunId, SequenceNumber),

        CONSTRAINT CK_AIToolExecutions_SequenceNumber
            CHECK (SequenceNumber >= 0),

        -- Bitiş zamanının başlangıçtan önce olmasını engeller.
        CONSTRAINT CK_AIToolExecutions_Dates
            CHECK (CompletedAt IS NULL OR CompletedAt >= StartedAt),

        -- Tool çağrısını geçerli bir AI çalışmasına bağlar.
        CONSTRAINT FK_AIToolExecutions_Runs
            FOREIGN KEY (RunId)
            REFERENCES AI.Runs (RunId)
    );
END
GO


-- ============================================================================
-- SOURCE: 13-create-evaluation-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- AI sisteminin beklenen davranışını tanımlayan test senaryoları.
IF OBJECT_ID(N'Evaluation.Cases', N'U') IS NULL
BEGIN
    CREATE TABLE Evaluation.Cases
    (
        -- Teknik benzersiz kimlik.
        EvaluationCaseId INT IDENTITY(1,1) NOT NULL,

        -- Test senaryosunun benzersiz kodu.
        CaseCode         VARCHAR(50)       NOT NULL,

        -- Test senaryosunun adı.
        CaseName         NVARCHAR(200)     NOT NULL,

        -- Test edilen yetenek veya davranış.
        -- Örnek: Retrieval, ToolCall, Classification, SupportReply.
        EvaluationType   VARCHAR(50)       NOT NULL,

        -- Modele veya sisteme verilen test girdisi.
        InputText        NVARCHAR(MAX)     NOT NULL,

        -- Beklenen davranış veya sonuç açıklaması.
        ExpectedOutcome  NVARCHAR(MAX)     NOT NULL,

        -- Test senaryosunun aktiflik durumu.
        IsActive         BIT               NOT NULL
            CONSTRAINT DF_EvaluationCases_IsActive DEFAULT (1),

        -- Kaydın oluşturulma zamanı (UTC).
        CreatedAt        DATETIME2(0)      NOT NULL
            CONSTRAINT DF_EvaluationCases_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_EvaluationCases
            PRIMARY KEY (EvaluationCaseId),

        -- Test kodunun benzersiz olmasını sağlar.
        CONSTRAINT UQ_EvaluationCases_CaseCode
            UNIQUE (CaseCode)
    );
END
GO


-- Bir grup eval testinin çalıştırılmasını temsil eder.
IF OBJECT_ID(N'Evaluation.Runs', N'U') IS NULL
BEGIN
    CREATE TABLE Evaluation.Runs
    (
        -- Teknik benzersiz kimlik.
        EvaluationRunId BIGINT IDENTITY(1,1) NOT NULL,

        -- Eval çalışmasının benzersiz kimliği.
        CorrelationId   UNIQUEIDENTIFIER     NOT NULL
            CONSTRAINT DF_EvaluationRuns_CorrelationId DEFAULT (NEWID()),

        -- Çalıştırılan eval setinin veya amacının adı.
        RunName         NVARCHAR(200)        NOT NULL,

        -- Eval çalışmasının durumu.
        -- Örnek: Running, Completed, Failed.
        RunStatus       VARCHAR(30)          NOT NULL,

        -- Eval çalışmasının başladığı zaman (UTC).
        StartedAt       DATETIME2(3)         NOT NULL
            CONSTRAINT DF_EvaluationRuns_StartedAt DEFAULT (SYSUTCDATETIME()),

        -- Eval çalışmasının tamamlandığı zaman (UTC).
        CompletedAt     DATETIME2(3)         NULL,

        CONSTRAINT PK_EvaluationRuns
            PRIMARY KEY (EvaluationRunId),

        CONSTRAINT UQ_EvaluationRuns_CorrelationId
            UNIQUE (CorrelationId),

        -- Bitiş zamanının başlangıçtan önce olmasını engeller.
        CONSTRAINT CK_EvaluationRuns_Dates
            CHECK (CompletedAt IS NULL OR CompletedAt >= StartedAt)
    );
END
GO


-- Her eval senaryosunun çalışma sonucunu temsil eder.
IF OBJECT_ID(N'Evaluation.Results', N'U') IS NULL
BEGIN
    CREATE TABLE Evaluation.Results
    (
        -- Teknik benzersiz kimlik.
        EvaluationResultId BIGINT IDENTITY(1,1) NOT NULL,

        -- Sonucun bağlı olduğu eval çalışması.
        EvaluationRunId    BIGINT               NOT NULL,

        -- Çalıştırılan test senaryosu.
        EvaluationCaseId   INT                  NOT NULL,

        -- Varsa değerlendirilen gerçek AI çalışması.
        AIRunId            BIGINT               NULL,

        -- Testin başarılı olup olmadığını belirtir.
        Passed             BIT                  NOT NULL,

        -- Sayısal değerlendirme skoru.
        Score              DECIMAL(9,6)         NULL,

        -- Gerçekleşen davranış veya çıktı.
        ActualOutcome      NVARCHAR(MAX)        NULL,

        -- Sonucun açıklaması veya değerlendirme gerekçesi.
        Notes              NVARCHAR(2000)       NULL,

        -- Sonucun oluşturulma zamanı (UTC).
        CreatedAt          DATETIME2(3)         NOT NULL
            CONSTRAINT DF_EvaluationResults_CreatedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_EvaluationResults
            PRIMARY KEY (EvaluationResultId),

        -- Aynı eval run içinde aynı test senaryosunun tekrar kaydedilmesini engeller.
        CONSTRAINT UQ_EvaluationResults_Run_Case
            UNIQUE (EvaluationRunId, EvaluationCaseId),

        -- Skor varsa 0 ile 1 arasında olmasını sağlar.
        CONSTRAINT CK_EvaluationResults_Score
            CHECK (Score IS NULL OR (Score >= 0 AND Score <= 1)),

        -- Sonucu eval çalışmasına bağlar.
        CONSTRAINT FK_EvaluationResults_Runs
            FOREIGN KEY (EvaluationRunId)
            REFERENCES Evaluation.Runs (EvaluationRunId),

        -- Sonucu test senaryosuna bağlar.
        CONSTRAINT FK_EvaluationResults_Cases
            FOREIGN KEY (EvaluationCaseId)
            REFERENCES Evaluation.Cases (EvaluationCaseId),

        -- Sonucu varsa gerçek AI çalışmasına bağlar.
        CONSTRAINT FK_EvaluationResults_AIRuns
            FOREIGN KEY (AIRunId)
            REFERENCES AI.Runs (RunId)
    );
END
GO


-- ============================================================================
-- SOURCE: 14-create-governance-tables.sql
-- ============================================================================

USE NorthstarOps;
GO

-- Kritik iade işlemleri için insan onayı kayıtları.
IF OBJECT_ID(N'Governance.HumanApprovals', N'U') IS NULL
BEGIN
    CREATE TABLE Governance.HumanApprovals
    (
        -- Teknik benzersiz kimlik.
        HumanApprovalId      BIGINT IDENTITY(1,1) NOT NULL,

        -- Onay gerektiren iade talebi.
        RefundRequestId      INT                  NOT NULL,

        -- Onayın mevcut durumu.
        -- Örnek: Pending, Approved, Rejected.
        ApprovalStatus       VARCHAR(30)          NOT NULL,

        -- Kararı veren çalışan.
        -- Talep henüz incelenmediyse NULL olabilir.
        ReviewedByEmployeeId INT                  NULL,

        -- Onay veya red gerekçesi.
        DecisionNotes        NVARCHAR(2000)       NULL,

        -- Onay talebinin oluşturulma zamanı (UTC).
        RequestedAt          DATETIME2(3)         NOT NULL
            CONSTRAINT DF_HumanApprovals_RequestedAt
            DEFAULT (SYSUTCDATETIME()),

        -- Kararın verildiği zaman (UTC).
        ReviewedAt           DATETIME2(3)         NULL,

        CONSTRAINT PK_HumanApprovals
            PRIMARY KEY (HumanApprovalId),

        -- Onayı gerçek bir iade talebine bağlar.
        CONSTRAINT FK_HumanApprovals_RefundRequests
            FOREIGN KEY (RefundRequestId)
            REFERENCES Operations.RefundRequests (RefundRequestId),

        -- Kararı veren kişiyi gerçek bir çalışan kaydına bağlar.
        CONSTRAINT FK_HumanApprovals_Employees
            FOREIGN KEY (ReviewedByEmployeeId)
            REFERENCES Organization.Employees (EmployeeId),

        -- Karar zamanının talep zamanından önce olmasını engeller.
        CONSTRAINT CK_HumanApprovals_Dates
            CHECK (ReviewedAt IS NULL OR ReviewedAt >= RequestedAt),

        -- Approved veya Rejected durumunda reviewer ve karar tarihi zorunludur.
        CONSTRAINT CK_HumanApprovals_Reviewed
            CHECK (
                ApprovalStatus NOT IN ('Approved', 'Rejected')
                OR (
                    ReviewedByEmployeeId IS NOT NULL
                    AND ReviewedAt IS NOT NULL
                )
            )
    );
END
GO


-- Sistem içindeki önemli işlemlerin audit kayıtları.
IF OBJECT_ID(N'Governance.AuditEvents', N'U') IS NULL
BEGIN
    CREATE TABLE Governance.AuditEvents
    (
        -- Teknik benzersiz kimlik.
        AuditEventId    BIGINT IDENTITY(1,1) NOT NULL,

        -- İşlemi yapan tarafın türü.
        -- Örnek: User, AI, System.
        ActorType       VARCHAR(30)          NOT NULL,

        -- İşlemi yapan kullanıcının kimliği.
        -- ASP.NET Core Identity daha sonra eklenecektir.
        ActorUserId     NVARCHAR(450)        NULL,

        -- İşlem AI tarafından yapıldıysa ilgili AI çalışması.
        AIRunId         BIGINT               NULL,

        -- Gerçekleştirilen işlem.
        EventType       VARCHAR(100)         NOT NULL,

        -- İşlemden etkilenen varlık türü.
        EntityType      VARCHAR(50)          NULL,

        -- İşlemden etkilenen kaydın kimliği.
        EntityId        BIGINT               NULL,

        -- Audit olayına ait ek veri.
        DetailsJson     NVARCHAR(MAX)        NULL,

        -- Olayın gerçekleştiği zaman (UTC).
        CreatedAt       DATETIME2(3)         NOT NULL
            CONSTRAINT DF_AuditEvents_CreatedAt
            DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_AuditEvents
            PRIMARY KEY (AuditEventId),

        -- Audit olayını varsa ilgili AI çalışmasına bağlar.
        CONSTRAINT FK_AuditEvents_AIRuns
            FOREIGN KEY (AIRunId)
            REFERENCES AI.Runs (RunId)
    );
END
GO


-- ============================================================================
-- SOURCE: 15-create-indexes.sql
-- ============================================================================

USE NorthstarOps;
GO

-- =========================================================
-- ORGANIZATION
-- =========================================================

-- Çalışanları yöneticilerine göre bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Employees_ManagerEmployeeId'
      AND object_id = OBJECT_ID(N'Organization.Employees')
)
    CREATE INDEX IX_Employees_ManagerEmployeeId
        ON Organization.Employees (ManagerEmployeeId);
GO

-- Bir departmandaki çalışanları bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_EmployeeDepartments_DepartmentId'
      AND object_id = OBJECT_ID(N'Organization.EmployeeDepartments')
)
    CREATE INDEX IX_EmployeeDepartments_DepartmentId
        ON Organization.EmployeeDepartments (DepartmentId);
GO


-- =========================================================
-- CATALOG
-- =========================================================

-- Ürünleri kategoriye göre listelemeyi hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Products_CategoryId'
      AND object_id = OBJECT_ID(N'Catalog.Products')
)
    CREATE INDEX IX_Products_CategoryId
        ON Catalog.Products (CategoryId);
GO


-- =========================================================
-- SALES
-- =========================================================

-- Müşterinin sipariş geçmişini tarih sırasıyla sorgulamayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Orders_CustomerId_OrderedAt'
      AND object_id = OBJECT_ID(N'Sales.Orders')
)
    CREATE INDEX IX_Orders_CustomerId_OrderedAt
        ON Sales.Orders (CustomerId, OrderedAt DESC);
GO

-- Sipariş kalemlerini siparişe göre bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_OrderItems_OrderId'
      AND object_id = OBJECT_ID(N'Sales.OrderItems')
)
    CREATE INDEX IX_OrderItems_OrderId
        ON Sales.OrderItems (OrderId);
GO

-- Bir ürünün hangi siparişlerde yer aldığını bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_OrderItems_ProductId'
      AND object_id = OBJECT_ID(N'Sales.OrderItems')
)
    CREATE INDEX IX_OrderItems_ProductId
        ON Sales.OrderItems (ProductId);
GO

-- Siparişe ait ödemeleri bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Payments_OrderId'
      AND object_id = OBJECT_ID(N'Sales.Payments')
)
    CREATE INDEX IX_Payments_OrderId
        ON Sales.Payments (OrderId);
GO

-- Müşterinin iletişim kişilerini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_CustomerContacts_CustomerId'
      AND object_id = OBJECT_ID(N'Sales.CustomerContacts')
)
    CREATE INDEX IX_CustomerContacts_CustomerId
        ON Sales.CustomerContacts (CustomerId);
GO

-- Müşterinin adreslerini türüne göre bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_CustomerAddresses_CustomerId_AddressType'
      AND object_id = OBJECT_ID(N'Sales.CustomerAddresses')
)
    CREATE INDEX IX_CustomerAddresses_CustomerId_AddressType
        ON Sales.CustomerAddresses (CustomerId, AddressType);
GO


-- =========================================================
-- PROCUREMENT
-- =========================================================

-- Tedarikçinin satın alma siparişlerini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PurchaseOrders_SupplierId_OrderedAt'
      AND object_id = OBJECT_ID(N'Procurement.PurchaseOrders')
)
    CREATE INDEX IX_PurchaseOrders_SupplierId_OrderedAt
        ON Procurement.PurchaseOrders (SupplierId, OrderedAt DESC);
GO

-- Çalışanın sorumlu olduğu satın alma siparişlerini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PurchaseOrders_EmployeeId'
      AND object_id = OBJECT_ID(N'Procurement.PurchaseOrders')
)
    CREATE INDEX IX_PurchaseOrders_EmployeeId
        ON Procurement.PurchaseOrders (EmployeeId);
GO

-- Satın alma siparişinin kalemlerini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PurchaseOrderItems_PurchaseOrderId'
      AND object_id = OBJECT_ID(N'Procurement.PurchaseOrderItems')
)
    CREATE INDEX IX_PurchaseOrderItems_PurchaseOrderId
        ON Procurement.PurchaseOrderItems (PurchaseOrderId);
GO

-- Bir ürünün satın alma geçmişini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PurchaseOrderItems_ProductId'
      AND object_id = OBJECT_ID(N'Procurement.PurchaseOrderItems')
)
    CREATE INDEX IX_PurchaseOrderItems_ProductId
        ON Procurement.PurchaseOrderItems (ProductId);
GO

-- Bir ürünün alternatif tedarikçilerini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_SupplierProducts_ProductId'
      AND object_id = OBJECT_ID(N'Procurement.SupplierProducts')
)
    CREATE INDEX IX_SupplierProducts_ProductId
        ON Procurement.SupplierProducts (ProductId)
        INCLUDE (SupplierId, UnitCost, LeadTimeDays, IsActive);
GO

-- Satın alma siparişinin teslim alma kayıtlarını bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PurchaseReceipts_PurchaseOrderId'
      AND object_id = OBJECT_ID(N'Procurement.PurchaseReceipts')
)
    CREATE INDEX IX_PurchaseReceipts_PurchaseOrderId
        ON Procurement.PurchaseReceipts (PurchaseOrderId);
GO

-- Depoya yapılan satın alma girişlerini sorgulamayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PurchaseReceipts_WarehouseId_ReceivedAt'
      AND object_id = OBJECT_ID(N'Procurement.PurchaseReceipts')
)
    CREATE INDEX IX_PurchaseReceipts_WarehouseId_ReceivedAt
        ON Procurement.PurchaseReceipts (WarehouseId, ReceivedAt DESC);
GO

-- Teslim alınan satın alma kalemlerini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PurchaseReceiptItems_PurchaseOrderItemId'
      AND object_id = OBJECT_ID(N'Procurement.PurchaseReceiptItems')
)
    CREATE INDEX IX_PurchaseReceiptItems_PurchaseOrderItemId
        ON Procurement.PurchaseReceiptItems (PurchaseOrderItemId);
GO


-- =========================================================
-- INVENTORY
-- =========================================================

-- Bir ürünün bütün depolardaki stok durumunu bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_StockLevels_ProductId'
      AND object_id = OBJECT_ID(N'Inventory.StockLevels')
)
    CREATE INDEX IX_StockLevels_ProductId
        ON Inventory.StockLevels (ProductId)
        INCLUDE (WarehouseId, QuantityOnHand, QuantityReserved);
GO

-- Bir ürünün stok hareket geçmişini sorgulamayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_InventoryMovements_ProductId_CreatedAt'
      AND object_id = OBJECT_ID(N'Inventory.InventoryMovements')
)
    CREATE INDEX IX_InventoryMovements_ProductId_CreatedAt
        ON Inventory.InventoryMovements (ProductId, CreatedAt DESC);
GO

-- Bir deponun stok hareketlerini sorgulamayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_InventoryMovements_WarehouseId_CreatedAt'
      AND object_id = OBJECT_ID(N'Inventory.InventoryMovements')
)
    CREATE INDEX IX_InventoryMovements_WarehouseId_CreatedAt
        ON Inventory.InventoryMovements (WarehouseId, CreatedAt DESC);
GO

-- Bir iş kaynağına bağlı stok hareketlerini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_InventoryMovements_Reference'
      AND object_id = OBJECT_ID(N'Inventory.InventoryMovements')
)
    CREATE INDEX IX_InventoryMovements_Reference
        ON Inventory.InventoryMovements (ReferenceType, ReferenceId);
GO


-- =========================================================
-- FULFILLMENT
-- =========================================================

-- Siparişe ait sevkiyatları bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Shipments_OrderId'
      AND object_id = OBJECT_ID(N'Fulfillment.Shipments')
)
    CREATE INDEX IX_Shipments_OrderId
        ON Fulfillment.Shipments (OrderId);
GO

-- Depodan çıkan sevkiyatları sorgulamayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Shipments_WarehouseId_CreatedAt'
      AND object_id = OBJECT_ID(N'Fulfillment.Shipments')
)
    CREATE INDEX IX_Shipments_WarehouseId_CreatedAt
        ON Fulfillment.Shipments (WarehouseId, CreatedAt DESC);
GO

-- Takip numarasıyla sevkiyat aramayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Shipments_TrackingNumber'
      AND object_id = OBJECT_ID(N'Fulfillment.Shipments')
)
    CREATE INDEX IX_Shipments_TrackingNumber
        ON Fulfillment.Shipments (TrackingNumber)
        WHERE TrackingNumber IS NOT NULL;
GO

-- Sipariş kaleminin hangi sevkiyatlarda bulunduğunu bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_ShipmentItems_OrderItemId'
      AND object_id = OBJECT_ID(N'Fulfillment.ShipmentItems')
)
    CREATE INDEX IX_ShipmentItems_OrderItemId
        ON Fulfillment.ShipmentItems (OrderItemId);
GO


-- =========================================================
-- SUPPORT
-- =========================================================

-- Müşterinin destek taleplerini tarih sırasıyla bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Tickets_CustomerId_CreatedAt'
      AND object_id = OBJECT_ID(N'Support.Tickets')
)
    CREATE INDEX IX_Tickets_CustomerId_CreatedAt
        ON Support.Tickets (CustomerId, CreatedAt DESC);
GO

-- Siparişle ilişkili destek taleplerini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Tickets_OrderId'
      AND object_id = OBJECT_ID(N'Support.Tickets')
)
    CREATE INDEX IX_Tickets_OrderId
        ON Support.Tickets (OrderId)
        WHERE OrderId IS NOT NULL;
GO

-- Açık destek taleplerini durum ve önceliğe göre sorgulamayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Tickets_Status_Priority_CreatedAt'
      AND object_id = OBJECT_ID(N'Support.Tickets')
)
    CREATE INDEX IX_Tickets_Status_Priority_CreatedAt
        ON Support.Tickets (TicketStatus, Priority, CreatedAt DESC);
GO

-- Ticket konuşma geçmişini kronolojik getirmeyi hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_TicketMessages_TicketId_CreatedAt'
      AND object_id = OBJECT_ID(N'Support.TicketMessages')
)
    CREATE INDEX IX_TicketMessages_TicketId_CreatedAt
        ON Support.TicketMessages (TicketId, CreatedAt);
GO


-- =========================================================
-- KNOWLEDGE
-- =========================================================

-- Dokümanları tür ve aktiflik durumuna göre bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Documents_DocumentType_IsActive'
      AND object_id = OBJECT_ID(N'Knowledge.Documents')
)
    CREATE INDEX IX_Documents_DocumentType_IsActive
        ON Knowledge.Documents (DocumentType, IsActive);
GO

-- Bir dokümanın geçerli sürümünü zaman üzerinden bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_DocumentVersions_DocumentId_EffectiveFrom'
      AND object_id = OBJECT_ID(N'Knowledge.DocumentVersions')
)
    CREATE INDEX IX_DocumentVersions_DocumentId_EffectiveFrom
        ON Knowledge.DocumentVersions (DocumentId, EffectiveFrom DESC)
        INCLUDE (EffectiveTo);
GO


-- =========================================================
-- OPERATIONS
-- =========================================================

-- Siparişe ait iade taleplerini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_RefundRequests_OrderId_CreatedAt'
      AND object_id = OBJECT_ID(N'Operations.RefundRequests')
)
    CREATE INDEX IX_RefundRequests_OrderId_CreatedAt
        ON Operations.RefundRequests (OrderId, CreatedAt DESC);
GO

-- Bekleyen iade taleplerini sorgulamayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_RefundRequests_Status_CreatedAt'
      AND object_id = OBJECT_ID(N'Operations.RefundRequests')
)
    CREATE INDEX IX_RefundRequests_Status_CreatedAt
        ON Operations.RefundRequests (RequestStatus, CreatedAt DESC);
GO

-- Bir iade talebinin işlem geçmişini getirir.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_RefundActions_RefundRequestId_CreatedAt'
      AND object_id = OBJECT_ID(N'Operations.RefundActions')
)
    CREATE INDEX IX_RefundActions_RefundRequestId_CreatedAt
        ON Operations.RefundActions (RefundRequestId, CreatedAt);
GO


-- =========================================================
-- AI
-- =========================================================

-- AI çalışmalarını amaç ve zamana göre sorgulamayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_AIRuns_Purpose_StartedAt'
      AND object_id = OBJECT_ID(N'AI.Runs')
)
    CREATE INDEX IX_AIRuns_Purpose_StartedAt
        ON AI.Runs (Purpose, StartedAt DESC);
GO

-- Başarısız veya devam eden AI çalışmalarını bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_AIRuns_RunStatus_StartedAt'
      AND object_id = OBJECT_ID(N'AI.Runs')
)
    CREATE INDEX IX_AIRuns_RunStatus_StartedAt
        ON AI.Runs (RunStatus, StartedAt DESC);
GO

-- Retrieval kayıtlarını AI çalışmasına ve sıralamasına göre getirir.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_AIRetrievals_RunId_RankPosition'
      AND object_id = OBJECT_ID(N'AI.Retrievals')
)
    CREATE INDEX IX_AIRetrievals_RunId_RankPosition
        ON AI.Retrievals (RunId, RankPosition);
GO

-- Bir chunk'ın hangi AI çalışmalarında kullanıldığını bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_AIRetrievals_DocumentChunkId'
      AND object_id = OBJECT_ID(N'AI.Retrievals')
)
    CREATE INDEX IX_AIRetrievals_DocumentChunkId
        ON AI.Retrievals (DocumentChunkId);
GO

-- Tool çağrılarını tool adına ve zamana göre analiz etmeyi hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_AIToolExecutions_ToolName_StartedAt'
      AND object_id = OBJECT_ID(N'AI.ToolExecutions')
)
    CREATE INDEX IX_AIToolExecutions_ToolName_StartedAt
        ON AI.ToolExecutions (ToolName, StartedAt DESC);
GO


-- =========================================================
-- EVALUATION
-- =========================================================

-- Eval case'lerini türüne göre bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_EvaluationCases_Type_IsActive'
      AND object_id = OBJECT_ID(N'Evaluation.Cases')
)
    CREATE INDEX IX_EvaluationCases_Type_IsActive
        ON Evaluation.Cases (EvaluationType, IsActive);
GO

-- Eval çalışmalarını tarih sırasıyla sorgulamayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_EvaluationRuns_StartedAt'
      AND object_id = OBJECT_ID(N'Evaluation.Runs')
)
    CREATE INDEX IX_EvaluationRuns_StartedAt
        ON Evaluation.Runs (StartedAt DESC);
GO

-- Bir AI çalışmasına ait eval sonuçlarını bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_EvaluationResults_AIRunId'
      AND object_id = OBJECT_ID(N'Evaluation.Results')
)
    CREATE INDEX IX_EvaluationResults_AIRunId
        ON Evaluation.Results (AIRunId)
        WHERE AIRunId IS NOT NULL;
GO


-- =========================================================
-- GOVERNANCE
-- =========================================================

-- Bekleyen insan onaylarını hızlı bulmayı sağlar.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_HumanApprovals_Status_RequestedAt'
      AND object_id = OBJECT_ID(N'Governance.HumanApprovals')
)
    CREATE INDEX IX_HumanApprovals_Status_RequestedAt
        ON Governance.HumanApprovals (ApprovalStatus, RequestedAt);
GO

-- Bir iade talebine ait insan onaylarını bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_HumanApprovals_RefundRequestId'
      AND object_id = OBJECT_ID(N'Governance.HumanApprovals')
)
    CREATE INDEX IX_HumanApprovals_RefundRequestId
        ON Governance.HumanApprovals (RefundRequestId, RequestedAt DESC);
GO

-- Bir çalışanın verdiği onay kararlarını bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_HumanApprovals_ReviewedByEmployeeId'
      AND object_id = OBJECT_ID(N'Governance.HumanApprovals')
)
    CREATE INDEX IX_HumanApprovals_ReviewedByEmployeeId
        ON Governance.HumanApprovals (ReviewedByEmployeeId, ReviewedAt DESC)
        WHERE ReviewedByEmployeeId IS NOT NULL;
GO

-- Bir iş kaydının audit geçmişini bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_AuditEvents_Entity'
      AND object_id = OBJECT_ID(N'Governance.AuditEvents')
)
    CREATE INDEX IX_AuditEvents_Entity
        ON Governance.AuditEvents (EntityType, EntityId, CreatedAt DESC);
GO

-- AI kaynaklı audit olaylarını bulmayı hızlandırır.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_AuditEvents_AIRunId'
      AND object_id = OBJECT_ID(N'Governance.AuditEvents')
)
    CREATE INDEX IX_AuditEvents_AIRunId
        ON Governance.AuditEvents (AIRunId)
        WHERE AIRunId IS NOT NULL;
GO


-- ============================================================================
-- SOURCE: 16-seed-reference-data.sql
-- ============================================================================

USE NorthstarOps;
GO

-- =========================================================
-- ORGANIZATION
-- =========================================================

-- Temel departmanlar.
IF NOT EXISTS (
    SELECT 1
    FROM Organization.Departments
    WHERE DepartmentCode = 'EXEC'
)
BEGIN
    INSERT INTO Organization.Departments
        (DepartmentCode, DepartmentName, Description)
    VALUES
        ('EXEC', N'Executive', N'Şirket yönetimi ve karar süreçleri.');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Organization.Departments
    WHERE DepartmentCode = 'SALES'
)
BEGIN
    INSERT INTO Organization.Departments
        (DepartmentCode, DepartmentName, Description)
    VALUES
        ('SALES', N'Sales', N'Müşteri kazanımı ve satış süreçleri.');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Organization.Departments
    WHERE DepartmentCode = 'SUPPORT'
)
BEGIN
    INSERT INTO Organization.Departments
        (DepartmentCode, DepartmentName, Description)
    VALUES
        ('SUPPORT', N'Customer Support', N'Müşteri destek ve çözüm süreçleri.');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Organization.Departments
    WHERE DepartmentCode = 'PROC'
)
BEGIN
    INSERT INTO Organization.Departments
        (DepartmentCode, DepartmentName, Description)
    VALUES
        ('PROC', N'Procurement', N'Tedarikçi ve satın alma süreçleri.');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Organization.Departments
    WHERE DepartmentCode = 'OPS'
)
BEGIN
    INSERT INTO Organization.Departments
        (DepartmentCode, DepartmentName, Description)
    VALUES
        ('OPS', N'Operations', N'Depo, stok ve fulfillment operasyonları.');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Organization.Departments
    WHERE DepartmentCode = 'TECH'
)
BEGIN
    INSERT INTO Organization.Departments
        (DepartmentCode, DepartmentName, Description)
    VALUES
        ('TECH', N'Technology', N'Yazılım, veri ve AI sistemleri.');
END
GO


-- =========================================================
-- CATALOG
-- =========================================================

-- Temel ürün kategorileri.
IF NOT EXISTS (
    SELECT 1
    FROM Catalog.Categories
    WHERE CategoryName = N'Laptops'
)
BEGIN
    INSERT INTO Catalog.Categories
        (CategoryName, Description)
    VALUES
        (N'Laptops', N'Kurumsal ve profesyonel dizüstü bilgisayarlar.');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Catalog.Categories
    WHERE CategoryName = N'Monitors'
)
BEGIN
    INSERT INTO Catalog.Categories
        (CategoryName, Description)
    VALUES
        (N'Monitors', N'Profesyonel masaüstü ekran çözümleri.');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Catalog.Categories
    WHERE CategoryName = N'Networking'
)
BEGIN
    INSERT INTO Catalog.Categories
        (CategoryName, Description)
    VALUES
        (N'Networking', N'Ağ, bağlantı ve kurumsal iletişim ürünleri.');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Catalog.Categories
    WHERE CategoryName = N'Storage'
)
BEGIN
    INSERT INTO Catalog.Categories
        (CategoryName, Description)
    VALUES
        (N'Storage', N'Veri depolama ve yedekleme ürünleri.');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Catalog.Categories
    WHERE CategoryName = N'Accessories'
)
BEGIN
    INSERT INTO Catalog.Categories
        (CategoryName, Description)
    VALUES
        (N'Accessories', N'Bilgisayar ve çalışma alanı aksesuarları.');
END
GO


-- =========================================================
-- INVENTORY
-- =========================================================

-- Temel depolar.
IF NOT EXISTS (
    SELECT 1
    FROM Inventory.Warehouses
    WHERE WarehouseCode = 'IST-01'
)
BEGIN
    INSERT INTO Inventory.Warehouses
        (WarehouseCode, WarehouseName, Country, City)
    VALUES
        ('IST-01', N'Istanbul Main Warehouse', N'Türkiye', N'İstanbul');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Inventory.Warehouses
    WHERE WarehouseCode = 'ANK-01'
)
BEGIN
    INSERT INTO Inventory.Warehouses
        (WarehouseCode, WarehouseName, Country, City)
    VALUES
        ('ANK-01', N'Ankara Regional Warehouse', N'Türkiye', N'Ankara');
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Inventory.Warehouses
    WHERE WarehouseCode = 'IZM-01'
)
BEGIN
    INSERT INTO Inventory.Warehouses
        (WarehouseCode, WarehouseName, Country, City)
    VALUES
        ('IZM-01', N'Izmir Regional Warehouse', N'Türkiye', N'İzmir');
END
GO


-- ============================================================================
-- SOURCE: 17-seed-sample-data.sql
-- ============================================================================

USE NorthstarOps;
GO

-- =========================================================
-- ORGANIZATION
-- =========================================================

-- CEO.
IF NOT EXISTS (
    SELECT 1 FROM Organization.Employees WHERE EmployeeCode = 'EMP-001'
)
BEGIN
    INSERT INTO Organization.Employees
        (EmployeeCode, FirstName, LastName, Email, JobTitle, ManagerEmployeeId, HireDate)
    VALUES
        ('EMP-001', N'Deniz', N'Arslan', 'deniz.arslan@northstar.local',
         N'Chief Executive Officer', NULL, '2022-01-10');
END
GO

-- Sales Manager.
IF NOT EXISTS (
    SELECT 1 FROM Organization.Employees WHERE EmployeeCode = 'EMP-002'
)
BEGIN
    INSERT INTO Organization.Employees
        (EmployeeCode, FirstName, LastName, Email, JobTitle, ManagerEmployeeId, HireDate)
    VALUES
        (
            'EMP-002',
            N'Elif',
            N'Kaya',
            'elif.kaya@northstar.local',
            N'Sales Manager',
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-001'),
            '2023-03-15'
        );
END
GO

-- Support Specialist.
IF NOT EXISTS (
    SELECT 1 FROM Organization.Employees WHERE EmployeeCode = 'EMP-003'
)
BEGIN
    INSERT INTO Organization.Employees
        (EmployeeCode, FirstName, LastName, Email, JobTitle, ManagerEmployeeId, HireDate)
    VALUES
        (
            'EMP-003',
            N'Mert',
            N'Demir',
            'mert.demir@northstar.local',
            N'Customer Support Specialist',
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-001'),
            '2024-02-01'
        );
END
GO

-- Procurement Specialist.
IF NOT EXISTS (
    SELECT 1 FROM Organization.Employees WHERE EmployeeCode = 'EMP-004'
)
BEGIN
    INSERT INTO Organization.Employees
        (EmployeeCode, FirstName, LastName, Email, JobTitle, ManagerEmployeeId, HireDate)
    VALUES
        (
            'EMP-004',
            N'Selin',
            N'Yıldız',
            'selin.yildiz@northstar.local',
            N'Procurement Specialist',
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-001'),
            '2024-05-20'
        );
END
GO

-- Operations Manager.
IF NOT EXISTS (
    SELECT 1 FROM Organization.Employees WHERE EmployeeCode = 'EMP-005'
)
BEGIN
    INSERT INTO Organization.Employees
        (EmployeeCode, FirstName, LastName, Email, JobTitle, ManagerEmployeeId, HireDate)
    VALUES
        (
            'EMP-005',
            N'Can',
            N'Öztürk',
            'can.ozturk@northstar.local',
            N'Operations Manager',
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-001'),
            '2023-09-11'
        );
END
GO


-- Çalışan-departman atamaları.
IF NOT EXISTS (
    SELECT 1
    FROM Organization.EmployeeDepartments
    WHERE EmployeeId = (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-001')
      AND DepartmentId = (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'EXEC')
)
BEGIN
    INSERT INTO Organization.EmployeeDepartments
        (EmployeeId, DepartmentId, IsPrimary, AssignedFrom)
    VALUES
        (
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-001'),
            (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'EXEC'),
            1,
            '2022-01-10'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Organization.EmployeeDepartments
    WHERE EmployeeId = (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-002')
      AND DepartmentId = (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'SALES')
)
BEGIN
    INSERT INTO Organization.EmployeeDepartments
        (EmployeeId, DepartmentId, IsPrimary, AssignedFrom)
    VALUES
        (
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-002'),
            (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'SALES'),
            1,
            '2023-03-15'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Organization.EmployeeDepartments
    WHERE EmployeeId = (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-003')
      AND DepartmentId = (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'SUPPORT')
)
BEGIN
    INSERT INTO Organization.EmployeeDepartments
        (EmployeeId, DepartmentId, IsPrimary, AssignedFrom)
    VALUES
        (
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-003'),
            (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'SUPPORT'),
            1,
            '2024-02-01'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Organization.EmployeeDepartments
    WHERE EmployeeId = (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-004')
      AND DepartmentId = (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'PROC')
)
BEGIN
    INSERT INTO Organization.EmployeeDepartments
        (EmployeeId, DepartmentId, IsPrimary, AssignedFrom)
    VALUES
        (
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-004'),
            (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'PROC'),
            1,
            '2024-05-20'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Organization.EmployeeDepartments
    WHERE EmployeeId = (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-005')
      AND DepartmentId = (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'OPS')
)
BEGIN
    INSERT INTO Organization.EmployeeDepartments
        (EmployeeId, DepartmentId, IsPrimary, AssignedFrom)
    VALUES
        (
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-005'),
            (SELECT DepartmentId FROM Organization.Departments WHERE DepartmentCode = 'OPS'),
            1,
            '2023-09-11'
        );
END
GO


-- =========================================================
-- CATALOG
-- =========================================================

IF NOT EXISTS (SELECT 1 FROM Catalog.Products WHERE ProductCode = 'LAP-001')
BEGIN
    INSERT INTO Catalog.Products
        (CategoryId, ProductCode, ProductName, Description, UnitPrice)
    VALUES
        (
            (SELECT CategoryId FROM Catalog.Categories WHERE CategoryName = N'Laptops'),
            'LAP-001',
            N'Northstar ProBook 14',
            N'Kurumsal kullanım için 14 inç profesyonel dizüstü bilgisayar.',
            48900.00
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Catalog.Products WHERE ProductCode = 'LAP-002')
BEGIN
    INSERT INTO Catalog.Products
        (CategoryId, ProductCode, ProductName, Description, UnitPrice)
    VALUES
        (
            (SELECT CategoryId FROM Catalog.Categories WHERE CategoryName = N'Laptops'),
            'LAP-002',
            N'Northstar WorkBook 16',
            N'Yüksek performanslı 16 inç profesyonel iş istasyonu.',
            74900.00
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Catalog.Products WHERE ProductCode = 'MON-001')
BEGIN
    INSERT INTO Catalog.Products
        (CategoryId, ProductCode, ProductName, Description, UnitPrice)
    VALUES
        (
            (SELECT CategoryId FROM Catalog.Categories WHERE CategoryName = N'Monitors'),
            'MON-001',
            N'Northstar Vision 27',
            N'27 inç QHD profesyonel monitör.',
            12900.00
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Catalog.Products WHERE ProductCode = 'NET-001')
BEGIN
    INSERT INTO Catalog.Products
        (CategoryId, ProductCode, ProductName, Description, UnitPrice)
    VALUES
        (
            (SELECT CategoryId FROM Catalog.Categories WHERE CategoryName = N'Networking'),
            'NET-001',
            N'Northstar SecureRouter X1',
            N'Kurumsal ağlar için güvenli router.',
            18600.00
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Catalog.Products WHERE ProductCode = 'STO-001')
BEGIN
    INSERT INTO Catalog.Products
        (CategoryId, ProductCode, ProductName, Description, UnitPrice)
    VALUES
        (
            (SELECT CategoryId FROM Catalog.Categories WHERE CategoryName = N'Storage'),
            'STO-001',
            N'Northstar BackupDrive 4TB',
            N'Kurumsal yedekleme için 4 TB harici depolama.',
            7900.00
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Catalog.Products WHERE ProductCode = 'ACC-001')
BEGIN
    INSERT INTO Catalog.Products
        (CategoryId, ProductCode, ProductName, Description, UnitPrice)
    VALUES
        (
            (SELECT CategoryId FROM Catalog.Categories WHERE CategoryName = N'Accessories'),
            'ACC-001',
            N'Northstar USB-C Dock',
            N'Çoklu ekran ve çevre birimi bağlantısı sağlayan USB-C dock.',
            5900.00
        );
END
GO


-- =========================================================
-- SALES / CUSTOMERS
-- =========================================================

IF NOT EXISTS (SELECT 1 FROM Sales.Customers WHERE CustomerCode = 'CUS-001')
BEGIN
    INSERT INTO Sales.Customers
        (CustomerCode, CompanyName, ContactName, Email, Phone, Country, City)
    VALUES
        (
            'CUS-001',
            N'Atlas Yazılım A.Ş.',
            N'Ayşe Koç',
            'ayse.koc@atlas.local',
            '+90 212 555 0101',
            N'Türkiye',
            N'İstanbul'
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Sales.Customers WHERE CustomerCode = 'CUS-002')
BEGIN
    INSERT INTO Sales.Customers
        (CustomerCode, CompanyName, ContactName, Email, Phone, Country, City)
    VALUES
        (
            'CUS-002',
            N'Nova Lojistik Ltd.',
            N'Burak Şen',
            'burak.sen@nova.local',
            '+90 312 555 0202',
            N'Türkiye',
            N'Ankara'
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Sales.Customers WHERE CustomerCode = 'CUS-003')
BEGIN
    INSERT INTO Sales.Customers
        (CustomerCode, CompanyName, ContactName, Email, Phone, Country, City)
    VALUES
        (
            'CUS-003',
            N'Mavi Tasarım Stüdyosu',
            N'Ece Aydın',
            'ece.aydin@mavi.local',
            '+90 232 555 0303',
            N'Türkiye',
            N'İzmir'
        );
END
GO


-- Müşteri iletişim kişileri.
IF NOT EXISTS (
    SELECT 1
    FROM Sales.CustomerContacts
    WHERE CustomerId = (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001')
      AND Email = 'ayse.koc@atlas.local'
)
BEGIN
    INSERT INTO Sales.CustomerContacts
        (CustomerId, FirstName, LastName, JobTitle, Email, Phone, IsPrimary)
    VALUES
        (
            (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001'),
            N'Ayşe',
            N'Koç',
            N'IT Operations Manager',
            'ayse.koc@atlas.local',
            '+90 212 555 0101',
            1
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Sales.CustomerContacts
    WHERE CustomerId = (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001')
      AND Email = 'emre.turan@atlas.local'
)
BEGIN
    INSERT INTO Sales.CustomerContacts
        (CustomerId, FirstName, LastName, JobTitle, Email, Phone, IsPrimary)
    VALUES
        (
            (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001'),
            N'Emre',
            N'Turan',
            N'Finance Specialist',
            'emre.turan@atlas.local',
            '+90 212 555 0110',
            0
        );
END
GO


-- Müşteri adresleri.
IF NOT EXISTS (
    SELECT 1
    FROM Sales.CustomerAddresses
    WHERE CustomerId = (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001')
      AND AddressType = 'Shipping'
)
BEGIN
    INSERT INTO Sales.CustomerAddresses
        (CustomerId, AddressType, AddressLine, City, StateProvince, PostalCode, Country, IsDefault)
    VALUES
        (
            (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001'),
            'Shipping',
            N'Barbaros Mah. Teknoloji Cad. No: 10',
            N'İstanbul',
            N'Ataşehir',
            '34746',
            N'Türkiye',
            1
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Sales.CustomerAddresses
    WHERE CustomerId = (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001')
      AND AddressType = 'Billing'
)
BEGIN
    INSERT INTO Sales.CustomerAddresses
        (CustomerId, AddressType, AddressLine, City, StateProvince, PostalCode, Country, IsDefault)
    VALUES
        (
            (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001'),
            'Billing',
            N'Barbaros Mah. Finans Sok. No: 22',
            N'İstanbul',
            N'Ataşehir',
            '34746',
            N'Türkiye',
            1
        );
END
GO


-- =========================================================
-- PROCUREMENT / SUPPLIERS
-- =========================================================

IF NOT EXISTS (SELECT 1 FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001')
BEGIN
    INSERT INTO Procurement.Suppliers
        (SupplierCode, CompanyName, ContactName, Email, Phone, Country, City)
    VALUES
        (
            'SUP-001',
            N'TechSource Europe',
            N'Marko Jensen',
            'marko@techsource.local',
            '+49 30 555 1001',
            N'Almanya',
            N'Berlin'
        );
END
GO

IF NOT EXISTS (SELECT 1 FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002')
BEGIN
    INSERT INTO Procurement.Suppliers
        (SupplierCode, CompanyName, ContactName, Email, Phone, Country, City)
    VALUES
        (
            'SUP-002',
            N'Anatolia Components',
            N'Zeynep Akın',
            'zeynep@anatolia.local',
            '+90 216 555 2002',
            N'Türkiye',
            N'İstanbul'
        );
END
GO


-- Tedarikçi ürün ilişkileri.
IF NOT EXISTS (
    SELECT 1
    FROM Procurement.SupplierProducts
    WHERE SupplierId = (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001')
)
BEGIN
    INSERT INTO Procurement.SupplierProducts
        (SupplierId, ProductId, SupplierProductCode, UnitCost, LeadTimeDays)
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001'),
            'TS-PB14',
            37100.00,
            12
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.SupplierProducts
    WHERE SupplierId = (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001')
)
BEGIN
    INSERT INTO Procurement.SupplierProducts
        (SupplierId, ProductId, SupplierProductCode, UnitCost, LeadTimeDays)
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001'),
            'AC-PB14',
            38900.00,
            4
        );
END
GO


-- Aktif katalog ürünlerinin tedarik kapsamı.
-- Bazı ürünlerde iki tedarikçi maliyet / teslim süresi trade-off'u sağlar;
-- bazı ürünlerde tek tedarikçi bırakılarak supplier concentration riski görünür tutulur.

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.SupplierProducts
    WHERE SupplierId = (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-002')
)
BEGIN
    INSERT INTO Procurement.SupplierProducts
        (SupplierId, ProductId, SupplierProductCode, UnitCost, LeadTimeDays)
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-002'),
            'TS-WB16',
            58200.00,
            14
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.SupplierProducts
    WHERE SupplierId = (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-002')
)
BEGIN
    INSERT INTO Procurement.SupplierProducts
        (SupplierId, ProductId, SupplierProductCode, UnitCost, LeadTimeDays)
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-002'),
            'AC-WB16',
            61100.00,
            6
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.SupplierProducts
    WHERE SupplierId = (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'MON-001')
)
BEGIN
    INSERT INTO Procurement.SupplierProducts
        (SupplierId, ProductId, SupplierProductCode, UnitCost, LeadTimeDays)
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'MON-001'),
            'TS-V27',
            9200.00,
            9
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.SupplierProducts
    WHERE SupplierId = (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'MON-001')
)
BEGIN
    INSERT INTO Procurement.SupplierProducts
        (SupplierId, ProductId, SupplierProductCode, UnitCost, LeadTimeDays)
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'MON-001'),
            'AC-V27',
            9700.00,
            3
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.SupplierProducts
    WHERE SupplierId = (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'NET-001')
)
BEGIN
    INSERT INTO Procurement.SupplierProducts
        (SupplierId, ProductId, SupplierProductCode, UnitCost, LeadTimeDays)
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'NET-001'),
            'TS-SRX1',
            13750.00,
            11
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.SupplierProducts
    WHERE SupplierId = (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'STO-001')
)
BEGIN
    INSERT INTO Procurement.SupplierProducts
        (SupplierId, ProductId, SupplierProductCode, UnitCost, LeadTimeDays)
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'STO-001'),
            'AC-BD4T',
            5350.00,
            3
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.SupplierProducts
    WHERE SupplierId = (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'ACC-001')
)
BEGIN
    INSERT INTO Procurement.SupplierProducts
        (SupplierId, ProductId, SupplierProductCode, UnitCost, LeadTimeDays)
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-002'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'ACC-001'),
            'AC-USBCD',
            3925.00,
            2
        );
END
GO


-- =========================================================
-- PROCUREMENT / PURCHASE ORDER
-- =========================================================

IF NOT EXISTS (
    SELECT 1 FROM Procurement.PurchaseOrders WHERE PurchaseOrderNumber = 'PO-2026-001'
)
BEGIN
    INSERT INTO Procurement.PurchaseOrders
        (
            SupplierId,
            EmployeeId,
            PurchaseOrderNumber,
            OrderStatus,
            OrderedAt,
            ExpectedAt,
            TotalAmount
        )
    VALUES
        (
            (SELECT SupplierId FROM Procurement.Suppliers WHERE SupplierCode = 'SUP-001'),
            (SELECT EmployeeId FROM Organization.Employees WHERE EmployeeCode = 'EMP-004'),
            'PO-2026-001',
            'Received',
            '2026-07-01T09:00:00',
            '2026-07-14T09:00:00',
            371000.00
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.PurchaseOrderItems
    WHERE PurchaseOrderId = (
        SELECT PurchaseOrderId
        FROM Procurement.PurchaseOrders
        WHERE PurchaseOrderNumber = 'PO-2026-001'
    )
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001')
)
BEGIN
    INSERT INTO Procurement.PurchaseOrderItems
        (PurchaseOrderId, ProductId, Quantity, UnitCost)
    VALUES
        (
            (SELECT PurchaseOrderId FROM Procurement.PurchaseOrders WHERE PurchaseOrderNumber = 'PO-2026-001'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001'),
            10,
            37100.00
        );
END
GO


-- =========================================================
-- PROCUREMENT / RECEIPT
-- =========================================================

IF NOT EXISTS (
    SELECT 1 FROM Procurement.PurchaseReceipts WHERE ReceiptNumber = 'RCV-2026-001'
)
BEGIN
    INSERT INTO Procurement.PurchaseReceipts
        (PurchaseOrderId, WarehouseId, ReceiptNumber, ReceiptStatus, ReceivedAt, Notes)
    VALUES
        (
            (SELECT PurchaseOrderId FROM Procurement.PurchaseOrders WHERE PurchaseOrderNumber = 'PO-2026-001'),
            (SELECT WarehouseId FROM Inventory.Warehouses WHERE WarehouseCode = 'IST-01'),
            'RCV-2026-001',
            'Received',
            '2026-07-13T14:30:00',
            N'Teslimat eksiksiz ve hasarsız alındı.'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.PurchaseReceiptItems
    WHERE PurchaseReceiptId = (
        SELECT PurchaseReceiptId
        FROM Procurement.PurchaseReceipts
        WHERE ReceiptNumber = 'RCV-2026-001'
    )
)
BEGIN
    INSERT INTO Procurement.PurchaseReceiptItems
        (PurchaseReceiptId, PurchaseOrderItemId, QuantityReceived, QuantityRejected)
    VALUES
        (
            (SELECT PurchaseReceiptId FROM Procurement.PurchaseReceipts WHERE ReceiptNumber = 'RCV-2026-001'),
            (
                SELECT PurchaseOrderItemId
                FROM Procurement.PurchaseOrderItems
                WHERE PurchaseOrderId = (
                    SELECT PurchaseOrderId
                    FROM Procurement.PurchaseOrders
                    WHERE PurchaseOrderNumber = 'PO-2026-001'
                )
                  AND ProductId = (
                    SELECT ProductId
                    FROM Catalog.Products
                    WHERE ProductCode = 'LAP-001'
                )
            ),
            10,
            0
        );
END
GO


-- =========================================================
-- INVENTORY
-- =========================================================

-- Satın alma teslim alındığında fiziksel stok artar.
IF NOT EXISTS (
    SELECT 1
    FROM Inventory.InventoryMovements
    WHERE MovementType = 'PurchaseReceipt'
      AND ReferenceType = 'PurchaseReceipt'
      AND ReferenceId = (
          SELECT PurchaseReceiptId
          FROM Procurement.PurchaseReceipts
          WHERE ReceiptNumber = 'RCV-2026-001'
      )
)
BEGIN
    INSERT INTO Inventory.InventoryMovements
        (
            WarehouseId,
            ProductId,
            MovementType,
            QuantityOnHandChange,
            QuantityReservedChange,
            ReferenceType,
            ReferenceId,
            Notes,
            CreatedAt
        )
    VALUES
        (
            (SELECT WarehouseId FROM Inventory.Warehouses WHERE WarehouseCode = 'IST-01'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001'),
            'PurchaseReceipt',
            10,
            0,
            'PurchaseReceipt',
            (SELECT PurchaseReceiptId FROM Procurement.PurchaseReceipts WHERE ReceiptNumber = 'RCV-2026-001'),
            N'PO-2026-001 satın alma siparişinden 10 adet fiziksel stok girişi.',
            '2026-07-13T14:35:00'
        );
END
GO


-- =========================================================
-- SALES / ORDER
-- =========================================================

IF NOT EXISTS (
    SELECT 1 FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001'
)
BEGIN
    INSERT INTO Sales.Orders
        (CustomerId, OrderNumber, OrderStatus, OrderedAt, TotalAmount)
    VALUES
        (
            (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001'),
            'SO-2026-001',
            'Delivered',
            '2026-08-01T10:00:00',
            97800.00
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Sales.OrderItems
    WHERE OrderId = (SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001')
)
BEGIN
    INSERT INTO Sales.OrderItems
        (OrderId, ProductId, Quantity, UnitPrice)
    VALUES
        (
            (SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001'),
            2,
            48900.00
        );
END
GO


-- Ödeme.
IF NOT EXISTS (
    SELECT 1
    FROM Sales.Payments
    WHERE OrderId = (SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001')
)
BEGIN
    INSERT INTO Sales.Payments
        (OrderId, PaymentMethod, PaymentStatus, Amount, PaidAt)
    VALUES
        (
            (SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001'),
            'BankTransfer',
            'Completed',
            97800.00,
            '2026-08-01T10:15:00'
        );
END
GO


-- Sipariş oluşturulduğunda fiziksel stok depoda kalır;
-- satılacak 2 adet ürün rezervasyona alınır.
IF NOT EXISTS (
    SELECT 1
    FROM Inventory.InventoryMovements
    WHERE MovementType = 'SaleReservation'
      AND ReferenceType = 'Order'
      AND ReferenceId = (SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001')
)
BEGIN
    INSERT INTO Inventory.InventoryMovements
        (
            WarehouseId,
            ProductId,
            MovementType,
            QuantityOnHandChange,
            QuantityReservedChange,
            ReferenceType,
            ReferenceId,
            Notes,
            CreatedAt
        )
    VALUES
        (
            (SELECT WarehouseId FROM Inventory.Warehouses WHERE WarehouseCode = 'IST-01'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001'),
            'SaleReservation',
            0,
            2,
            'Order',
            (SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001'),
            N'SO-2026-001 siparişi için 2 adet ürün rezerve edildi.',
            '2026-08-01T10:00:00'
        );
END
GO


-- =========================================================
-- FULFILLMENT
-- =========================================================

IF NOT EXISTS (
    SELECT 1 FROM Fulfillment.Shipments WHERE ShipmentNumber = 'SHP-2026-001'
)
BEGIN
    INSERT INTO Fulfillment.Shipments
        (
            OrderId,
            WarehouseId,
            ShipmentNumber,
            ShipmentStatus,
            CarrierName,
            TrackingNumber,
            ShippedAt,
            EstimatedDeliveryAt,
            DeliveredAt
        )
    VALUES
        (
            (SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001'),
            (SELECT WarehouseId FROM Inventory.Warehouses WHERE WarehouseCode = 'IST-01'),
            'SHP-2026-001',
            'Delivered',
            N'Northstar Express',
            'TRK-2026-100001',
            '2026-08-02T15:00:00',
            '2026-08-04T18:00:00',
            '2026-08-04T13:45:00'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Fulfillment.ShipmentItems
    WHERE ShipmentId = (
        SELECT ShipmentId
        FROM Fulfillment.Shipments
        WHERE ShipmentNumber = 'SHP-2026-001'
    )
)
BEGIN
    INSERT INTO Fulfillment.ShipmentItems
        (ShipmentId, OrderItemId, Quantity)
    VALUES
        (
            (SELECT ShipmentId FROM Fulfillment.Shipments WHERE ShipmentNumber = 'SHP-2026-001'),
            (
                SELECT OrderItemId
                FROM Sales.OrderItems
                WHERE OrderId = (
                    SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001'
                )
                  AND ProductId = (
                    SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001'
                )
            ),
            2
        );
END
GO

-- Sevkiyat gerçekleştiğinde ürün fiziksel olarak depodan çıkar
-- ve sipariş rezervasyonu aynı anda çözülür.
IF NOT EXISTS (
    SELECT 1
    FROM Inventory.InventoryMovements
    WHERE MovementType = 'Shipment'
      AND ReferenceType = 'Shipment'
      AND ReferenceId = (
          SELECT ShipmentId
          FROM Fulfillment.Shipments
          WHERE ShipmentNumber = 'SHP-2026-001'
      )
)
BEGIN
    INSERT INTO Inventory.InventoryMovements
        (
            WarehouseId,
            ProductId,
            MovementType,
            QuantityOnHandChange,
            QuantityReservedChange,
            ReferenceType,
            ReferenceId,
            Notes,
            CreatedAt
        )
    VALUES
        (
            (SELECT WarehouseId FROM Inventory.Warehouses WHERE WarehouseCode = 'IST-01'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001'),
            'Shipment',
            -2,
            -2,
            'Shipment',
            (SELECT ShipmentId FROM Fulfillment.Shipments WHERE ShipmentNumber = 'SHP-2026-001'),
            N'SHP-2026-001 ile 2 adet ürün sevk edildi; rezervasyon tüketildi.',
            '2026-08-02T15:00:00'
        );
END
GO

-- Hareketlerin sonucundaki güncel stok özeti.
-- +10 fiziksel giriş, +2 rezervasyon, -2 fiziksel çıkış/-2 rezervasyon çözümü
-- sonucunda OnHand = 8, Reserved = 0, Available = 8 olur.
IF NOT EXISTS (
    SELECT 1
    FROM Inventory.StockLevels
    WHERE WarehouseId = (SELECT WarehouseId FROM Inventory.Warehouses WHERE WarehouseCode = 'IST-01')
      AND ProductId = (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001')
)
BEGIN
    INSERT INTO Inventory.StockLevels
        (WarehouseId, ProductId, QuantityOnHand, QuantityReserved)
    VALUES
        (
            (SELECT WarehouseId FROM Inventory.Warehouses WHERE WarehouseCode = 'IST-01'),
            (SELECT ProductId FROM Catalog.Products WHERE ProductCode = 'LAP-001'),
            8,
            0
        );
END
GO


-- =========================================================
-- SUPPORT
-- =========================================================

IF NOT EXISTS (
    SELECT 1 FROM Support.Tickets WHERE TicketNumber = 'TCK-2026-001'
)
BEGIN
    INSERT INTO Support.Tickets
        (
            CustomerId,
            OrderId,
            TicketNumber,
            Subject,
            TicketStatus,
            Priority,
            CreatedAt
        )
    VALUES
        (
            (SELECT CustomerId FROM Sales.Customers WHERE CustomerCode = 'CUS-001'),
            (SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001'),
            'TCK-2026-001',
            N'Dizüstü bilgisayarlardan biri açılmıyor',
            'Open',
            'High',
            '2026-08-06T09:10:00'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Support.TicketMessages
    WHERE TicketId = (
        SELECT TicketId FROM Support.Tickets WHERE TicketNumber = 'TCK-2026-001'
    )
      AND SenderType = 'Customer'
)
BEGIN
    INSERT INTO Support.TicketMessages
        (TicketId, SenderType, MessageText, CreatedAt)
    VALUES
        (
            (SELECT TicketId FROM Support.Tickets WHERE TicketNumber = 'TCK-2026-001'),
            'Customer',
            N'Siparişimizdeki iki bilgisayardan biri ilk günden beri açılmıyor. Güç adaptörünü ve farklı prizleri denedik ancak sonuç değişmedi. İade veya değişim sürecini öğrenmek istiyoruz.',
            '2026-08-06T09:10:00'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Support.TicketMessages
    WHERE TicketId = (
        SELECT TicketId FROM Support.Tickets WHERE TicketNumber = 'TCK-2026-001'
    )
      AND SenderType = 'SupportAgent'
)
BEGIN
    INSERT INTO Support.TicketMessages
        (TicketId, SenderType, MessageText, CreatedAt)
    VALUES
        (
            (SELECT TicketId FROM Support.Tickets WHERE TicketNumber = 'TCK-2026-001'),
            'SupportAgent',
            N'Talebinizi aldık. Sipariş ve ürün bilgilerinizi kontrol ederek garanti ve iade politikasına göre uygun çözümü belirleyeceğiz.',
            '2026-08-06T09:35:00'
        );
END
GO


-- =========================================================
-- KNOWLEDGE
-- =========================================================

IF NOT EXISTS (
    SELECT 1 FROM Knowledge.Documents WHERE DocumentCode = 'POL-RETURN-001'
)
BEGIN
    INSERT INTO Knowledge.Documents
        (DocumentCode, Title, DocumentType)
    VALUES
        (
            'POL-RETURN-001',
            N'Kurumsal Ürün İade Politikası',
            'Policy'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Knowledge.DocumentVersions
    WHERE DocumentId = (
        SELECT DocumentId FROM Knowledge.Documents WHERE DocumentCode = 'POL-RETURN-001'
    )
      AND VersionNumber = 1
)
BEGIN
    INSERT INTO Knowledge.DocumentVersions
        (DocumentId, VersionNumber, Content, EffectiveFrom)
    VALUES
        (
            (SELECT DocumentId FROM Knowledge.Documents WHERE DocumentCode = 'POL-RETURN-001'),
            1,
            N'Teslimattan sonraki 14 gün içinde arızalı olduğu doğrulanan ürünler için değişim veya iade talebi oluşturulabilir. 50.000 TL üzerindeki toplam iade işlemleri tamamlanmadan önce yönetici onayı gerektirir. Fiziksel hasar veya kullanıcı kaynaklı arızalar standart iade kapsamının dışındadır.',
            '2026-01-01T00:00:00'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Knowledge.DocumentChunks
    WHERE DocumentVersionId = (
        SELECT DocumentVersionId
        FROM Knowledge.DocumentVersions
        WHERE DocumentId = (
            SELECT DocumentId FROM Knowledge.Documents WHERE DocumentCode = 'POL-RETURN-001'
        )
          AND VersionNumber = 1
    )
      AND ChunkIndex = 0
)
BEGIN
    INSERT INTO Knowledge.DocumentChunks
        (DocumentVersionId, ChunkIndex, ChunkText)
    VALUES
        (
            (
                SELECT DocumentVersionId
                FROM Knowledge.DocumentVersions
                WHERE DocumentId = (
                    SELECT DocumentId FROM Knowledge.Documents WHERE DocumentCode = 'POL-RETURN-001'
                )
                  AND VersionNumber = 1
            ),
            0,
            N'Teslimattan sonraki 14 gün içinde arızalı olduğu doğrulanan ürünler için değişim veya iade talebi oluşturulabilir.'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Knowledge.DocumentChunks
    WHERE DocumentVersionId = (
        SELECT DocumentVersionId
        FROM Knowledge.DocumentVersions
        WHERE DocumentId = (
            SELECT DocumentId FROM Knowledge.Documents WHERE DocumentCode = 'POL-RETURN-001'
        )
          AND VersionNumber = 1
    )
      AND ChunkIndex = 1
)
BEGIN
    INSERT INTO Knowledge.DocumentChunks
        (DocumentVersionId, ChunkIndex, ChunkText)
    VALUES
        (
            (
                SELECT DocumentVersionId
                FROM Knowledge.DocumentVersions
                WHERE DocumentId = (
                    SELECT DocumentId FROM Knowledge.Documents WHERE DocumentCode = 'POL-RETURN-001'
                )
                  AND VersionNumber = 1
            ),
            1,
            N'50.000 TL üzerindeki toplam iade işlemleri tamamlanmadan önce yönetici onayı gerektirir.'
        );
END
GO


-- =========================================================
-- OPERATIONS / REFUND
-- =========================================================

IF NOT EXISTS (
    SELECT 1 FROM Operations.RefundRequests WHERE RequestNumber = 'REF-2026-001'
)
BEGIN
    INSERT INTO Operations.RefundRequests
        (
            OrderId,
            RequestNumber,
            Reason,
            RequestedAmount,
            RequestStatus,
            CreatedAt
        )
    VALUES
        (
            (SELECT OrderId FROM Sales.Orders WHERE OrderNumber = 'SO-2026-001'),
            'REF-2026-001',
            N'Siparişteki iki bilgisayardan birinin teslimattan sonra çalışmadığı bildirildi.',
            48900.00,
            'Requested',
            '2026-08-06T10:00:00'
        );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM Operations.RefundActions
    WHERE RefundRequestId = (
        SELECT RefundRequestId
        FROM Operations.RefundRequests
        WHERE RequestNumber = 'REF-2026-001'
    )
      AND ActionType = 'Submitted'
)
BEGIN
    INSERT INTO Operations.RefundActions
        (RefundRequestId, ActionType, ActorType, Notes, CreatedAt)
    VALUES
        (
            (
                SELECT RefundRequestId
                FROM Operations.RefundRequests
                WHERE RequestNumber = 'REF-2026-001'
            ),
            'Submitted',
            'Human',
            N'Destek talebi sonrasında iade talebi oluşturuldu.',
            '2026-08-06T10:00:00'
        );
END
GO


-- ============================================================================
-- SOURCE: 18-validation-queries.sql
-- ============================================================================

USE NorthstarOps;
GO

SET NOCOUNT ON;
GO

DECLARE @Failures TABLE
(
    CheckName NVARCHAR(200) NOT NULL,
    Details   NVARCHAR(1000) NULL
);

-- =========================================================
-- 01. TABLE COUNT
-- =========================================================

DECLARE @TableCount INT;

SELECT @TableCount = COUNT(*)
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name IN
(
    N'Organization',
    N'Catalog',
    N'Sales',
    N'Procurement',
    N'Inventory',
    N'Fulfillment',
    N'Support',
    N'Knowledge',
    N'Operations',
    N'AI',
    N'Evaluation',
    N'Governance'
);

IF @TableCount <> 38
BEGIN
    INSERT INTO @Failures (CheckName, Details)
    VALUES
    (
        N'Table count',
        CONCAT(N'Expected 38 tables, found ', @TableCount, N'.')
    );
END


-- =========================================================
-- 02. CORE SEED RECORDS
-- =========================================================

IF NOT EXISTS (
    SELECT 1
    FROM Organization.Employees
    WHERE EmployeeCode = 'EMP-001'
)
    INSERT INTO @Failures VALUES
        (N'Employee seed', N'EMP-001 not found.');

IF NOT EXISTS (
    SELECT 1
    FROM Catalog.Products
    WHERE ProductCode = 'LAP-001'
)
    INSERT INTO @Failures VALUES
        (N'Product seed', N'LAP-001 not found.');

IF NOT EXISTS (
    SELECT 1
    FROM Sales.Customers
    WHERE CustomerCode = 'CUS-001'
)
    INSERT INTO @Failures VALUES
        (N'Customer seed', N'CUS-001 not found.');

IF NOT EXISTS (
    SELECT 1
    FROM Procurement.Suppliers
    WHERE SupplierCode = 'SUP-001'
)
    INSERT INTO @Failures VALUES
        (N'Supplier seed', N'SUP-001 not found.');

IF NOT EXISTS (
    SELECT 1
    FROM Sales.Orders
    WHERE OrderNumber = 'SO-2026-001'
)
    INSERT INTO @Failures VALUES
        (N'Order seed', N'SO-2026-001 not found.');

IF NOT EXISTS (
    SELECT 1
    FROM Support.Tickets
    WHERE TicketNumber = 'TCK-2026-001'
)
    INSERT INTO @Failures VALUES
        (N'Ticket seed', N'TCK-2026-001 not found.');

IF NOT EXISTS (
    SELECT 1
    FROM Knowledge.Documents
    WHERE DocumentCode = 'POL-RETURN-001'
)
    INSERT INTO @Failures VALUES
        (N'Knowledge seed', N'POL-RETURN-001 not found.');

IF NOT EXISTS (
    SELECT 1
    FROM Operations.RefundRequests
    WHERE RequestNumber = 'REF-2026-001'
)
    INSERT INTO @Failures VALUES
        (N'Refund seed', N'REF-2026-001 not found.');


-- =========================================================
-- 03. ACTIVE PRODUCT → ACTIVE SUPPLIER COVERAGE
-- =========================================================

-- NorthstarOps üretim yapan bir şirket değildir.
-- Bu nedenle katalogda aktif olan her ürünün en az bir aktif tedarikçi
-- üzerinden aktif bir SupplierProducts ilişkisi bulunmalıdır.
IF EXISTS
(
    SELECT 1
    FROM Catalog.Products p
    WHERE p.IsActive = 1
      AND NOT EXISTS
      (
          SELECT 1
          FROM Procurement.SupplierProducts sp
          INNER JOIN Procurement.Suppliers s
              ON s.SupplierId = sp.SupplierId
          WHERE sp.ProductId = p.ProductId
            AND sp.IsActive = 1
            AND s.IsActive = 1
      )
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Active product supplier coverage',
        N'Every active Catalog.Products record must have at least one active supplier relationship.'
    );
END


-- =========================================================
-- 04. PURCHASE → RECEIPT → INVENTORY
-- =========================================================

IF NOT EXISTS
(
    SELECT 1
    FROM Procurement.PurchaseOrders po
    INNER JOIN Procurement.PurchaseOrderItems poi
        ON poi.PurchaseOrderId = po.PurchaseOrderId
    INNER JOIN Procurement.PurchaseReceiptItems pri
        ON pri.PurchaseOrderItemId = poi.PurchaseOrderItemId
    INNER JOIN Procurement.PurchaseReceipts pr
        ON pr.PurchaseReceiptId = pri.PurchaseReceiptId
    INNER JOIN Inventory.Warehouses w
        ON w.WarehouseId = pr.WarehouseId
    INNER JOIN Catalog.Products p
        ON p.ProductId = poi.ProductId
    WHERE po.PurchaseOrderNumber = 'PO-2026-001'
      AND pr.ReceiptNumber = 'RCV-2026-001'
      AND w.WarehouseCode = 'IST-01'
      AND p.ProductCode = 'LAP-001'
      AND pri.QuantityReceived = 10
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Procurement chain',
        N'PO-2026-001 → RCV-2026-001 → IST-01 → LAP-001 chain is invalid.'
    );
END


-- =========================================================
-- 05. CUSTOMER → ORDER → SHIPMENT
-- =========================================================

IF NOT EXISTS
(
    SELECT 1
    FROM Sales.Customers c
    INNER JOIN Sales.Orders o
        ON o.CustomerId = c.CustomerId
    INNER JOIN Fulfillment.Shipments s
        ON s.OrderId = o.OrderId
    WHERE c.CustomerCode = 'CUS-001'
      AND o.OrderNumber = 'SO-2026-001'
      AND s.ShipmentNumber = 'SHP-2026-001'
      AND s.ShipmentStatus = 'Delivered'
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Fulfillment chain',
        N'CUS-001 → SO-2026-001 → SHP-2026-001 chain is invalid.'
    );
END


-- =========================================================
-- 06. ORDER → SUPPORT → REFUND
-- =========================================================

IF NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders o
    INNER JOIN Support.Tickets t
        ON t.OrderId = o.OrderId
    INNER JOIN Operations.RefundRequests rr
        ON rr.OrderId = o.OrderId
    WHERE o.OrderNumber = 'SO-2026-001'
      AND t.TicketNumber = 'TCK-2026-001'
      AND rr.RequestNumber = 'REF-2026-001'
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Support/refund chain',
        N'SO-2026-001 → TCK-2026-001 → REF-2026-001 chain is invalid.'
    );
END


-- =========================================================
-- 07. KNOWLEDGE / POLICY
-- =========================================================

IF NOT EXISTS
(
    SELECT 1
    FROM Knowledge.Documents d
    INNER JOIN Knowledge.DocumentVersions dv
        ON dv.DocumentId = d.DocumentId
    INNER JOIN Knowledge.DocumentChunks dc
        ON dc.DocumentVersionId = dv.DocumentVersionId
    WHERE d.DocumentCode = 'POL-RETURN-001'
    GROUP BY d.DocumentId
    HAVING COUNT(dc.DocumentChunkId) >= 2
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Knowledge chunks',
        N'POL-RETURN-001 must contain at least 2 chunks.'
    );
END


-- =========================================================
-- 08. INVENTORY / RESERVATION BALANCE
-- =========================================================

DECLARE @OnHandMovementBalance INT;
DECLARE @ReservedMovementBalance INT;
DECLARE @StoredStock INT;
DECLARE @StoredReserved INT;

SELECT
    @OnHandMovementBalance = COALESCE(SUM(im.QuantityOnHandChange), 0),
    @ReservedMovementBalance = COALESCE(SUM(im.QuantityReservedChange), 0)
FROM Inventory.InventoryMovements im
INNER JOIN Catalog.Products p
    ON p.ProductId = im.ProductId
INNER JOIN Inventory.Warehouses w
    ON w.WarehouseId = im.WarehouseId
WHERE p.ProductCode = 'LAP-001'
  AND w.WarehouseCode = 'IST-01';

SELECT
    @StoredStock = sl.QuantityOnHand,
    @StoredReserved = sl.QuantityReserved
FROM Inventory.StockLevels sl
INNER JOIN Catalog.Products p
    ON p.ProductId = sl.ProductId
INNER JOIN Inventory.Warehouses w
    ON w.WarehouseId = sl.WarehouseId
WHERE p.ProductCode = 'LAP-001'
  AND w.WarehouseCode = 'IST-01';

-- PurchaseReceipt: +10 OnHand / 0 Reserved
IF NOT EXISTS
(
    SELECT 1
    FROM Inventory.InventoryMovements im
    INNER JOIN Catalog.Products p
        ON p.ProductId = im.ProductId
    INNER JOIN Inventory.Warehouses w
        ON w.WarehouseId = im.WarehouseId
    INNER JOIN Procurement.PurchaseReceipts pr
        ON pr.PurchaseReceiptId = im.ReferenceId
    WHERE p.ProductCode = 'LAP-001'
      AND w.WarehouseCode = 'IST-01'
      AND im.MovementType = 'PurchaseReceipt'
      AND im.ReferenceType = 'PurchaseReceipt'
      AND pr.ReceiptNumber = 'RCV-2026-001'
      AND im.QuantityOnHandChange = 10
      AND im.QuantityReservedChange = 0
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Purchase receipt inventory movement',
        N'RCV-2026-001 must add +10 OnHand and 0 Reserved.'
    );
END

-- Order: fiziksel stok değişmez, 2 adet rezerve edilir.
IF NOT EXISTS
(
    SELECT 1
    FROM Inventory.InventoryMovements im
    INNER JOIN Catalog.Products p
        ON p.ProductId = im.ProductId
    INNER JOIN Inventory.Warehouses w
        ON w.WarehouseId = im.WarehouseId
    INNER JOIN Sales.Orders o
        ON o.OrderId = im.ReferenceId
    WHERE p.ProductCode = 'LAP-001'
      AND w.WarehouseCode = 'IST-01'
      AND im.MovementType = 'SaleReservation'
      AND im.ReferenceType = 'Order'
      AND o.OrderNumber = 'SO-2026-001'
      AND im.QuantityOnHandChange = 0
      AND im.QuantityReservedChange = 2
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Sale reservation inventory movement',
        N'SO-2026-001 must reserve 2 units without reducing OnHand.'
    );
END

-- Shipment: 2 adet fiziksel stoktan çıkar ve rezervasyon tüketilir.
IF NOT EXISTS
(
    SELECT 1
    FROM Inventory.InventoryMovements im
    INNER JOIN Catalog.Products p
        ON p.ProductId = im.ProductId
    INNER JOIN Inventory.Warehouses w
        ON w.WarehouseId = im.WarehouseId
    INNER JOIN Fulfillment.Shipments s
        ON s.ShipmentId = im.ReferenceId
    WHERE p.ProductCode = 'LAP-001'
      AND w.WarehouseCode = 'IST-01'
      AND im.MovementType = 'Shipment'
      AND im.ReferenceType = 'Shipment'
      AND s.ShipmentNumber = 'SHP-2026-001'
      AND im.QuantityOnHandChange = -2
      AND im.QuantityReservedChange = -2
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Shipment inventory movement',
        N'SHP-2026-001 must reduce OnHand by 2 and Reserved by 2.'
    );
END

IF @OnHandMovementBalance <> 8
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Inventory on-hand movement balance',
        CONCAT(N'Expected OnHand movement balance 8, found ', COALESCE(@OnHandMovementBalance, -999), N'.')
    );
END

IF @ReservedMovementBalance <> 0
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Inventory reservation movement balance',
        CONCAT(N'Expected Reserved movement balance 0, found ', COALESCE(@ReservedMovementBalance, -999), N'.')
    );
END

IF @StoredStock <> 8
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Stock level',
        CONCAT(N'Expected QuantityOnHand 8, found ', COALESCE(@StoredStock, -999), N'.')
    );
END

IF @StoredReserved <> 0
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Reserved stock level',
        CONCAT(N'Expected QuantityReserved 0, found ', COALESCE(@StoredReserved, -999), N'.')
    );
END

IF @OnHandMovementBalance <> @StoredStock
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Inventory on-hand reconciliation',
        N'InventoryMovements OnHand total does not match StockLevels.QuantityOnHand.'
    );
END

IF @ReservedMovementBalance <> @StoredReserved
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Inventory reservation reconciliation',
        N'InventoryMovements Reserved total does not match StockLevels.QuantityReserved.'
    );
END


-- =========================================================
-- 09. ORPHAN CHECKS
-- =========================================================

IF EXISTS
(
    SELECT 1
    FROM Sales.Orders o
    LEFT JOIN Sales.Customers c
        ON c.CustomerId = o.CustomerId
    WHERE c.CustomerId IS NULL
)
    INSERT INTO @Failures VALUES
        (N'Orphan Sales.Orders', N'Order without customer found.');

IF EXISTS
(
    SELECT 1
    FROM Sales.OrderItems oi
    LEFT JOIN Sales.Orders o
        ON o.OrderId = oi.OrderId
    LEFT JOIN Catalog.Products p
        ON p.ProductId = oi.ProductId
    WHERE o.OrderId IS NULL
       OR p.ProductId IS NULL
)
    INSERT INTO @Failures VALUES
        (N'Orphan Sales.OrderItems', N'Order item orphan found.');

IF EXISTS
(
    SELECT 1
    FROM Support.TicketMessages tm
    LEFT JOIN Support.Tickets t
        ON t.TicketId = tm.TicketId
    WHERE t.TicketId IS NULL
)
    INSERT INTO @Failures VALUES
        (N'Orphan Support.TicketMessages', N'Ticket message orphan found.');

IF EXISTS
(
    SELECT 1
    FROM Knowledge.DocumentChunks dc
    LEFT JOIN Knowledge.DocumentVersions dv
        ON dv.DocumentVersionId = dc.DocumentVersionId
    WHERE dv.DocumentVersionId IS NULL
)
    INSERT INTO @Failures VALUES
        (N'Orphan Knowledge.DocumentChunks', N'Document chunk orphan found.');

IF EXISTS
(
    SELECT 1
    FROM Fulfillment.ShipmentItems si
    LEFT JOIN Fulfillment.Shipments s
        ON s.ShipmentId = si.ShipmentId
    LEFT JOIN Sales.OrderItems oi
        ON oi.OrderItemId = si.OrderItemId
    WHERE s.ShipmentId IS NULL
       OR oi.OrderItemId IS NULL
)
    INSERT INTO @Failures VALUES
        (N'Orphan Fulfillment.ShipmentItems', N'Shipment item orphan found.');


-- =========================================================
-- 10. GOVERNANCE RELATIONSHIPS
-- =========================================================

-- HumanApprovals must be relationally connected to RefundRequests.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys fk
    WHERE fk.name = N'FK_HumanApprovals_RefundRequests'
      AND fk.parent_object_id = OBJECT_ID(N'Governance.HumanApprovals')
      AND fk.referenced_object_id = OBJECT_ID(N'Operations.RefundRequests')
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Human approval refund relationship',
        N'Governance.HumanApprovals must reference Operations.RefundRequests.'
    );
END

-- HumanApprovals must be relationally connected to Employees.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys fk
    WHERE fk.name = N'FK_HumanApprovals_Employees'
      AND fk.parent_object_id = OBJECT_ID(N'Governance.HumanApprovals')
      AND fk.referenced_object_id = OBJECT_ID(N'Organization.Employees')
)
BEGIN
    INSERT INTO @Failures VALUES
    (
        N'Human approval employee relationship',
        N'Governance.HumanApprovals must reference Organization.Employees.'
    );
END

-- =========================================================
-- FINAL RESULT
-- =========================================================

IF EXISTS (SELECT 1 FROM @Failures)
BEGIN
    SELECT
        'FAIL' AS ValidationStatus,
        CheckName,
        Details
    FROM @Failures
    ORDER BY CheckName;

    THROW 51000, 'NorthstarOps validation failed.', 1;
END
ELSE
BEGIN
    SELECT
        'PASS' AS ValidationStatus,
        @TableCount AS TableCount,
        @OnHandMovementBalance AS InventoryMovementBalance,
        @ReservedMovementBalance AS InventoryReservationBalance,
        @StoredStock AS StoredStock,
        @StoredReserved AS StoredReserved,
        'NorthstarOps database validation completed successfully.' AS Message;
END
GO
