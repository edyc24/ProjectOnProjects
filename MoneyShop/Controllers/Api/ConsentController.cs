using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ConsentService = MoneyShop.BusinessLogic.Implementation.Consent.ConsentService;
using System.Security.Claims;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ConsentController : ControllerBase
    {
        private readonly ConsentService _consentService;

        public ConsentController(ConsentService consentService)
        {
            _consentService = consentService;
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
        /// Grant a consent with snapshot text
        /// </summary>
        [HttpPost("grant")]
        public IActionResult GrantConsent([FromBody] ConsentGrantModel model)
        {
            if (model == null || string.IsNullOrEmpty(model.ConsentType) || string.IsNullOrEmpty(model.ConsentTextSnapshot))
            {
                return BadRequest(new { message = "ConsentType and ConsentTextSnapshot are required" });
            }

            try
            {
                var userId = GetUserId();
                var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
                var userAgent = HttpContext.Request.Headers["User-Agent"].ToString();
                var deviceHash = ComputeDeviceHash();

                var result = _consentService.GrantConsent(
                    userId,
                    model.ConsentType,
                    model.DocType ?? "MANDATE",
                    model.DocVersion ?? "1.0.0",
                    model.ConsentTextSnapshot,
                    model.SessionId,
                    ip,
                    userAgent,
                    deviceHash,
                    model.SourceChannel ?? "web"
                );

                return Ok(new
                {
                    consentId = result.ConsentId,
                    status = result.Status,
                    grantedAt = result.GrantedAt
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// List consents for current user
        /// </summary>
        [HttpGet("list")]
        public IActionResult ListConsents()
        {
            try
            {
                var userId = GetUserId();
                var consents = _consentService.GetUserConsents(userId);

                return Ok(new { consents });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Revoke a consent
        /// </summary>
        [HttpPost("revoke/{consentId}")]
        public IActionResult RevokeConsent(Guid consentId)
        {
            try
            {
                var userId = GetUserId();
                var success = _consentService.RevokeConsent(consentId, userId);

                if (!success)
                {
                    return NotFound(new { message = "Consent not found or already revoked" });
                }

                return Ok(new { message = "Consent revoked successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        private byte[]? ComputeDeviceHash()
        {
            var userAgent = HttpContext.Request.Headers["User-Agent"].ToString();
            if (string.IsNullOrEmpty(userAgent))
                return null;

            using var sha256 = System.Security.Cryptography.SHA256.Create();
            return sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(userAgent));
        }
    }

    public class ConsentGrantModel
    {
        public string ConsentType { get; set; } = null!; // TC_ACCEPT, GDPR_ACCEPT, MANDATE_ANAF_BC, COSTS_ACCEPT, SHARE_TO_BROKER
        public string? DocType { get; set; } // TC, GDPR, COOKIES, MANDATE, BROKER_TRANSFER
        public string? DocVersion { get; set; }
        public string ConsentTextSnapshot { get; set; } = null!;
        public Guid? SessionId { get; set; }
        public string? SourceChannel { get; set; } // web/ios/android
    }
}

