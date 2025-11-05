using ShopMVC.Models;
using ShopMVC.ViewModels;

namespace ShopMVC.Services.Interfaces
{
    public interface IAuthService
    {
        Task<User> LoginAsync(LoginViewModel model);
    }
}
