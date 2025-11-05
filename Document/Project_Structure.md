# =============================================
# CẤU TRÚC THƯ MỤC DỰ ÁN - PHONESHOP MVC
# ASP.NET Core 8.0 MVC + Entity Framework Core
# FPT Polytechnic Assignment
# =============================================

PhoneShopMVC/
│
├── 📁 Controllers/                    # Xử lý HTTP requests và responses
│   ├── HomeController.cs             # Trang chủ, giới thiệu
│   ├── ProductController.cs          # Xem sản phẩm, chi tiết, tìm kiếm
│   ├── CartController.cs             # Quản lý giỏ hàng (thêm, xóa, sửa)
│   ├── OrderController.cs            # Đặt hàng, xem đơn hàng của tôi
│   ├── AccountController.cs          # Đăng ký, đăng nhập, profile
│   └── AdminController.cs            # Quản lý admin (products, orders, users)
│
├── 📁 Models/                         # Entity classes (mapping với database)
│   ├── Category.cs                   # Entity: Categories
│   ├── Product.cs                    # Entity: Products
│   ├── User.cs                       # Entity: Users
│   ├── Cart.cs                       # Entity: Carts
│   ├── CartDetail.cs                 # Entity: CartDetails
│   ├── Order.cs                      # Entity: Orders
│   └── OrderDetail.cs                # Entity: OrderDetails
│
├── 📁 ViewModels/                     # DTOs cho Views (không map trực tiếp DB)
│   ├── LoginViewModel.cs             # Dữ liệu cho form đăng nhập
│   ├── RegisterViewModel.cs          # Dữ liệu cho form đăng ký
│   ├── ProductViewModel.cs           # Dữ liệu hiển thị sản phẩm (có thêm info)
│   ├── CartViewModel.cs              # Dữ liệu hiển thị giỏ hàng
│   ├── CheckoutViewModel.cs          # Dữ liệu thanh toán
│   ├── OrderViewModel.cs             # Dữ liệu đơn hàng
│   └── DashboardViewModel.cs         # Dữ liệu dashboard admin
│
├── 📁 Data/                           # Database context và configurations
│   ├── ApplicationDbContext.cs       # DbContext chính - kết nối EF Core
│   └── DbInitializer.cs              # (Optional) Seed data nếu cần
│
├── 📁 Services/                       # Business Logic Layer
│   ├── Interfaces/                   # Interface definitions
│   │   ├── IProductService.cs
│   │   ├── ICartService.cs
│   │   ├── IOrderService.cs
│   │   ├── IAuthService.cs
│   │   └── IAdminService.cs
│   │
│   └── Implementations/              # Service implementations
│       ├── ProductService.cs         # Logic sản phẩm (search, filter, CRUD)
│       ├── CartService.cs            # Logic giỏ hàng (add, update, remove)
│       ├── OrderService.cs           # Logic đơn hàng (create, approve)
│       ├── AuthService.cs            # Logic xác thực (login, register, hash password)
│       └── AdminService.cs           # Logic admin (reports, statistics)
│
├── 📁 Helpers/                        # Utility classes
│   ├── SessionHelper.cs              # Quản lý Session
│   ├── PasswordHasher.cs             # Hash password với BCrypt
│   ├── ImageHelper.cs                # Xử lý upload/resize ảnh
│   └── PaginationHelper.cs           # Phân trang
│
├── 📁 Filters/                        # Action Filters & Attributes
│   ├── AuthorizeRoleAttribute.cs     # Custom authorization filter
│   └── ValidateModelAttribute.cs     # Validate model state
│
├── 📁 Views/                          # Razor Views (.cshtml)
│   │
│   ├── 📁 Shared/                    # Layout & partial views dùng chung
│   │   ├── _Layout.cshtml           # Layout chính cho User
│   │   ├── _AdminLayout.cshtml      # Layout cho Admin area
│   │   ├── _Header.cshtml           # Header (navbar, menu)
│   │   ├── _Footer.cshtml           # Footer
│   │   ├── _LoginPartial.cshtml     # Login status (hiện tên user/logout)
│   │   ├── _Pagination.cshtml       # Pagination component
│   │   ├── _ProductCard.cshtml      # Card hiển thị sản phẩm
│   │   ├── Error.cshtml             # Error page
│   │   └── _ValidationScriptsPartial.cshtml  # jQuery validation scripts
│   │
│   ├── 📁 Home/                      # Views cho HomeController
│   │   ├── Index.cshtml             # Trang chủ (hiển thị sản phẩm nổi bật)
│   │   ├── About.cshtml             # Giới thiệu
│   │   └── Contact.cshtml           # Liên hệ
│   │
│   ├── 📁 Product/                   # Views cho ProductController
│   │   ├── Index.cshtml             # Danh sách tất cả sản phẩm (có filter)
│   │   ├── Category.cshtml          # Sản phẩm theo danh mục
│   │   ├── Detail.cshtml            # Chi tiết sản phẩm
│   │   └── Search.cshtml            # Kết quả tìm kiếm
│   │
│   ├── 📁 Cart/                      # Views cho CartController
│   │   ├── Index.cshtml             # Xem giỏ hàng
│   │   └── Checkout.cshtml          # Trang thanh toán
│   │
│   ├── 📁 Order/                     # Views cho OrderController
│   │   ├── Index.cshtml             # Danh sách đơn hàng của tôi
│   │   ├── Detail.cshtml            # Chi tiết đơn hàng
│   │   └── Success.cshtml           # Đặt hàng thành công
│   │
│   ├── 📁 Account/                   # Views cho AccountController
│   │   ├── Login.cshtml             # Form đăng nhập
│   │   ├── Register.cshtml          # Form đăng ký
│   │   ├── Profile.cshtml           # Thông tin cá nhân
│   │   └── ChangePassword.cshtml    # Đổi mật khẩu
│   │
│   └── 📁 Admin/                     # Views cho AdminController
│       ├── Index.cshtml             # Dashboard (thống kê tổng quan)
│       │
│       ├── 📁 Products/             # Quản lý sản phẩm
│       │   ├── Index.cshtml         # Danh sách sản phẩm
│       │   ├── Create.cshtml        # Thêm sản phẩm mới
│       │   ├── Edit.cshtml          # Sửa sản phẩm
│       │   └── Delete.cshtml        # Xóa sản phẩm (confirmation)
│       │
│       ├── 📁 Orders/               # Quản lý đơn hàng
│       │   ├── Index.cshtml         # Danh sách đơn hàng
│       │   ├── Detail.cshtml        # Chi tiết đơn hàng
│       │   └── Approve.cshtml       # Duyệt đơn hàng
│       │
│       ├── 📁 Users/                # Quản lý người dùng
│       │   ├── Index.cshtml         # Danh sách users
│       │   ├── Detail.cshtml        # Chi tiết user
│       │   └── Edit.cshtml          # Sửa thông tin user
│       │
│       └── 📁 Reports/              # Báo cáo thống kê
│           ├── Sales.cshtml         # Báo cáo doanh thu
│           └── Products.cshtml      # Báo cáo sản phẩm bán chạy
│
├── 📁 wwwroot/                        # Static files (public accessible)
│   │
│   ├── 📁 css/                       # CSS files
│   │   ├── site.css                 # CSS tùy chỉnh chung
│   │   ├── admin.css                # CSS riêng cho admin
│   │   └── product.css              # CSS riêng cho trang sản phẩm
│   │
│   ├── 📁 js/                        # JavaScript files
│   │   ├── site.js                  # JS chung
│   │   ├── cart.js                  # JS cho giỏ hàng (AJAX add to cart)
│   │   ├── product.js               # JS cho sản phẩm
│   │   └── admin.js                 # JS cho admin
│   │
│   ├── 📁 images/                    # Hình ảnh
│   │   ├── logo.png                 # Logo website
│   │   ├── no-image.jpg             # Ảnh placeholder
│   │   ├── banner/                  # Banner trang chủ
│   │   │   ├── banner1.jpg
│   │   │   └── banner2.jpg
│   │   │
│   │   └── products/                # Ảnh sản phẩm (upload by admin)
│   │       ├── iphone15promax.jpg
│   │       ├── galaxys24ultra.jpg
│   │       └── ... (các ảnh khác)
│   │
│   └── 📁 lib/                       # Thư viện bên ngoài (CDN hoặc local)
│       ├── bootstrap/               # Bootstrap 5
│       ├── jquery/                  # jQuery
│       ├── font-awesome/            # Font Awesome icons
│       └── jquery-validation/       # jQuery Validation
│
├── 📁 Migrations/                     # EF Core Migrations (auto-generated)
│   └── (các file migration...)
│
├── 📄 appsettings.json                # Configuration chính
├── 📄 appsettings.Development.json    # Config cho Development
├── 📄 Program.cs                      # Entry point, configure services
├── 📄 PhoneShopMVC.csproj            # Project file
└── 📄 .gitignore                      # Git ignore file


# =============================================
# GIẢI THÍCH CHI TIẾT CÁC LAYER
# =============================================

## 1. CONTROLLERS (Presentation Layer)
- Nhận HTTP requests từ user
- Gọi Services để xử lý business logic
- Trả về Views hoặc JSON
- KHÔNG chứa business logic phức tạp

## 2. MODELS (Data Layer)
- Entity classes mapping trực tiếp với database tables
- Có Data Annotations ([Key], [Required], [MaxLength])
- Navigation properties (relationships)

## 3. VIEWMODELS (Data Transfer Objects)
- Dữ liệu tùy chỉnh cho từng View cụ thể
- Có thể kết hợp nhiều Models
- Có validation attributes
- KHÔNG map trực tiếp với database

## 4. SERVICES (Business Logic Layer)
- Chứa tất cả business logic
- CRUD operations
- Validation
- Calculations
- Transaction handling
- Gọi DbContext để tương tác database

## 5. DATA (Data Access Layer)
- ApplicationDbContext: DbContext chính
- DbSet cho các entities
- Fluent API configurations
- OnModelCreating()

## 6. HELPERS (Utility Layer)
- Các hàm tiện ích tái sử dụng
- Session management
- Password hashing
- Image processing
- Pagination

## 7. VIEWS (Presentation Layer)
- Razor pages (.cshtml)
- HTML + C# syntax
- Strongly-typed với ViewModels
- Partial views cho components


# =============================================
# WORKFLOW ĐIỂN HÌNH
# =============================================

User Request → Controller → Service → DbContext → Database
                    ↓
                  View ← ViewModel ← Service Response


# =============================================
# VÍ DỤ: ADD TO CART FLOW
# =============================================

1. User click "Thêm vào giỏ" → POST /Cart/AddToCart
2. CartController.AddToCart() nhận request
3. Controller gọi CartService.AddToCart(userId, productId, quantity)
4. Service kiểm tra:
   - User có giỏ hàng active không?
   - Sản phẩm còn tồn kho không?
   - Đã có trong giỏ chưa?
5. Service gọi DbContext để insert/update
6. Controller trả về JSON success
7. JavaScript cập nhật UI (số lượng giỏ hàng)


# =============================================
# PHÂN QUYỀN USER ROLES
# =============================================

## Admin:
- Full access mọi chức năng
- Quản lý products, orders, users
- Xem báo cáo thống kê

## Staff:
- Quản lý products (CRUD)
- Duyệt đơn hàng
- KHÔNG quản lý users

## Customer:
- Xem sản phẩm
- Mua hàng
- Xem đơn hàng của mình
- Quản lý thông tin cá nhân


# =============================================
# SESSION MANAGEMENT
# =============================================

Session Keys:
- "UserId" → int
- "Username" → string
- "FullName" → string
- "Role" → string (Admin/Staff/Customer)
- "CartCount" → int


# =============================================
# VALIDATION STRATEGY
# =============================================

1. Client-side: jQuery Validation (UX)
2. Server-side: Data Annotations (Security)
3. Business rules: Service Layer (Logic)


# =============================================
# ERROR HANDLING
# =============================================

- Try-catch trong Services
- Custom error pages (404, 500)
- Logging (optional: Serilog, NLog)
- User-friendly error messages


# =============================================
# ĐIỂM CỘNG CHO ASSIGNMENT
# =============================================

✅ Repository Pattern (optional - nâng cao)
✅ Unit of Work Pattern (optional - nâng cao)
✅ Dependency Injection (built-in ASP.NET Core)
✅ Async/Await cho database operations
✅ AJAX cho Add to Cart (UX tốt hơn)
✅ Pagination
✅ Search & Filter
✅ Image upload
✅ Session management
✅ Password hashing
✅ Responsive design (Bootstrap)


# =============================================
# NAMING CONVENTIONS
# =============================================

- Controllers: PascalCase + "Controller" suffix
  Example: ProductController, CartController

- Actions: PascalCase verbs
  Example: Index, Create, Edit, Delete

- Views: PascalCase, match action names
  Example: Index.cshtml, Create.cshtml

- Models: PascalCase singular nouns
  Example: Product, User, Order

- ViewModels: PascalCase + "ViewModel" suffix
  Example: LoginViewModel, ProductViewModel

- Services: PascalCase + "Service" suffix
  Example: ProductService, CartService

- Interfaces: "I" + PascalCase
  Example: IProductService, ICartService

- Private fields: camelCase with underscore
  Example: _context, _cartService

- Public properties: PascalCase
  Example: ProductId, ProductName


# =============================================
# GIT IGNORE RECOMMENDATIONS
# =============================================

- bin/
- obj/
- .vs/
- *.user
- appsettings.Development.json (nếu có sensitive data)
- wwwroot/images/products/* (ảnh upload - backup riêng)


# =============================================
# KẾT LUẬN
# =============================================

Cấu trúc này:
✅ Tuân thủ MVC pattern chuẩn
✅ Separation of Concerns rõ ràng
✅ Dễ maintain và scale
✅ Phù hợp cho assignment FPT Polytechnic
✅ Đủ professional để học thêm sau này

Đây là cấu trúc cân bằng giữa:
- Đơn giản (dễ làm cho assignment)
- Chuyên nghiệp (học được kiến thức thực tế)
- Đầy đủ chức năng (đạt điểm cao)
