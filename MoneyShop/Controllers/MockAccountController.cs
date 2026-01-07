using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace MoneyShop.WebApp.Controllers
{
    public class MockAccountController : Controller
    {
        // Mock user data - stored in memory, not in database
        private static readonly Dictionary<string, object> MockUser = new Dictionary<string, object>
        {
            { "Id", 999 },
            { "Email", "demo@moneyshop.ro" },
            { "Name", "Utilizator Demo" },
            { "Phone", "0712345678" },
            { "Role", "User" }
        };

        [HttpGet]
        public IActionResult Login()
        {
            if (User.Identity?.IsAuthenticated == true)
            {
                return RedirectToAction("Index", "Home");
            }
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Login(string email, string password)
        {
            // Mock login - accept any credentials
            if (string.IsNullOrEmpty(email))
            {
                ViewBag.Error = "Email-ul este obligatoriu";
                return View();
            }

            // Create claims for mock user
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, MockUser["Id"].ToString()!),
                new Claim(ClaimTypes.Name, MockUser["Name"].ToString()!),
                new Claim(ClaimTypes.Email, MockUser["Email"].ToString()!),
                new Claim(ClaimTypes.Role, MockUser["Role"].ToString()!)
            };

            var claimsIdentity = new ClaimsIdentity(claims, "MoneyShopCookies");
            var authProperties = new AuthenticationProperties
            {
                IsPersistent = true,
                ExpiresUtc = DateTimeOffset.UtcNow.AddDays(30)
            };

            await HttpContext.SignInAsync(
                "MoneyShopCookies",
                new ClaimsPrincipal(claimsIdentity),
                authProperties);

            return RedirectToAction("Index", "Home");
        }

        [HttpPost]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync("MoneyShopCookies");
            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public IActionResult Profile()
        {
            if (User.Identity?.IsAuthenticated != true)
            {
                return RedirectToAction("Login");
            }

            ViewBag.MockUser = MockUser;
            return View();
        }
    }
}
