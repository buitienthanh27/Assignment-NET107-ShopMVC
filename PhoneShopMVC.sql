-- =============================================
-- PHONE SHOP DATABASE - FINAL COMPATIBLE VERSION
-- ASP.NET Core 8.0 + Entity Framework Core
-- Tương thích với SQL Server 2012+
-- =============================================

USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'PhoneShopDB')
BEGIN
    ALTER DATABASE PhoneShopDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PhoneShopDB;
END
GO

CREATE DATABASE PhoneShopDB;
GO

USE PhoneShopDB;
GO

-- =============================================
-- TẠO CÁC BẢNG
-- =============================================

-- 1. Bảng Categories (Danh mục sản phẩm)
CREATE TABLE dbo.Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Categories_CategoryName CHECK (LEN(LTRIM(RTRIM(CategoryName))) > 0)
);
GO

-- 2. Bảng Users (Người dùng - Admin, Nhân viên, Khách hàng)
CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Address NVARCHAR(500),
    Role NVARCHAR(20) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_Users_Username UNIQUE (Username),
    CONSTRAINT CK_Users_Role CHECK (Role IN ('Admin', 'Staff', 'Customer')),
    CONSTRAINT CK_Users_Username CHECK (LEN(LTRIM(RTRIM(Username))) >= 3),
    CONSTRAINT CK_Users_Password CHECK (LEN(Password) >= 6),
    CONSTRAINT CK_Users_Email CHECK (Email LIKE '%_@__%.__%' OR Email IS NULL)
);
GO

-- Unique Email (non-null)
CREATE UNIQUE NONCLUSTERED INDEX UX_Users_Email_NonNull 
ON dbo.Users(Email) 
WHERE Email IS NOT NULL;
GO

-- 3. Bảng Products (Sản phẩm)
CREATE TABLE dbo.Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(200) NOT NULL,
    CategoryId INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    Image NVARCHAR(500),
    Color NVARCHAR(50),
    Size NVARCHAR(50),
    Description NVARCHAR(MAX),
    Stock INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) 
        REFERENCES dbo.Categories(CategoryId) ON DELETE NO ACTION,
    CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    CONSTRAINT CK_Products_Stock CHECK (Stock >= 0),
    CONSTRAINT CK_Products_ProductName CHECK (LEN(LTRIM(RTRIM(ProductName))) > 0)
);
GO

-- 4. Bảng Carts (Giỏ hàng)
CREATE TABLE dbo.Carts (
    CartId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    CreatedDate DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    CONSTRAINT FK_Carts_Users FOREIGN KEY (UserId) 
        REFERENCES dbo.Users(UserId) ON DELETE NO ACTION,
    CONSTRAINT CK_Carts_Status CHECK (Status IN ('Active', 'Ordered', 'Cancelled'))
);
GO

-- 5. Bảng CartDetails (Chi tiết giỏ hàng)
CREATE TABLE dbo.CartDetails (
    CartDetailId INT IDENTITY(1,1) PRIMARY KEY,
    CartId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_CartDetails_Carts FOREIGN KEY (CartId) 
        REFERENCES dbo.Carts(CartId) ON DELETE CASCADE,
    CONSTRAINT FK_CartDetails_Products FOREIGN KEY (ProductId) 
        REFERENCES dbo.Products(ProductId) ON DELETE NO ACTION,
    CONSTRAINT CK_CartDetails_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_CartDetails_Price CHECK (Price >= 0),
    CONSTRAINT UQ_CartDetails_CartProduct UNIQUE (CartId, ProductId)
);
GO

-- 6. Bảng Orders (Đơn hàng)
CREATE TABLE dbo.Orders (
    OrderId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    OrderDate DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    TotalAmount DECIMAL(18,2) NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    ShippingAddress NVARCHAR(500) NOT NULL,
    ApprovedBy INT NULL,
    ApprovedDate DATETIME2(0) NULL,
    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) 
        REFERENCES dbo.Users(UserId) ON DELETE NO ACTION,
    CONSTRAINT FK_Orders_ApprovedBy FOREIGN KEY (ApprovedBy) 
        REFERENCES dbo.Users(UserId) ON DELETE NO ACTION,
    CONSTRAINT CK_Orders_Status CHECK (Status IN ('Pending', 'Approved', 'Rejected', 'Shipping', 'Completed', 'Cancelled')),
    CONSTRAINT CK_Orders_TotalAmount CHECK (TotalAmount >= 0 OR TotalAmount IS NULL),
    CONSTRAINT CK_Orders_ShippingAddress CHECK (LEN(LTRIM(RTRIM(ShippingAddress))) > 0)
);
GO

-- 7. Bảng OrderDetails (Chi tiết đơn hàng)
CREATE TABLE dbo.OrderDetails (
    OrderDetailId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderId) 
        REFERENCES dbo.Orders(OrderId) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductId) 
        REFERENCES dbo.Products(ProductId) ON DELETE NO ACTION,
    CONSTRAINT CK_OrderDetails_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderDetails_Price CHECK (Price >= 0),
    CONSTRAINT UQ_OrderDetails_OrderProduct UNIQUE (OrderId, ProductId)
);
GO

-- =============================================
-- TẠO INDEXES
-- =============================================

-- Index cho Foreign Keys
CREATE NONCLUSTERED INDEX IX_Products_CategoryId ON dbo.Products(CategoryId);
CREATE NONCLUSTERED INDEX IX_Carts_UserId ON dbo.Carts(UserId);
CREATE NONCLUSTERED INDEX IX_CartDetails_CartId ON dbo.CartDetails(CartId);
CREATE NONCLUSTERED INDEX IX_CartDetails_ProductId ON dbo.CartDetails(ProductId);
CREATE NONCLUSTERED INDEX IX_Orders_UserId ON dbo.Orders(UserId);
CREATE NONCLUSTERED INDEX IX_Orders_ApprovedBy ON dbo.Orders(ApprovedBy);
CREATE NONCLUSTERED INDEX IX_OrderDetails_OrderId ON dbo.OrderDetails(OrderId);
CREATE NONCLUSTERED INDEX IX_OrderDetails_ProductId ON dbo.OrderDetails(ProductId);

-- Index cho tìm kiếm
CREATE NONCLUSTERED INDEX IX_Products_ProductName ON dbo.Products(ProductName);
CREATE NONCLUSTERED INDEX IX_Products_IsActive ON dbo.Products(IsActive);
CREATE NONCLUSTERED INDEX IX_Users_Role ON dbo.Users(Role);
CREATE NONCLUSTERED INDEX IX_Orders_Status ON dbo.Orders(Status);
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate ON dbo.Orders(OrderDate DESC);
GO

-- =============================================
-- TRIGGER: TỰ ĐỘNG ĐỒNG BỘ TotalAmount
-- =============================================

IF OBJECT_ID('dbo.trg_OrderDetails_SyncTotal', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_OrderDetails_SyncTotal;
GO

CREATE TRIGGER dbo.trg_OrderDetails_SyncTotal
ON dbo.OrderDetails
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Lấy danh sách OrderId bị ảnh hưởng
    ;WITH AffectedOrders AS (
        SELECT OrderId FROM inserted
        UNION
        SELECT OrderId FROM deleted
    )
    -- Cập nhật TotalAmount
    UPDATE o
    SET o.TotalAmount = ISNULL(totals.CalculatedTotal, 0)
    FROM dbo.Orders o
    INNER JOIN AffectedOrders a ON a.OrderId = o.OrderId
    LEFT JOIN (
        SELECT OrderId, SUM(Quantity * Price) AS CalculatedTotal
        FROM dbo.OrderDetails
        GROUP BY OrderId
    ) totals ON totals.OrderId = o.OrderId;
END;
GO

-- =============================================
-- INSERT DỮ LIỆU MẪU
-- =============================================

-- 1. Categories (2 danh mục)
SET IDENTITY_INSERT dbo.Categories ON;
INSERT INTO dbo.Categories (CategoryId, CategoryName, Description, IsActive) VALUES
(1, N'iPhone', N'Các dòng điện thoại iPhone của Apple', 1),
(2, N'Samsung', N'Các dòng điện thoại Samsung Galaxy', 1);
SET IDENTITY_INSERT dbo.Categories OFF;
GO

-- 2. Users (4 người dùng)
-- ⚠️ Password = "123456" - Chỉ dùng cho demo!
SET IDENTITY_INSERT dbo.Users ON;
INSERT INTO dbo.Users (UserId, Username, Password, FullName, Email, Phone, Address, Role, IsActive) VALUES
(1, 'admin', '123456', N'Nguyễn Văn Admin', 'admin@phoneshop.com', '0901234567', N'Hà Nội', 'Admin', 1),
(2, 'staff01', '123456', N'Trần Thị Nhân Viên', 'staff@phoneshop.com', '0902234567', N'Hồ Chí Minh', 'Staff', 1),
(3, 'customer01', '123456', N'Lê Văn Khách', 'customer@gmail.com', '0903234567', N'Đà Nẵng', 'Customer', 1),
(4, 'customer02', '123456', N'Phạm Thị Hoa', 'hoa@gmail.com', '0904234567', N'Cần Thơ', 'Customer', 1);
SET IDENTITY_INSERT dbo.Users OFF;
GO

-- 3. Products (16 sản phẩm)
SET IDENTITY_INSERT dbo.Products ON;
INSERT INTO dbo.Products (ProductId, ProductName, CategoryId, Price, Image, Color, Size, Description, Stock, IsActive) VALUES
-- iPhone (8 sản phẩm)
(1, N'iPhone 15 Pro Max', 1, 29990000, 'iphone15promax.jpg', N'Titan Tự Nhiên', '6.7 inch', N'iPhone 15 Pro Max với chip A17 Pro, camera 48MP, màn hình Super Retina XDR', 50, 1),
(2, N'iPhone 15 Pro', 1, 25990000, 'iphone15pro.jpg', N'Titan Xanh', '6.1 inch', N'iPhone 15 Pro với chip A17 Pro, thiết kế titan cao cấp', 45, 1),
(3, N'iPhone 15 Plus', 1, 22990000, 'iphone15plus.jpg', N'Hồng', '6.7 inch', N'iPhone 15 Plus với màn hình lớn, pin trâu', 60, 1),
(4, N'iPhone 15', 1, 19990000, 'iphone15.jpg', N'Xanh Dương', '6.1 inch', N'iPhone 15 với Dynamic Island, camera 48MP', 70, 1),
(5, N'iPhone 14 Pro Max', 1, 24990000, 'iphone14promax.jpg', N'Tím', '6.7 inch', N'iPhone 14 Pro Max với chip A16 Bionic', 40, 1),
(6, N'iPhone 14 Pro', 1, 21990000, 'iphone14pro.jpg', N'Đen', '6.1 inch', N'iPhone 14 Pro với Dynamic Island độc đáo', 35, 1),
(7, N'iPhone 14', 1, 17990000, 'iphone14.jpg', N'Trắng', '6.1 inch', N'iPhone 14 với hiệu năng ổn định', 80, 1),
(8, N'iPhone 13', 1, 14990000, 'iphone13.jpg', N'Đỏ', '6.1 inch', N'iPhone 13 với chip A15 Bionic mạnh mẽ', 90, 1),

-- Samsung (8 sản phẩm)
(9, N'Samsung Galaxy S24 Ultra', 2, 27990000, 'galaxys24ultra.jpg', N'Titan Xám', '6.8 inch', N'Galaxy S24 Ultra với bút S Pen, camera 200MP', 45, 1),
(10, N'Samsung Galaxy S24+', 2, 22990000, 'galaxys24plus.jpg', N'Tím', '6.7 inch', N'Galaxy S24+ với màn hình QHD+ Dynamic AMOLED', 50, 1),
(11, N'Samsung Galaxy S24', 2, 18990000, 'galaxys24.jpg', N'Vàng', '6.2 inch', N'Galaxy S24 với AI thông minh', 60, 1),
(12, N'Samsung Galaxy Z Fold5', 2, 35990000, 'galaxyfold5.jpg', N'Đen', '7.6 inch', N'Điện thoại gập cao cấp với màn hình lớn', 30, 1),
(13, N'Samsung Galaxy Z Flip5', 2, 23990000, 'galaxyflip5.jpg', N'Kem', '6.7 inch', N'Điện thoại gập nhỏ gọn thời trang', 35, 1),
(14, N'Samsung Galaxy A54', 2, 9990000, 'galaxya54.jpg', N'Xanh Lá', '6.4 inch', N'Galaxy A54 với camera 50MP, giá tốt', 100, 1),
(15, N'Samsung Galaxy A34', 2, 7490000, 'galaxya34.jpg', N'Bạc', '6.6 inch', N'Galaxy A34 dòng phổ thông chất lượng', 120, 1),
(16, N'Samsung Galaxy M34', 2, 6490000, 'galaxym34.jpg', N'Xanh Đen', '6.5 inch', N'Galaxy M34 với pin 6000mAh siêu khủng', 110, 1);
SET IDENTITY_INSERT dbo.Products OFF;
GO

-- 4. Carts (2 giỏ hàng)
SET IDENTITY_INSERT dbo.Carts ON;
INSERT INTO dbo.Carts (CartId, UserId, Status) VALUES
(1, 3, 'Active'),
(2, 4, 'Active');
SET IDENTITY_INSERT dbo.Carts OFF;
GO

-- 5. CartDetails
SET IDENTITY_INSERT dbo.CartDetails ON;
INSERT INTO dbo.CartDetails (CartDetailId, CartId, ProductId, Quantity, Price) VALUES
(1, 1, 1, 1, 29990000),
(2, 1, 9, 1, 27990000),
(3, 2, 4, 2, 19990000);
SET IDENTITY_INSERT dbo.CartDetails OFF;
GO

-- 6. Orders (2 đơn hàng)
SET IDENTITY_INSERT dbo.Orders ON;
INSERT INTO dbo.Orders (OrderId, UserId, TotalAmount, Status, ShippingAddress, ApprovedBy, ApprovedDate) VALUES
(1, 3, NULL, 'Approved', N'123 Đường Lê Lợi, Quận 1, TP.HCM', 2, SYSDATETIME()),
(2, 4, NULL, 'Pending', N'456 Đường Trần Hưng Đạo, Đà Nẵng', NULL, NULL);
SET IDENTITY_INSERT dbo.Orders OFF;
GO

-- 7. OrderDetails (Trigger sẽ tự động tính TotalAmount)
SET IDENTITY_INSERT dbo.OrderDetails ON;
INSERT INTO dbo.OrderDetails (OrderDetailId, OrderId, ProductId, Quantity, Price) VALUES
(1, 1, 1, 1, 29990000),
(2, 1, 9, 1, 27990000),
(3, 2, 4, 2, 19990000);
SET IDENTITY_INSERT dbo.OrderDetails OFF;
GO

-- =============================================
-- TẠO VIEWS
-- =============================================

-- View 1: Sản phẩm kèm tên danh mục
IF OBJECT_ID('dbo.vw_ProductsWithCategory', 'V') IS NOT NULL 
    DROP VIEW dbo.vw_ProductsWithCategory;
GO

CREATE VIEW dbo.vw_ProductsWithCategory AS
SELECT 
    p.ProductId,
    p.ProductName,
    c.CategoryName,
    p.Price,
    p.Image,
    p.Color,
    p.Size,
    p.Description,
    p.Stock,
    p.IsActive,
    p.CreatedDate
FROM dbo.Products p
INNER JOIN dbo.Categories c ON p.CategoryId = c.CategoryId;
GO

-- View 2: Tổng tiền giỏ hàng
IF OBJECT_ID('dbo.vw_CartTotals', 'V') IS NOT NULL 
    DROP VIEW dbo.vw_CartTotals;
GO

CREATE VIEW dbo.vw_CartTotals AS
SELECT 
    c.CartId,
    c.UserId,
    u.FullName,
    u.Email,
    ISNULL(SUM(cd.Quantity * cd.Price), 0) AS TotalAmount,
    COUNT(cd.CartDetailId) AS TotalItems,
    c.Status,
    c.CreatedDate
FROM dbo.Carts c
INNER JOIN dbo.Users u ON c.UserId = u.UserId
LEFT JOIN dbo.CartDetails cd ON c.CartId = cd.CartId
GROUP BY c.CartId, c.UserId, u.FullName, u.Email, c.Status, c.CreatedDate;
GO

-- View 3: Chi tiết giỏ hàng với thông tin sản phẩm
IF OBJECT_ID('dbo.vw_CartDetailsWithProduct', 'V') IS NOT NULL 
    DROP VIEW dbo.vw_CartDetailsWithProduct;
GO

CREATE VIEW dbo.vw_CartDetailsWithProduct AS
SELECT 
    cd.CartDetailId,
    cd.CartId,
    c.UserId,
    u.FullName AS CustomerName,
    p.ProductId,
    p.ProductName,
    cat.CategoryName,
    p.Image,
    p.Color,
    p.Size,
    cd.Quantity,
    cd.Price AS UnitPrice,
    (cd.Quantity * cd.Price) AS LineTotal,
    p.Stock AS AvailableStock
FROM dbo.CartDetails cd
INNER JOIN dbo.Carts c ON cd.CartId = c.CartId
INNER JOIN dbo.Users u ON c.UserId = u.UserId
INNER JOIN dbo.Products p ON cd.ProductId = p.ProductId
INNER JOIN dbo.Categories cat ON p.CategoryId = cat.CategoryId;
GO

-- View 4: Tổng tiền đơn hàng
IF OBJECT_ID('dbo.vw_OrderTotals', 'V') IS NOT NULL 
    DROP VIEW dbo.vw_OrderTotals;
GO

CREATE VIEW dbo.vw_OrderTotals AS
SELECT 
    o.OrderId,
    o.UserId,
    u.FullName AS CustomerName,
    u.Email,
    u.Phone,
    o.OrderDate,
    o.TotalAmount,
    o.Status,
    o.ShippingAddress,
    staff.FullName AS ApprovedByStaff,
    o.ApprovedDate,
    COUNT(od.OrderDetailId) AS TotalItems
FROM dbo.Orders o
INNER JOIN dbo.Users u ON o.UserId = u.UserId
LEFT JOIN dbo.Users staff ON o.ApprovedBy = staff.UserId
LEFT JOIN dbo.OrderDetails od ON o.OrderId = od.OrderId
GROUP BY 
    o.OrderId, o.UserId, u.FullName, u.Email, u.Phone, 
    o.OrderDate, o.TotalAmount, o.Status, o.ShippingAddress, 
    staff.FullName, o.ApprovedDate;
GO

-- View 5: Chi tiết đơn hàng với thông tin sản phẩm
IF OBJECT_ID('dbo.vw_OrderDetailsWithProduct', 'V') IS NOT NULL 
    DROP VIEW dbo.vw_OrderDetailsWithProduct;
GO

CREATE VIEW dbo.vw_OrderDetailsWithProduct AS
SELECT 
    od.OrderDetailId,
    od.OrderId,
    o.UserId,
    u.FullName AS CustomerName,
    p.ProductId,
    p.ProductName,
    cat.CategoryName,
    p.Image,
    p.Color,
    p.Size,
    od.Quantity,
    od.Price AS UnitPrice,
    (od.Quantity * od.Price) AS LineTotal
FROM dbo.OrderDetails od
INNER JOIN dbo.Orders o ON od.OrderId = o.OrderId
INNER JOIN dbo.Users u ON o.UserId = u.UserId
INNER JOIN dbo.Products p ON od.ProductId = p.ProductId
INNER JOIN dbo.Categories cat ON p.CategoryId = cat.CategoryId;
GO

-- =============================================
-- KIỂM TRA KẾT QUẢ
-- =============================================

PRINT '====================================';
PRINT 'DATABASE CREATED SUCCESSFULLY!';
PRINT '====================================';
PRINT '';
PRINT '📊 THỐNG KÊ DỮ LIỆU:';
PRINT '   Categories: ' + CAST((SELECT COUNT(*) FROM dbo.Categories) AS VARCHAR);
PRINT '   Products: ' + CAST((SELECT COUNT(*) FROM dbo.Products) AS VARCHAR);
PRINT '   Users: ' + CAST((SELECT COUNT(*) FROM dbo.Users) AS VARCHAR);
PRINT '   Carts: ' + CAST((SELECT COUNT(*) FROM dbo.Carts) AS VARCHAR);
PRINT '   Orders: ' + CAST((SELECT COUNT(*) FROM dbo.Orders) AS VARCHAR);
PRINT '';
PRINT '🔑 TÀI KHOẢN ĐĂNG NHẬP:';
PRINT '   Admin:    admin / 123456';
PRINT '   Staff:    staff01 / 123456';
PRINT '   Customer: customer01 / 123456';
PRINT '   Customer: customer02 / 123456';
PRINT '';
PRINT '⚠️  LƯU Ý: Password chưa hash, chỉ demo!';
PRINT '   Trong code C# phải hash bằng BCrypt';
PRINT '';
PRINT '✅ TÍNH NĂNG:';
PRINT '   • 7 bảng với constraints đầy đủ';
PRINT '   • 13 indexes tối ưu hiệu năng';
PRINT '   • 1 trigger tự động tính TotalAmount';
PRINT '   • 5 views hỗ trợ query';
PRINT '   • Tương thích SQL Server 2012+';
PRINT '====================================';
GO

-- =============================================
-- TEST VIEWS & TRIGGER
-- =============================================

PRINT '';
PRINT '=== TEST 1: SẢN PHẨM VỚI DANH MỤC ===';
SELECT TOP 5 
    ProductId, 
    ProductName, 
    CategoryName, 
    Price, 
    Stock 
FROM dbo.vw_ProductsWithCategory 
ORDER BY ProductId;

PRINT '';
PRINT '=== TEST 2: TỔNG TIỀN GIỎ HÀNG ===';
SELECT 
    CartId, 
    FullName AS Customer, 
    TotalAmount, 
    TotalItems, 
    Status 
FROM dbo.vw_CartTotals;

PRINT '';
PRINT '=== TEST 3: CHI TIẾT GIỎ HÀNG ===';
SELECT 
    CartDetailId,
    CustomerName,
    ProductName,
    Quantity,
    UnitPrice,
    LineTotal
FROM dbo.vw_CartDetailsWithProduct;

PRINT '';
PRINT '=== TEST 4: ĐƠN HÀNG (Trigger đã tính TotalAmount) ===';
SELECT 
    OrderId, 
    CustomerName, 
    TotalAmount,
    Status, 
    TotalItems,
    CASE 
        WHEN TotalAmount IS NOT NULL THEN 'Trigger OK ✓'
        ELSE 'Chưa có chi tiết'
    END AS TriggerStatus
FROM dbo.vw_OrderTotals;

PRINT '';
PRINT '=== TEST 5: CHI TIẾT ĐƠN HÀNG ===';
SELECT 
    OrderDetailId,
    OrderId,
    CustomerName,
    ProductName,
    Quantity,
    UnitPrice,
    LineTotal
FROM dbo.vw_OrderDetailsWithProduct;

PRINT '';
PRINT '✅ Database hoàn tất! Sẵn sàng tích hợp với ASP.NET Core 8.0';
PRINT '';
GO

-- =============================================
-- HƯỚNG DẪN TÍCH HỢP EF CORE
-- =============================================

/*
📚 HƯỚNG DẪN TÍCH HỢP VỚI ASP.NET CORE 8.0 + EF CORE

1️⃣ CONNECTION STRING (appsettings.json):
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=.;Database=PhoneShopDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true"
     }
   }

2️⃣ CÀI ĐẶT PACKAGES:
   dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.0
   dotnet add package Microsoft.EntityFrameworkCore.Tools --version 8.0.0
   dotnet add package Microsoft.EntityFrameworkCore.Design --version 8.0.0

3️⃣ TẠO MODELS (Database-First approach):
   Scaffold-DbContext "Server=.;Database=PhoneShopDB;Trusted_Connection=True;TrustServerCertificate=True" Microsoft.EntityFrameworkCore.SqlServer -OutputDir Models -Context ApplicationDbContext -DataAnnotations -Force

4️⃣ HOẶC TẠO THỦ CÔNG:
   - Models/Category.cs
   - Models/Product.cs
   - Models/User.cs
   - Models/Cart.cs
   - Models/CartDetail.cs
   - Models/Order.cs
   - Models/OrderDetail.cs
   - Data/ApplicationDbContext.cs

5️⃣ ĐĂNG KÝ DbContext (Program.cs):
   builder.Services.AddDbContext<ApplicationDbContext>(options =>
       options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

6️⃣ HASH PASSWORD KHI SỬ DỤNG:
   Install-Package BCrypt.Net-Next
   
   // Hash
   string hashedPassword = BCrypt.Net.BCrypt.HashPassword(plainPassword);
   
   // Verify
   bool isValid = BCrypt.Net.BCrypt.Verify(plainPassword, hashedPassword);

📝 LƯU Ý:
   ✅ Trigger hoạt động tự động với EF Core
   ✅ Views có thể map thành Entity (keyless)
   ✅ Không cần Stored Procedures - viết logic trong C#
   ✅ Sử dụng async/await cho mọi database operations
*/
GO

-- Kiểm tra số lượng records
SELECT 'Categories' AS TableName, COUNT(*) AS Records FROM dbo.Categories
UNION ALL
SELECT 'Products', COUNT(*) FROM dbo.Products
UNION ALL
SELECT 'Users', COUNT(*) FROM dbo.Users
UNION ALL
SELECT 'Carts', COUNT(*) FROM dbo.Carts
UNION ALL
SELECT 'Orders', COUNT(*) FROM dbo.Orders;

-- Kiểm tra trigger đã tính TotalAmount chưa
SELECT OrderId, TotalAmount, Status FROM dbo.Orders;

-- Kiểm tra views
SELECT COUNT(*) AS ViewsCount FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = 'dbo';