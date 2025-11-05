using Microsoft.EntityFrameworkCore;
using ShopMVC.Data;
using ShopMVC.Models;
using ShopMVC.Services.Interfaces;
using ShopMVC.ViewModels;
using BCrypt.Net;

namespace ShopMVC.Services.Implementations
{
    public class AuthService : IAuthService
    {
        private readonly ApplicationDbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public AuthService(ApplicationDbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        public async Task<User> LoginAsync(LoginViewModel model)
        {
            // 1. Tìm user bằng username
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Username == model.Username && u.IsActive == true);

            if (user == null)
            {
                return null; // Không tìm thấy user
            }

            // 2. Kiểm tra mật khẩu
            // File database của bạn dùng mật khẩu "123456"
            // Trong thực tế, bạn sẽ hash mật khẩu khi đăng ký.
            // Tạm thời chúng ta sẽ hash "123456" để so sánh:
            // string testHash = BCrypt.HashPassword("123456"); 

            // Giả sử mật khẩu trong DB đã được hash bằng BCrypt
            // Hoặc, vì là demo, chúng ta dùng mật khẩu "123456"
            if (user.Password != model.Password) // TẠM THỜI: So sánh text
            // if (!BCrypt.Verify(model.Password, user.Password)) // CHUẨN: Dùng BCrypt
            {
                return null; // Sai mật khẩu
            }

            // 3. Đăng nhập thành công, lưu vào Session [cite: 4838]
            var session = _httpContextAccessor.HttpContext.Session;
            session.SetInt32("UserId", user.UserId);
            session.SetString("Username", user.Username);
            session.SetString("FullName", user.FullName);
            session.SetString("Role", user.Role); // Rất quan trọng để phân quyền

            return user; // Trả về user để Controller biết
        }
    }
}