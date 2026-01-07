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
using MoneyShop.BusinessLogic.Implementation.Application;
using MoneyShop.BusinessLogic.Implementation.Simulator;
using MoneyShop.BusinessLogic.Implementation.Bank;
using MoneyShop.BusinessLogic.Implementation.Lead;
using MoneyShop.BusinessLogic.Implementation.Auth;
using ConsentService = MoneyShop.BusinessLogic.Implementation.Consent.ConsentService;
using MandateService = MoneyShop.BusinessLogic.Implementation.Mandate.MandateService;
using SubjectService = MoneyShop.BusinessLogic.Implementation.Subject.SubjectService;
using KycService = MoneyShop.BusinessLogic.Implementation.Kyc.KycService;
using PdfGenerationService = MoneyShop.BusinessLogic.Implementation.Document.PdfGenerationService;
using BrokerDirectoryService = MoneyShop.BusinessLogic.Implementation.Broker.BrokerDirectoryService;
using UserFinancialDataService = MoneyShop.BusinessLogic.Implementation.User.UserFinancialDataService;
using MoneyShop.Services;

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
            services.AddScoped<ApplicationService>();
            services.AddScoped<ScoringService>();
            services.AddScoped<BankService>();
            services.AddScoped<LeadService>();
            services.AddScoped<JwtService>();
            services.AddScoped<MoneyShop.BusinessLogic.Implementation.Otp.EmailService>();
            services.AddScoped<MoneyShop.BusinessLogic.Implementation.Otp.SmsService>();
            services.AddScoped<OtpService>();
            services.AddScoped<ConsentService>();
            services.AddScoped<MandateService>();
            services.AddScoped<SubjectService>();
            services.AddScoped<KycService>();
            services.AddScoped<PdfGenerationService>();
            services.AddScoped<BrokerDirectoryService>();
            services.AddScoped<UserFinancialDataService>();
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
