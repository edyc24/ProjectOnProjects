using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MandateService = MoneyShop.BusinessLogic.Implementation.Mandate.MandateService;
using System.Security.Claims;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MandateController : ControllerBase
    {
        private readonly MandateService _mandateService;

        public MandateController(MandateService mandateService)
        {
            _mandateService = mandateService;
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
        /// Create a new mandate (ANAF, BC, or ANAF_BC)
        /// </summary>
        [HttpPost("create")]
        public IActionResult CreateMandate([FromBody] MandateCreateModel model)
        {
            if (model == null || string.IsNullOrEmpty(model.MandateType))
            {
                return BadRequest(new { message = "MandateType is required" });
            }

            try
            {
                var userId = GetUserId();
                var result = _mandateService.CreateMandate(
                    userId,
                    model.MandateType,
                    model.ConsentEventId,
                    model.ExpiresInDays ?? 30
                );

                return Ok(new
                {
                    mandateId = result.MandateId,
                    status = result.Status,
                    grantedAt = result.GrantedAt,
                    expiresAt = result.ExpiresAt
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Get mandate by ID
        /// </summary>
        [HttpGet("{mandateId}")]
        public IActionResult GetMandate(Guid mandateId)
        {
            try
            {
                var userId = GetUserId();
                var mandate = _mandateService.GetMandate(mandateId, userId);

                if (mandate == null)
                {
                    return NotFound(new { message = "Mandate not found" });
                }

                return Ok(mandate);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// List all mandates for current user
        /// </summary>
        [HttpGet("list")]
        public IActionResult ListMandates()
        {
            try
            {
                var userId = GetUserId();
                var mandates = _mandateService.GetUserMandates(userId);

                return Ok(new { mandates });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Check if user has active mandate of specific type
        /// </summary>
        [HttpGet("check/{mandateType}")]
        public IActionResult CheckMandate(string mandateType)
        {
            try
            {
                var userId = GetUserId();
                var hasActive = _mandateService.HasActiveMandate(userId, mandateType);

                return Ok(new { hasActiveMandate = hasActive });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Revoke a mandate
        /// </summary>
        [HttpPost("revoke/{mandateId}")]
        public IActionResult RevokeMandate(Guid mandateId, [FromBody] MandateRevokeModel? model)
        {
            try
            {
                var userId = GetUserId();
                var success = _mandateService.RevokeMandate(mandateId, userId, model?.Reason);

                if (!success)
                {
                    return NotFound(new { message = "Mandate not found or not active" });
                }

                return Ok(new { message = "Mandate revoked successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }

    public class MandateCreateModel
    {
        public string MandateType { get; set; } = null!; // ANAF, BC, ANAF_BC
        public string? ConsentEventId { get; set; }
        public int? ExpiresInDays { get; set; } = 30;
    }

    public class MandateRevokeModel
    {
        public string? Reason { get; set; }
    }
}

