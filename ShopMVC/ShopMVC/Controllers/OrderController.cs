using Microsoft.AspNetCore.Mvc;
using ShopMVC.Services.Interfaces;
using ShopMVC.Helpers;

namespace ShopMVC.Controllers
{
    public class OrderController : Controller
    {
        private readonly IOrderService _orderService;
        private readonly ICartService _cartService;

        public OrderController(IOrderService orderService, ICartService cartService)
        {
            _orderService = orderService;
            _cartService = cartService;
        }

        // GET: /Order
        public async Task<IActionResult> Index()
        {
            if (!HttpContext.Session.IsLoggedIn())
            {
                return RedirectToAction("Login", "Account");
            }

            var userId = HttpContext.Session.GetUserId()!.Value;
            var orders = await _orderService.GetOrdersByUserAsync(userId);

            // DEBUG: Kiểm tra OrderDetails
            foreach (var order in orders)
            {
                Console.WriteLine($"Order #{order.OrderId}: {order.OrderDetails?.Count ?? 0} items");
            }

            return View(orders);
        }

        // GET: /Order/Detail/5
        public async Task<IActionResult> Detail(int id)
        {
            if (!HttpContext.Session.IsLoggedIn())
            {
                return RedirectToAction("Login", "Account");
            }

            var order = await _orderService.GetOrderByIdAsync(id);

            if (order == null)
            {
                TempData["Error"] = "Không tìm thấy đơn hàng";
                return RedirectToAction(nameof(Index));
            }

            // Check ownership
            var userId = HttpContext.Session.GetUserId()!.Value;
            if (order.UserId != userId && !HttpContext.Session.IsStaff())
            {
                TempData["Error"] = "Bạn không có quyền xem đơn hàng này";
                return RedirectToAction(nameof(Index));
            }

            return View(order);
        }

        // GET: /Order/Checkout
        public async Task<IActionResult> Checkout()
        {
            if (!HttpContext.Session.IsLoggedIn())
            {
                return RedirectToAction("Login", "Account");
            }

            var userId = HttpContext.Session.GetUserId()!.Value;
            var cart = await _cartService.GetCartAsync(userId);

            if (cart == null || !cart.CartDetails.Any())
            {
                TempData["Error"] = "Giỏ hàng trống";
                return RedirectToAction("Index", "Cart");
            }

            return View(cart);
        }

        // POST: /Order/PlaceOrder
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> PlaceOrder(string shippingAddress)  // ← Xóa tham số note
        {
            if (!HttpContext.Session.IsLoggedIn())
            {
                return RedirectToAction("Login", "Account");
            }

            if (string.IsNullOrWhiteSpace(shippingAddress))
            {
                TempData["Error"] = "Vui lòng nhập địa chỉ giao hàng";
                return RedirectToAction(nameof(Checkout));
            }

            var userId = HttpContext.Session.GetUserId()!.Value;

            // Get cart total
            var totalAmount = await _cartService.GetCartTotalAsync(userId);

            if (totalAmount <= 0)
            {
                TempData["Error"] = "Giỏ hàng trống";
                return RedirectToAction("Index", "Cart");
            }

            // Create order (Xóa note parameter)
            var result = await _orderService.CreateOrderAsync(userId, totalAmount, shippingAddress);

            if (result.success)
            {
                // Clear session cart count
                HttpContext.Session.SetInt32("CartCount", 0);

                TempData["Success"] = "Đặt hàng thành công! Mã đơn hàng: #" + result.orderId;
                return RedirectToAction(nameof(Detail), new { id = result.orderId });
            }

            TempData["Error"] = result.message;
            return RedirectToAction(nameof(Checkout));
        } 

        // POST: /Order/Cancel/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Cancel(int id)
        {
            if (!HttpContext.Session.IsLoggedIn())
            {
                return RedirectToAction("Login", "Account");
            }

            var order = await _orderService.GetOrderByIdAsync(id);

            if (order == null)
            {
                TempData["Error"] = "Không tìm thấy đơn hàng";
                return RedirectToAction(nameof(Index));
            }

            // Check ownership
            var userId = HttpContext.Session.GetUserId()!.Value;
            if (order.UserId != userId)
            {
                TempData["Error"] = "Bạn không có quyền hủy đơn hàng này";
                return RedirectToAction(nameof(Index));
            }

            // Only allow cancel pending orders
            if (order.Status != "Pending")
            {
                TempData["Error"] = "Chỉ có thể hủy đơn hàng đang chờ duyệt";
                return RedirectToAction(nameof(Detail), new { id });
            }

            var result = await _orderService.UpdateOrderStatusAsync(id, "Cancelled");

            if (result.success)
            {
                TempData["Success"] = "Đã hủy đơn hàng";
            }
            else
            {
                TempData["Error"] = result.message;
            }

            return RedirectToAction(nameof(Detail), new { id });
        }
    }
}