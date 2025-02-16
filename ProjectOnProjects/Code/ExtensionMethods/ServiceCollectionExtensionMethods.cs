using ProjectOnProjects.Code.Base;
using ProjectOnProjects.Common;
using ProjectOnProjects.Common.DTOs;
using ProjectOnProjects.WebApp.Code.Base;
using System.Security.Claims;
using ProjectOnProjects.BusinessLogic.Base;
using ProjectOnProjects.BusinessLogic.Implementation.Account;
using ProjectOnProjects.BusinessLogic.Implementation.BacDocumentService;
using ProjectOnProjects.BusinessLogic.Implementation.ProjectService;
using ProjectOnProjects.Code.Base;

namespace ProjectOnProjects.WebApp.Code.ExtensionMethods
{
    public static class ServiceCollectionExtensionMethods
    {
        public static IServiceCollection AddPresentation(this IServiceCollection services)
        {
            services.AddScoped<ControllerDependencies>();

            return services;
        }

        public static IServiceCollection AddProjectOnProjectsBusinessLogic(this IServiceCollection services)
        {
            services.AddScoped<ServiceDependencies>();
            services.AddScoped<BacDocumentService>();
            services.AddScoped<AccountService>();
            services.AddScoped<ProjectService>();
            return services;
        }

        public static IServiceCollection AddProjectOnProjectsCurrentUser(this IServiceCollection services)
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
