using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;

namespace MoneyShop.BusinessLogic.Implementation.Chat
{
    public class CostControlService : BaseService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<CostControlService> _logger;
        private readonly decimal _budgetUsdMonth;

        public CostControlService(
            ServiceDependencies dependencies,
            IConfiguration configuration,
            ILogger<CostControlService> logger)
            : base(dependencies)
        {
            _configuration = configuration;
            _logger = logger;
            _budgetUsdMonth = decimal.Parse(_configuration["OpenAI:BudgetUsdMonth"] ?? "150");
        }

        public async Task EnforceMonthlyBudgetAsync()
        {
            var monthKey = DateTime.UtcNow.ToString("yyyy-MM");
            var spent = await GetMonthlySpentAsync(monthKey);
            
            if (spent >= _budgetUsdMonth)
            {
                throw new InvalidOperationException("BUDGET_EXCEEDED");
            }
        }

        public async Task AddUsageAsync(decimal usdDelta, string? metadata = null)
        {
            var monthKey = DateTime.UtcNow.ToString("yyyy-MM");
            
            try
            {
                var existing = await UnitOfWork.Context.Set<Entities.Entities.ChatUsage>()
                    .FirstOrDefaultAsync(u => u.MonthKey == monthKey);

                if (existing != null)
                {
                    existing.UsdSpent += usdDelta;
                    existing.UpdatedAt = DateTime.UtcNow;
                    existing.MetaLast = metadata;
                    UnitOfWork.Context.Update(existing);
                }
                else
                {
                    var newUsage = new Entities.Entities.ChatUsage
                    {
                        MonthKey = monthKey,
                        UsdSpent = usdDelta,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow,
                        MetaLast = metadata
                    };
                    UnitOfWork.Context.Add(newUsage);
                }
                
                await UnitOfWork.Context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Nu s-a putut salva usage, continuăm");
            }
        }

        private async Task<decimal> GetMonthlySpentAsync(string monthKey)
        {
            try
            {
                var usage = await UnitOfWork.Context.Set<Entities.Entities.ChatUsage>()
                    .FirstOrDefaultAsync(u => u.MonthKey == monthKey);
                
                return usage?.UsdSpent ?? 0;
            }
            catch
            {
                return 0;
            }
        }

        public static decimal EstimateUsd(string model, int inputTokens, int outputTokens)
        {
            // Estimări conservative (USD / 1M tokens)
            decimal inRate = 3.0m;
            decimal outRate = 6.0m;

            if (model.Contains("gpt-4o-mini"))
            {
                inRate = 0.25m;
                outRate = 1.0m;
            }

            return (inputTokens / 1_000_000m) * inRate + (outputTokens / 1_000_000m) * outRate;
        }
    }
}

