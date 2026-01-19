using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Eligibility;
using MoneyShop.BusinessLogic.Models.Eligibility;
using System.Security.Claims;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class EligibilityController : ControllerBase
    {
        private readonly SimpleEligibilityEngine _simpleEngine;
        private readonly EligibilityConfigService _configService;

        public EligibilityController(
            SimpleEligibilityEngine simpleEngine,
            EligibilityConfigService configService)
        {
            _simpleEngine = simpleEngine;
            _configService = configService;
        }

        /// <summary>
        /// Calculator simplu (fără cont, fără ANAF/BC)
        /// </summary>
        [HttpPost("simple")]
        [AllowAnonymous]
        public async Task<IActionResult> CalculateSimple([FromBody] CalcSimpleRequest request)
        {
            if (request == null)
                return BadRequest(new { message = "Invalid request data" });

            if (string.IsNullOrEmpty(request.LoanType) || 
                (request.LoanType != "NP" && request.LoanType != "IPOTECAR"))
            {
                return BadRequest(new { message = "LoanType must be 'NP' or 'IPOTECAR'" });
            }

            if (request.SalaryNetUser <= 0)
            {
                return BadRequest(new { message = "SalaryNetUser must be greater than 0" });
            }

            try
            {
                var result = await _simpleEngine.CalculateAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Calculator verificat (KYC + ANAF + BC) - TODO: implementare
        /// </summary>
        [HttpPost("verified")]
        [Authorize]
        public async Task<IActionResult> CalculateVerified([FromBody] CalcVerifiedRequest request)
        {
            // TODO: Implementare VerifiedEligibilityEngine
            return StatusCode(501, new { message = "Verified eligibility calculator not yet implemented" });
        }

        /// <summary>
        /// Obține configurația activă (admin only)
        /// </summary>
        [HttpGet("config")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetConfig()
        {
            try
            {
                var config = await _configService.GetActiveConfigAsync();
                return Ok(config);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

