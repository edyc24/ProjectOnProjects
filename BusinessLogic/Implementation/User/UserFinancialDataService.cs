using System;
using System.Linq;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using UserFinancialDataEntity = MoneyShop.Entities.Entities.UserFinancialData;
using MoneyShop.BusinessLogic.Implementation.Simulator;

namespace MoneyShop.BusinessLogic.Implementation.User
{
    public class UserFinancialDataService : BaseService
    {
        private readonly ScoringService _scoringService;

        public UserFinancialDataService(ServiceDependencies dependencies, ScoringService scoringService)
            : base(dependencies)
        {
            _scoringService = scoringService;
        }

        /// <summary>
        /// Saves or updates user financial data from simulator calculation
        /// </summary>
        public UserFinancialDataEntity SaveFinancialData(int userId, ScoringRequest request, ScoringResult result)
        {
            // Calculate total income
            decimal venitTotal = request.SalariuNet;
            if (request.BonuriMasa == true && request.SumaBonuriMasa.HasValue)
            {
                venitTotal += request.SumaBonuriMasa.Value;
            }

            // Calculate total monthly rate (approximate)
            decimal rataTotalaLunara = 0;
            if (request.SoldTotal.HasValue)
            {
                rataTotalaLunara = request.SoldTotal.Value * 0.05m / 12; // ~5% per year / 12 months
            }

            // Get or create financial data
            var existing = UnitOfWork.UserFinancialData.Get()
                .FirstOrDefault(f => f.UserId == userId);

            if (existing != null)
            {
                // Update existing
                existing.SalariuNet = request.SalariuNet;
                existing.BonuriMasa = request.BonuriMasa;
                existing.SumaBonuriMasa = request.SumaBonuriMasa;
                existing.VenitTotal = venitTotal;
                existing.SoldTotal = request.SoldTotal;
                existing.RataTotalaLunara = rataTotalaLunara;
                existing.NrCrediteBanci = request.NrCrediteBanci;
                existing.NrIfn = request.NrIfn;
                existing.Poprire = request.Poprire;
                existing.Intarzieri = request.Intarzieri;
                existing.IntarzieriNumar = request.IntarzieriNumar;
                existing.Dti = result.Dti;
                existing.ScoringLevel = result.ScoringLevel;
                existing.RecommendedLevel = result.RecommendedLevel;
                existing.LastUpdated = DateTime.UtcNow;

                UnitOfWork.UserFinancialData.Update(existing);
            }
            else
            {
                // Create new
                existing = new UserFinancialDataEntity
                {
                    UserId = userId,
                    SalariuNet = request.SalariuNet,
                    BonuriMasa = request.BonuriMasa,
                    SumaBonuriMasa = request.SumaBonuriMasa,
                    VenitTotal = venitTotal,
                    SoldTotal = request.SoldTotal,
                    RataTotalaLunara = rataTotalaLunara,
                    NrCrediteBanci = request.NrCrediteBanci,
                    NrIfn = request.NrIfn,
                    Poprire = request.Poprire,
                    Intarzieri = request.Intarzieri,
                    IntarzieriNumar = request.IntarzieriNumar,
                    Dti = result.Dti,
                    ScoringLevel = result.ScoringLevel,
                    RecommendedLevel = result.RecommendedLevel,
                    CreatedAt = DateTime.UtcNow,
                    LastUpdated = DateTime.UtcNow
                };

                UnitOfWork.UserFinancialData.Insert(existing);
            }

            UnitOfWork.SaveChanges();
            return existing;
        }

        /// <summary>
        /// Gets user financial data
        /// </summary>
        public UserFinancialDataEntity? GetFinancialData(int userId)
        {
            return UnitOfWork.UserFinancialData.Get()
                .FirstOrDefault(f => f.UserId == userId);
        }
    }
}

