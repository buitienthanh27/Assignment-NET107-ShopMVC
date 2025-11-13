using Microsoft.AspNetCore.Mvc;
using ShopMVC.Services;
using ShopMVC.Services.Interfaces;

namespace ShopMVC.Controllers
{
    public class ProductController : Controller
    {
        private readonly IProductService _productService;

        public ProductController(IProductService productService)
        {
            _productService = productService;
        }

        // GET: /Product
        public async Task<IActionResult> Index(int? categoryId, string? search, int page = 1)
        {
            try
            {
                Console.WriteLine("=== CALLING ProductService ===");

                var model = await _productService.GetProductsPagedAsync(categoryId, search, page);

                Console.WriteLine("=== SUCCESS: Model returned ===");

                return View(model);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"=== ERROR: {ex.Message} ===");
                Console.WriteLine($"Stack: {ex.StackTrace}");

                TempData["Error"] = "Có lỗi xảy ra: " + ex.Message;
                return RedirectToAction("Index", "Home");
            }
        }

        // GET: /Product/Detail/5
        public async Task<IActionResult> Detail(int id)
        {
            try
            {
                var product = await _productService.GetProductByIdAsync(id);

                if (product == null)
                {
                    TempData["Error"] = "Không tìm thấy sản phẩm";
                    return RedirectToAction("Index");
                }

                return View(product);
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Có lỗi xảy ra: " + ex.Message;
                return RedirectToAction("Index");
            }
        }

        // GET: /Product/Category/1
        public async Task<IActionResult> Category(int id, int page = 1)
        {
            try
            {
                var model = await _productService.GetProductsPagedAsync(id, null, page);
                return View("Index", model);
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Có lỗi xảy ra: " + ex.Message;
                return RedirectToAction("Index", "Home");
            }
        }

        // GET: /Product/Search?term=iphone
        public async Task<IActionResult> Search(string term)
        {
            try
            {
                var products = await _productService.SearchProductsAsync(term);
                return Json(products);
            }
            catch (Exception ex)
            {
                return Json(new { error = ex.Message });
            }
        }
    }
}