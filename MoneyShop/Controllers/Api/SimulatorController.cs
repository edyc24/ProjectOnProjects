using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Simulator;
using MoneyShop.BusinessLogic.Implementation.User;
using System.Security.Claims;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class SimulatorController : ControllerBase
    {
        private readonly ScoringService _scoringService;
        private readonly UserFinancialDataService _financialDataService;

        public SimulatorController(ScoringService scoringService, UserFinancialDataService financialDataService)
        {
            _scoringService = scoringService;
            _financialDataService = financialDataService;
        }

        private int? GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return null;
            }
            return userId;
        }

        /// <summary>
        /// Calculate credit scoring based on user input
        /// </summary>
        [HttpPost("calculate")]
        public IActionResult CalculateScoring([FromBody] ScoringRequest request)
        {
            if (request == null)
                return BadRequest(new { message = "Invalid request data" });

            try
            {
                var result = _scoringService.CalculateScoring(request);
                
                // If user is authenticated, save financial data
                var userId = GetUserId();
                if (userId.HasValue)
                {
                    _financialDataService.SaveFinancialData(userId.Value, request, result);
                }
                
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

