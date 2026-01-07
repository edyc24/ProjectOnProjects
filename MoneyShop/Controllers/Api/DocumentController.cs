using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PdfGenerationService = MoneyShop.BusinessLogic.Implementation.Document.PdfGenerationService;
using MandateService = MoneyShop.BusinessLogic.Implementation.Mandate.MandateService;
using System.Security.Claims;
using System.IO;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class DocumentController : ControllerBase
    {
        private readonly PdfGenerationService _pdfService;
        private readonly MandateService _mandateService;

        public DocumentController(
            PdfGenerationService pdfService,
            MandateService mandateService)
        {
            _pdfService = pdfService;
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
        /// Generate PDF for a mandate
        /// </summary>
        [HttpPost("mandate/{mandateId}/generate-pdf")]
        public IActionResult GenerateMandatePdf(Guid mandateId)
        {
            try
            {
                var userId = GetUserId();
                
                // Get mandate
                var mandate = _mandateService.GetMandate(mandateId, userId);
                if (mandate == null)
                {
                    return NotFound(new { message = "Mandate not found" });
                }

                // Get IP and User Agent
                var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
                var userAgent = HttpContext.Request.Headers["User-Agent"].ToString();

                // Generate PDF
                var result = _pdfService.GenerateMandatePdf(
                    mandateId,
                    userId,
                    mandate.MandateType,
                    null, // consentTextSnapshot - would need to get from consent
                    null, // consentEventId - would need to get from consent
                    ip,
                    userAgent,
                    mandate.GrantedAt,
                    mandate.ExpiresAt
                );

                return Ok(new
                {
                    blobPath = result.BlobPath,
                    sha256 = result.Sha256Base64,
                    fileSize = result.FileSize,
                    generatedAt = result.GeneratedAt
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Download mandate PDF
        /// </summary>
        [HttpGet("mandate/{mandateId}/download")]
        public IActionResult DownloadMandatePdf(Guid mandateId)
        {
            try
            {
                var userId = GetUserId();
                
                // Verify mandate belongs to user
                var mandate = _mandateService.GetMandate(mandateId, userId);
                if (mandate == null)
                {
                    return NotFound(new { message = "Mandate not found" });
                }

                // Generate PDF path
                var year = mandate.GrantedAt.Year;
                var month = mandate.GrantedAt.Month.ToString("D2");
                var blobPath = $"ms-docs/mandates/{year}/{month}/{mandateId}.pdf";
                var localPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", blobPath);

                if (!System.IO.File.Exists(localPath))
                {
                    // Generate PDF if it doesn't exist
                    var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
                    var userAgent = HttpContext.Request.Headers["User-Agent"].ToString();
                    
                    var pdfResult = _pdfService.GenerateMandatePdf(
                        mandateId,
                        userId,
                        mandate.MandateType,
                        null,
                        null,
                        ip,
                        userAgent,
                        mandate.GrantedAt,
                        mandate.ExpiresAt
                    );
                    
                    localPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", pdfResult.BlobPath);
                }

                if (!System.IO.File.Exists(localPath))
                {
                    return NotFound(new { message = "PDF not found" });
                }

                var fileBytes = System.IO.File.ReadAllBytes(localPath);
                return File(fileBytes, "application/pdf", $"{mandateId}.pdf");
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

