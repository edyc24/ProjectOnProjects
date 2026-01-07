using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.User;
using System.Security.Claims;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UserFinancialDataController : ControllerBase
    {
        private readonly UserFinancialDataService _financialDataService;

        public UserFinancialDataController(UserFinancialDataService financialDataService)
        {
            _financialDataService = financialDataService;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                throw new UnauthorizedAccessException("Invalid user");
            }
            return userId;
        }

        /// <summary>
        /// Get user financial data
        /// </summary>
        [HttpGet("my-data")]
        public IActionResult GetMyFinancialData()
        {
            try
            {
                var userId = GetUserId();
                var data = _financialDataService.GetFinancialData(userId);

                if (data == null)
                {
                    return NotFound(new { message = "No financial data found" });
                }

                return Ok(new
                {
                    salariuNet = data.SalariuNet,
                    bonuriMasa = data.BonuriMasa,
                    sumaBonuriMasa = data.SumaBonuriMasa,
                    venitTotal = data.VenitTotal,
                    soldTotal = data.SoldTotal,
                    rataTotalaLunara = data.RataTotalaLunara,
                    nrCrediteBanci = data.NrCrediteBanci,
                    nrIfn = data.NrIfn,
                    poprire = data.Poprire,
                    intarzieri = data.Intarzieri,
                    intarzieriNumar = data.IntarzieriNumar,
                    dti = data.Dti,
                    scoringLevel = data.ScoringLevel,
                    recommendedLevel = data.RecommendedLevel,
                    lastUpdated = data.LastUpdated
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

