using MoneyShop.Code.Base;
using MoneyShop.Common;
using MoneyShop.Common.DTOs;
using MoneyShop.WebApp.Code.Base;
using System.Security.Claims;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.BusinessLogic.Implementation.Account;
using MoneyShop.BusinessLogic.Implementation.BacDocumentService;
using MoneyShop.BusinessLogic.Implementation.ProjectService;
using MoneyShop.Code.Base;
using MoneyShop.BusinessLogic.Implementation.Bac;

namespace MoneyShop.WebApp.Code.ExtensionMethods
{
    public static class ServiceCollectionExtensionMethods
    {
        public static IServiceCollection AddPresentation(this IServiceCollection services)
        {
            services.AddScoped<ControllerDependencies>();

            return services;
        }

        public static IServiceCollection AddMoneyShopBusinessLogic(this IServiceCollection services)
        {
            services.AddScoped<ServiceDependencies>();
            services.AddScoped<BacDocumentService>();
            services.AddScoped<AccountService>();
            services.AddScoped<ProjectService>();
            services.AddScoped<BacService>();
            return services;
        }

        public static IServiceCollection AddMoneyShopCurrentUser(this IServiceCollection services)
        {
            services.AddScoped(s =>
            {
                var accessor = s.GetService<IHttpContextAccessor>();
                var httpContext = accessor.HttpContext;
                var claims = httpContext.User.Claims;

                var userIdClaim = claims?.FirstOrDefault(c => c.Type == "Id")?.Value;
                var userEmailClaim = claims?.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
                var userRoleClaim = claims?.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
                var isParsingSuccessful = int.TryParse(userIdClaim, out int id);

                var currentUser = new CurrentUserDto
                {
                    Id = id,
                    IsAuthenticated = httpContext.User.Identity.IsAuthenticated,
                    FirstName = httpContext.User.Identity.Name,
                    Email = userEmailClaim,
                    Role = userRoleClaim
                };
                return currentUser;
            });

            return services;
        }
    }
}
