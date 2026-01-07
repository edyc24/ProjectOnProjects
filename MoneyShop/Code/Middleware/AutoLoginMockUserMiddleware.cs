using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using System.Security.Claims;

namespace MoneyShop.WebApp.Code.Middleware
{
    public class AutoLoginMockUserMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IWebHostEnvironment _environment;

        public AutoLoginMockUserMiddleware(RequestDelegate next, IWebHostEnvironment environment)
        {
            _next = next;
            _environment = environment;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Only in Development mode
            if (_environment.IsDevelopment())
            {
                // Skip auto-login for login/logout endpoints and API endpoints
                var path = context.Request.Path.Value?.ToLower() ?? "";
                if (!path.Contains("/mockaccount/login") && 
                    !path.Contains("/mockaccount/logout") &&
                    !path.Contains("/account/login") &&
                    !path.Contains("/account/logout") &&
                    !path.Contains("/api/") &&
                    !path.Contains("/swagger") &&
                    !path.StartsWith("/_") &&
                    !context.User.Identity?.IsAuthenticated == true)
                {
                    // Auto-login mock user
                    var claims = new List<Claim>
                    {
                        new Claim(ClaimTypes.NameIdentifier, "999"),
                        new Claim(ClaimTypes.Name, "Utilizator Demo"),
                        new Claim(ClaimTypes.Email, "demo@moneyshop.ro"),
                        new Claim(ClaimTypes.Role, "User")
                    };

                    var claimsIdentity = new ClaimsIdentity(claims, "MoneyShopCookies");
                    var authProperties = new AuthenticationProperties
                    {
                        IsPersistent = true,
                        ExpiresUtc = DateTimeOffset.UtcNow.AddDays(30)
                    };

                    await context.SignInAsync(
                        "MoneyShopCookies",
                        new ClaimsPrincipal(claimsIdentity),
                        authProperties);
                }
            }

            await _next(context);
        }
    }

    public static class AutoLoginMockUserMiddlewareExtensions
    {
        public static IApplicationBuilder UseAutoLoginMockUser(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<AutoLoginMockUserMiddleware>();
        }
    }
}

