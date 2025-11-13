using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using ShopMVC.Data;
using ShopMVC.Models;
using ShopMVC.Services.Interfaces;
using System.Data;

namespace ShopMVC.Services.Implementations
{
    public class OrderService : IOrderService
    {
        private readonly ApplicationDbContext _context;
        private readonly string _connectionString;

        public OrderService(ApplicationDbContext context, IConfiguration configuration)
        {
            _context = context;
            _connectionString = configuration.GetConnectionString("PhoneShopDB");
        }

        public async Task<(bool success, string message, int orderId)> CreateOrderAsync(int userId, decimal totalAmount, string shippingAddress)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("sp_CreateOrder", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserId", userId);
                    command.Parameters.AddWithValue("@TotalAmount", totalAmount);
                    command.Parameters.AddWithValue("@ShippingAddress", shippingAddress);
                    // Xóa dòng: command.Parameters.AddWithValue("@Note", ...)

                    var outputParam = new SqlParameter("@NewOrderId", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.Output
                    };
                    command.Parameters.Add(outputParam);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            var success = reader.GetInt32(reader.GetOrdinal("Success")) == 1;
                            var message = reader.GetString(reader.GetOrdinal("Message"));
                            var orderId = success ? reader.GetInt32(reader.GetOrdinal("OrderId")) : 0;

                            return (success, message, orderId);
                        }
                    }

                    return (false, "Có lỗi xảy ra", 0);
                }
            }
        }

        // GET ORDER BY ID
        public async Task<Order?> GetOrderByIdAsync(int orderId)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("sp_GetOrderById", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@OrderId", orderId);

                    Order? order = null;
                    var orderDetails = new List<OrderDetail>();

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        // Read Order
                        if (await reader.ReadAsync())
                        {
                            order = new Order
                            {
                                OrderId = reader.GetInt32(reader.GetOrdinal("OrderId")),
                                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                                TotalAmount = reader.GetDecimal(reader.GetOrdinal("TotalAmount")),
                                Status = reader.GetString(reader.GetOrdinal("Status")),
                                ShippingAddress = reader.GetString(reader.GetOrdinal("ShippingAddress")),
                                OrderDate = reader.GetDateTime(reader.GetOrdinal("OrderDate")),
                                ApprovedBy = reader.IsDBNull(reader.GetOrdinal("ApprovedBy")) ? null : reader.GetInt32(reader.GetOrdinal("ApprovedBy")),
                                ApprovedDate = reader.IsDBNull(reader.GetOrdinal("ApprovedDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ApprovedDate")),

                                // ← THÊM PHẦN NÀY: Load User info
                                User = new User
                                {
                                    UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                                    FullName = reader.IsDBNull(reader.GetOrdinal("UserFullName")) ? "" : reader.GetString(reader.GetOrdinal("UserFullName")),
                                    Email = reader.IsDBNull(reader.GetOrdinal("UserEmail")) ? "" : reader.GetString(reader.GetOrdinal("UserEmail")),
                                    Phone = reader.IsDBNull(reader.GetOrdinal("UserPhoneNumber")) ? "" : reader.GetString(reader.GetOrdinal("UserPhoneNumber"))  // ← THÊM DÒNG NÀY
                                }
                            };
                        }

                        // Read Order Details
                        if (await reader.NextResultAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                orderDetails.Add(new OrderDetail
                                {
                                    OrderDetailId = reader.GetInt32(reader.GetOrdinal("OrderDetailId")),
                                    OrderId = reader.GetInt32(reader.GetOrdinal("OrderId")),
                                    ProductId = reader.GetInt32(reader.GetOrdinal("ProductId")),
                                    Quantity = reader.GetInt32(reader.GetOrdinal("Quantity")),
                                    Price = reader.GetDecimal(reader.GetOrdinal("Price")),
                                    Product = new Product
                                    {
                                        ProductId = reader.GetInt32(reader.GetOrdinal("ProductId")),
                                        ProductName = reader.GetString(reader.GetOrdinal("ProductName")),
                                        Image = reader.IsDBNull(reader.GetOrdinal("Image")) ? null : reader.GetString(reader.GetOrdinal("Image")),
                                        Category = new Category
                                        {
                                            CategoryName = reader.GetString(reader.GetOrdinal("CategoryName"))
                                        }
                                    }
                                });
                            }
                        }
                    }

                    if (order != null)
                    {
                        order.OrderDetails = orderDetails;

                        // ← THÊM PHẦN NÀY: Load ApprovedBy user info
                        if (order.ApprovedBy != null)
                        {
                            order.ApprovedByNavigation = await _context.Users
                                .Where(u => u.UserId == order.ApprovedBy)
                                .Select(u => new User { UserId = u.UserId, FullName = u.FullName })
                                .FirstOrDefaultAsync();
                        }
                    }

                    return order;
                }
            }
        }

        // GET ORDERS BY USER
        public async Task<IEnumerable<Order>> GetOrdersByUserAsync(int userId, string? status = null)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("sp_GetOrdersByUser", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@UserId", userId);
                    command.Parameters.AddWithValue("@Status", status as object ?? DBNull.Value);

                    var orders = new List<Order>();

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            orders.Add(new Order
                            {
                                OrderId = reader.GetInt32(reader.GetOrdinal("OrderId")),
                                TotalAmount = reader.GetDecimal(reader.GetOrdinal("TotalAmount")),
                                Status = reader.GetString(reader.GetOrdinal("Status")),
                                ShippingAddress = reader.GetString(reader.GetOrdinal("ShippingAddress")),
                                OrderDate = reader.GetDateTime(reader.GetOrdinal("OrderDate")),
                                ApprovedBy = reader.IsDBNull(reader.GetOrdinal("ApprovedBy")) ? null : reader.GetInt32(reader.GetOrdinal("ApprovedBy")),
                                ApprovedDate = reader.IsDBNull(reader.GetOrdinal("ApprovedDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ApprovedDate"))
                            });
                        }
                    }

                    return orders;
                }
            }
        }

        // UPDATE ORDER STATUS
        public async Task<(bool success, string message)> UpdateOrderStatusAsync(int orderId, string newStatus, int? approvedBy = null)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();

                using (var command = new SqlCommand("sp_UpdateOrderStatus", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@OrderId", orderId);
                    command.Parameters.AddWithValue("@NewStatus", newStatus);
                    command.Parameters.AddWithValue("@ApprovedBy", (object)approvedBy ?? DBNull.Value);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            var success = reader.GetInt32(reader.GetOrdinal("Success")) == 1;
                            var message = reader.GetString(reader.GetOrdinal("Message"));

                            return (success, message);
                        }
                    }

                    return (false, "Có lỗi xảy ra");
                }
            }
        }

        // GET ALL ORDERS (Admin)
        public async Task<IEnumerable<Order>> GetAllOrdersAsync()
        {
            return await _context.Orders
                .Include(o => o.User)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();
        }

        // GET ORDERS BY STATUS (Admin)
        public async Task<IEnumerable<Order>> GetOrdersByStatusAsync(string status)
        {
            return await _context.Orders
                .Include(o => o.User)
                .Where(o => o.Status == status)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync();
        }

        // GET ORDER DETAILS
        public async Task<IEnumerable<OrderDetail>> GetOrderDetailsAsync(int orderId)
        {
            return await _context.OrderDetails
                .Include(od => od.Product)
                    .ThenInclude(p => p.Category)
                .Where(od => od.OrderId == orderId)
                .ToListAsync();
        }

        // APPROVE ORDER
        public async Task<bool> ApproveOrderAsync(int orderId, int staffId)
        {
            var result = await UpdateOrderStatusAsync(orderId, "Approved", staffId);
            return result.success;
        }

        // REJECT ORDER
        public async Task<bool> RejectOrderAsync(int orderId, int staffId)
        {
            var result = await UpdateOrderStatusAsync(orderId, "Rejected", staffId);
            return result.success;
        }

        // GET USER ORDERS (for admin view)
        public async Task<IEnumerable<Order>> GetUserOrdersAsync(int userId)
        {
            return await GetOrdersByUserAsync(userId);
        }
    }
}