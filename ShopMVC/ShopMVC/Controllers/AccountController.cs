using Microsoft.AspNetCore.Mvc;
using ShopMVC.Services.Interfaces;
using ShopMVC.ViewModels;

namespace ShopMVC.Controllers
{
    public class AccountController : Controller
    {
        private readonly IAuthService _authService;

        public AccountController(IAuthService authService)
        {
            _authService = authService;
        }

        // [GET] /Account/Login
        public IActionResult Login()
        {
            return View();
        }

        // [POST] /Account/Login
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (ModelState.IsValid)
            {
                var user = await _authService.LoginAsync(model);
                if (user != null)
                {
                    // Đăng nhập thành công, chuyển về trang chủ
                    return RedirectToAction("Index", "Home");
                }
                else
                {
                    // Thêm lỗi vào Model
                    ModelState.AddModelError(string.Empty, "Tên đăng nhập hoặc mật khẩu không đúng.");
                }
            }
            // Nếu có lỗi, trả lại View Login với dữ liệu đã nhập
            return View(model);
        }

        // [GET] /Account/Logout
        public IActionResult Logout()
        {
            // Xóa Session và chuyển về trang chủ
            HttpContext.Session.Clear();
            return RedirectToAction("Index", "Home");
        }
    }
}
