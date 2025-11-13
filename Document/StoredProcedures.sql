-- =============================================
-- PhoneShop MVC - Stored Procedures
-- Compatible with SQL Server 2008+
-- =============================================

USE [PhoneShopDB]
GO

-- =============================================
-- PRODUCT STORED PROCEDURES
-- =============================================

-- 1. Get Products with Pagination (SQL 2008 compatible)
IF OBJECT_ID('sp_GetProducts', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetProducts
GO

CREATE PROCEDURE sp_GetProducts
    @CategoryId INT = NULL,
    @SearchTerm NVARCHAR(255) = NULL,
    @Page INT = 1,
    @PageSize INT = 12
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartRow INT = (@Page - 1) * @PageSize + 1;
    DECLARE @EndRow INT = @Page * @PageSize;
    
    -- Get paginated products using ROW_NUMBER (SQL 2008 compatible)
    WITH ProductsCTE AS
    (
        SELECT 
            p.ProductId,
            p.ProductName,
            p.Description,
            p.Price,
            p.Stock,
            p.Image,
            p.Color,
            p.Size,
            p.CategoryId,
            p.IsActive,
            p.CreatedDate,
            c.CategoryName,
            c.Description AS CategoryDescription,
            ROW_NUMBER() OVER (ORDER BY p.ProductId DESC) AS RowNum
        FROM Products p
        INNER JOIN Categories c ON p.CategoryId = c.CategoryId
        WHERE 
            (@CategoryId IS NULL OR p.CategoryId = @CategoryId)
            AND (@SearchTerm IS NULL OR 
                 p.ProductName LIKE '%' + @SearchTerm + '%' OR 
                 p.Description LIKE '%' + @SearchTerm + '%')
    )
    SELECT 
        ProductId,
        ProductName,
        Description,
        Price,
        Stock,
        Image,
        Color,
        Size,
        CategoryId,
        IsActive,
        CreatedDate,
        CategoryName,
        CategoryDescription
    FROM ProductsCTE
    WHERE RowNum BETWEEN @StartRow AND @EndRow
    ORDER BY RowNum;
    
    -- Get total count
    SELECT COUNT(*) AS TotalCount
    FROM Products p
    WHERE 
        (@CategoryId IS NULL OR p.CategoryId = @CategoryId)
        AND (@SearchTerm IS NULL OR 
             p.ProductName LIKE '%' + @SearchTerm + '%' OR 
             p.Description LIKE '%' + @SearchTerm + '%');
END
GO

-- 2. Get Product By ID
IF OBJECT_ID('sp_GetProductById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetProductById
GO

CREATE PROCEDURE sp_GetProductById
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.ProductId,
        p.ProductName,
        p.Description,
        p.Price,
        p.Stock,
        p.Image,
        p.Color,
        p.Size,
        p.CategoryId,
        p.IsActive,
        p.CreatedDate,
        c.CategoryName,
        c.Description AS CategoryDescription
    FROM Products p
    INNER JOIN Categories c ON p.CategoryId = c.CategoryId
    WHERE p.ProductId = @ProductId;
END
GO

-- 3. Search Products
IF OBJECT_ID('sp_SearchProducts', 'P') IS NOT NULL
    DROP PROCEDURE sp_SearchProducts
GO

CREATE PROCEDURE sp_SearchProducts
    @SearchTerm NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 20
        p.ProductId,
        p.ProductName,
        p.Description,
        p.Price,
        p.Stock,
        p.Image,
        p.CategoryId,
        c.CategoryName
    FROM Products p
    INNER JOIN Categories c ON p.CategoryId = c.CategoryId
    WHERE 
        p.ProductName LIKE '%' + @SearchTerm + '%' OR 
        p.Description LIKE '%' + @SearchTerm + '%'
    ORDER BY p.ProductId DESC;
END
GO

-- 4. Create Product
IF OBJECT_ID('sp_CreateProduct', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateProduct
GO

CREATE PROCEDURE sp_CreateProduct
    @ProductName NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @Price DECIMAL(18,2),
    @Stock INT,
    @Image NVARCHAR(255),
    @Color NVARCHAR(50) = NULL,
    @Size NVARCHAR(50) = NULL,
    @CategoryId INT,
    @IsActive BIT = 1,
    @NewProductId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        INSERT INTO Products (
            ProductName, Description, Price, Stock, 
            Image, Color, Size, CategoryId, IsActive, CreatedDate
        )
        VALUES (
            @ProductName, @Description, @Price, @Stock,
            @Image, @Color, @Size, @CategoryId, @IsActive, GETDATE()
        );
        
        SET @NewProductId = SCOPE_IDENTITY();
        
        SELECT @NewProductId AS ProductId, 'Success' AS Status;
    END TRY
    BEGIN CATCH
        SELECT -1 AS ProductId, ERROR_MESSAGE() AS Status;
    END CATCH
END
GO

-- 5. Update Product
IF OBJECT_ID('sp_UpdateProduct', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateProduct
GO

CREATE PROCEDURE sp_UpdateProduct
    @ProductId INT,
    @ProductName NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @Price DECIMAL(18,2),
    @Stock INT,
    @Image NVARCHAR(255),
    @Color NVARCHAR(50) = NULL,
    @Size NVARCHAR(50) = NULL,
    @CategoryId INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE Products
        SET 
            ProductName = @ProductName,
            Description = @Description,
            Price = @Price,
            Stock = @Stock,
            Image = @Image,
            Color = @Color,
            Size = @Size,
            CategoryId = @CategoryId,
            IsActive = @IsActive
        WHERE ProductId = @ProductId;
        
        SELECT 1 AS Success, 'Product updated successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- 6. Delete Product
IF OBJECT_ID('sp_DeleteProduct', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteProduct
GO

CREATE PROCEDURE sp_DeleteProduct
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Soft delete by setting IsActive = 0
        UPDATE Products
        SET IsActive = 0
        WHERE ProductId = @ProductId;
        
        SELECT 1 AS Success, 'Product deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- =============================================
-- CATEGORY STORED PROCEDURES
-- =============================================

-- 7. Get All Categories
IF OBJECT_ID('sp_GetCategories', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetCategories
GO

CREATE PROCEDURE sp_GetCategories
    @IsActiveOnly BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        CategoryId,
        CategoryName,
        Description,
        IsActive,
        CreatedDate
    FROM Categories
    WHERE (@IsActiveOnly = 0 OR IsActive = 1)
    ORDER BY CategoryId;
END
GO

-- 8. Get Category By ID
IF OBJECT_ID('sp_GetCategoryById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetCategoryById
GO

CREATE PROCEDURE sp_GetCategoryById
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        CategoryId,
        CategoryName,
        Description,
        IsActive,
        CreatedDate
    FROM Categories
    WHERE CategoryId = @CategoryId;
END
GO

-- 9. Create Category
IF OBJECT_ID('sp_CreateCategory', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateCategory
GO

CREATE PROCEDURE sp_CreateCategory
    @CategoryName NVARCHAR(255),
    @Description NVARCHAR(MAX) = NULL,
    @IsActive BIT = 1,
    @NewCategoryId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        INSERT INTO Categories (CategoryName, Description, IsActive, CreatedDate)
        VALUES (@CategoryName, @Description, @IsActive, GETDATE());
        
        SET @NewCategoryId = SCOPE_IDENTITY();
        
        SELECT @NewCategoryId AS CategoryId, 'Success' AS Status;
    END TRY
    BEGIN CATCH
        SELECT -1 AS CategoryId, ERROR_MESSAGE() AS Status;
    END CATCH
END
GO

-- 10. Update Category
IF OBJECT_ID('sp_UpdateCategory', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateCategory
GO

CREATE PROCEDURE sp_UpdateCategory
    @CategoryId INT,
    @CategoryName NVARCHAR(255),
    @Description NVARCHAR(MAX) = NULL,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE Categories
        SET 
            CategoryName = @CategoryName,
            Description = @Description,
            IsActive = @IsActive
        WHERE CategoryId = @CategoryId;
        
        SELECT 1 AS Success, 'Category updated successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- 11. Delete Category
IF OBJECT_ID('sp_DeleteCategory', 'P') IS NOT NULL
    DROP PROCEDURE sp_DeleteCategory
GO

CREATE PROCEDURE sp_DeleteCategory
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Check if category has products
        IF EXISTS (SELECT 1 FROM Products WHERE CategoryId = @CategoryId)
        BEGIN
            SELECT 0 AS Success, 'Cannot delete category with existing products' AS Message;
            RETURN;
        END
        
        -- Soft delete
        UPDATE Categories
        SET IsActive = 0
        WHERE CategoryId = @CategoryId;
        
        SELECT 1 AS Success, 'Category deleted successfully' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- =============================================
-- CART STORED PROCEDURES
-- =============================================

-- 12. Get Cart
IF OBJECT_ID('sp_GetCart', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetCart
GO

CREATE PROCEDURE sp_GetCart
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get Cart
    SELECT 
        CartId,
        UserId,
        CreatedDate
    FROM Carts
    WHERE UserId = @UserId;
    
    -- Get Cart Details
    SELECT 
        cd.CartDetailId,
        cd.CartId,
        cd.ProductId,
        cd.Quantity,
        p.ProductName,
        p.Description,
        p.Price,
        p.Image,
        p.Stock,
        c.CategoryName
    FROM CartDetails cd
    INNER JOIN Carts cart ON cd.CartId = cart.CartId
    INNER JOIN Products p ON cd.ProductId = p.ProductId
    LEFT JOIN Categories c ON p.CategoryId = c.CategoryId
    WHERE cart.UserId = @UserId;
END
GO

-- 13. Add To Cart
IF OBJECT_ID('sp_AddToCart', 'P') IS NOT NULL
    DROP PROCEDURE sp_AddToCart
GO

CREATE PROCEDURE sp_AddToCart
    @UserId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CartId INT;
    DECLARE @ExistingQuantity INT;
    DECLARE @Stock INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check product stock
        SELECT @Stock = Stock FROM Products WHERE ProductId = @ProductId;
        
        IF @Stock < @Quantity
        BEGIN
            SELECT 0 AS Success, 'Insufficient stock' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Get or create cart
        SELECT @CartId = CartId FROM Carts WHERE UserId = @UserId;
        
        IF @CartId IS NULL
        BEGIN
            INSERT INTO Carts (UserId, CreatedDate)
            VALUES (@UserId, GETDATE());
            
            SET @CartId = SCOPE_IDENTITY();
        END
        
        -- Check if product already in cart
        SELECT @ExistingQuantity = Quantity 
        FROM CartDetails 
        WHERE CartId = @CartId AND ProductId = @ProductId;
        
        IF @ExistingQuantity IS NOT NULL
        BEGIN
            -- Update quantity
            IF (@ExistingQuantity + @Quantity) > @Stock
            BEGIN
                SELECT 0 AS Success, 'Insufficient stock' AS Message;
                ROLLBACK TRANSACTION;
                RETURN;
            END
            
            UPDATE CartDetails
            SET Quantity = Quantity + @Quantity
            WHERE CartId = @CartId AND ProductId = @ProductId;
        END
        ELSE
        BEGIN
            -- Add new item
            INSERT INTO CartDetails (CartId, ProductId, Quantity)
            VALUES (@CartId, @ProductId, @Quantity);
        END
        
        -- Get cart count
        DECLARE @CartCount INT;
        SELECT @CartCount = SUM(Quantity) 
        FROM CartDetails 
        WHERE CartId = @CartId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, 'Added to cart' AS Message, @CartCount AS CartCount;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- 14. Update Cart Quantity
IF OBJECT_ID('sp_UpdateCartQuantity', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateCartQuantity
GO

CREATE PROCEDURE sp_UpdateCartQuantity
    @CartDetailId INT,
    @Quantity INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ProductId INT;
    DECLARE @Stock INT;
    DECLARE @CartId INT;
    
    BEGIN TRY
        -- Get product info
        SELECT @ProductId = ProductId, @CartId = CartId
        FROM CartDetails
        WHERE CartDetailId = @CartDetailId;
        
        SELECT @Stock = Stock FROM Products WHERE ProductId = @ProductId;
        
        IF @Quantity > @Stock
        BEGIN
            SELECT 0 AS Success, 'Insufficient stock' AS Message;
            RETURN;
        END
        
        IF @Quantity <= 0
        BEGIN
            SELECT 0 AS Success, 'Invalid quantity' AS Message;
            RETURN;
        END
        
        -- Update quantity
        UPDATE CartDetails
        SET Quantity = @Quantity
        WHERE CartDetailId = @CartDetailId;
        
        -- Calculate totals
        DECLARE @ItemSubtotal DECIMAL(18,2);
        DECLARE @Subtotal DECIMAL(18,2);
        DECLARE @CartCount INT;
        
        SELECT @ItemSubtotal = p.Price * @Quantity
        FROM Products p
        WHERE p.ProductId = @ProductId;
        
        SELECT @Subtotal = SUM(p.Price * cd.Quantity)
        FROM CartDetails cd
        INNER JOIN Products p ON cd.ProductId = p.ProductId
        WHERE cd.CartId = @CartId;
        
        SELECT @CartCount = SUM(Quantity)
        FROM CartDetails
        WHERE CartId = @CartId;
        
        SELECT 
            1 AS Success, 
            'Quantity updated' AS Message,
            @ItemSubtotal AS ItemSubtotal,
            @Subtotal AS Subtotal,
            @Subtotal AS TotalAmount,
            @CartCount AS CartCount;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- 15. Remove From Cart
IF OBJECT_ID('sp_RemoveFromCart', 'P') IS NOT NULL
    DROP PROCEDURE sp_RemoveFromCart
GO

CREATE PROCEDURE sp_RemoveFromCart
    @CartDetailId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CartId INT;
    
    BEGIN TRY
        -- Get CartId
        SELECT @CartId = CartId FROM CartDetails WHERE CartDetailId = @CartDetailId;
        
        -- Delete item
        DELETE FROM CartDetails WHERE CartDetailId = @CartDetailId;
        
        -- Get cart count
        DECLARE @CartCount INT;
        SELECT @CartCount = ISNULL(SUM(Quantity), 0)
        FROM CartDetails
        WHERE CartId = @CartId;
        
        SELECT 1 AS Success, 'Item removed' AS Message, @CartCount AS CartCount;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- 16. Clear Cart
IF OBJECT_ID('sp_ClearCart', 'P') IS NOT NULL
    DROP PROCEDURE sp_ClearCart
GO

CREATE PROCEDURE sp_ClearCart
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CartId INT;
    
    BEGIN TRY
        SELECT @CartId = CartId FROM Carts WHERE UserId = @UserId;
        
        DELETE FROM CartDetails WHERE CartId = @CartId;
        
        SELECT 1 AS Success, 'Cart cleared' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- =============================================
-- ORDER STORED PROCEDURES
-- =============================================

-- 17. Create Order (FIXED - Dùng Status thay vì OrderStatus)
IF OBJECT_ID('sp_CreateOrder', 'P') IS NOT NULL
    DROP PROCEDURE sp_CreateOrder
GO

CREATE PROCEDURE sp_CreateOrder
    @UserId INT,
    @TotalAmount DECIMAL(18,2),
    @ShippingAddress NVARCHAR(500),
    @Note NVARCHAR(MAX) = NULL,
    @NewOrderId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CartId INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get cart
        SELECT @CartId = CartId FROM Carts WHERE UserId = @UserId;
        
        IF @CartId IS NULL
        BEGIN
            SELECT 0 AS Success, 'Cart is empty' AS Message;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Create order (FIXED: Dùng Status, ShippingAddress)
        INSERT INTO Orders (
            UserId, TotalAmount, Status, 
            ShippingAddress, OrderDate
        )
        VALUES (
            @UserId, @TotalAmount, N'Pending',
            @ShippingAddress, GETDATE()
        );
        
        SET @NewOrderId = SCOPE_IDENTITY();
        
        -- Create order details from cart
        INSERT INTO OrderDetails (OrderId, ProductId, Quantity, Price)
        SELECT 
            @NewOrderId,
            cd.ProductId,
            cd.Quantity,
            p.Price
        FROM CartDetails cd
        INNER JOIN Products p ON cd.ProductId = p.ProductId
        WHERE cd.CartId = @CartId;
        
        -- Update product stock
        UPDATE p
        SET p.Stock = p.Stock - cd.Quantity
        FROM Products p
        INNER JOIN CartDetails cd ON p.ProductId = cd.ProductId
        WHERE cd.CartId = @CartId;
        
        -- Clear cart
        DELETE FROM CartDetails WHERE CartId = @CartId;
        
        COMMIT TRANSACTION;
        
        SELECT 1 AS Success, 'Order created successfully' AS Message, @NewOrderId AS OrderId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

-- 18. Get Order By ID (FIXED)
IF OBJECT_ID('sp_GetOrderById', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetOrderById
GO

CREATE PROCEDURE sp_GetOrderById
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get Order
    SELECT 
        o.OrderId,
        o.UserId,
        o.TotalAmount,
        o.Status,
        o.ShippingAddress,
        o.OrderDate,
        o.ApprovedBy,
        o.ApprovedDate,
        u.FullName AS UserFullName,
        u.Email AS UserEmail
    FROM Orders o
    LEFT JOIN Users u ON o.UserId = u.UserId
    WHERE o.OrderId = @OrderId;
    
    -- Get Order Details
    SELECT 
        od.OrderDetailId,
        od.OrderId,
        od.ProductId,
        od.Quantity,
        od.Price,
        p.ProductName,
        p.Image,
        c.CategoryName
    FROM OrderDetails od
    INNER JOIN Products p ON od.ProductId = p.ProductId
    LEFT JOIN Categories c ON p.CategoryId = c.CategoryId
    WHERE od.OrderId = @OrderId;
END
GO

-- 19. Get Orders By User (FIXED)
IF OBJECT_ID('sp_GetOrdersByUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetOrdersByUser
GO

CREATE PROCEDURE sp_GetOrdersByUser
    @UserId INT,
    @Status NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        OrderId,
        TotalAmount,
        Status,
        ShippingAddress,
        OrderDate,
        ApprovedBy,
        ApprovedDate
    FROM Orders
    WHERE 
        UserId = @UserId
        AND (@Status IS NULL OR Status = @Status)
    ORDER BY OrderDate DESC;
END
GO

-- 20. Update Order Status (FIXED)
IF OBJECT_ID('sp_UpdateOrderStatus', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateOrderStatus
GO

CREATE PROCEDURE sp_UpdateOrderStatus
    @OrderId INT,
    @NewStatus NVARCHAR(50),
    @ApprovedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE Orders
        SET 
            Status = @NewStatus,
            ApprovedBy = @ApprovedBy,
            ApprovedDate = CASE WHEN @ApprovedBy IS NOT NULL THEN GETDATE() ELSE ApprovedDate END
        WHERE OrderId = @OrderId;
        
        SELECT 1 AS Success, 'Order status updated' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO
PRINT 'All stored procedures created successfully!';
GO
