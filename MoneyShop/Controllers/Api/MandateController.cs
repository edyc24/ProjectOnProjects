using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Document;
using MoneyShop.BusinessLogic.Implementation.Mandate;
using MoneyShop.DataAccess;
using System;
using System.Linq;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class MandateController : ControllerBase
    {
        private readonly MandateService _mandateService;
        private readonly PdfGenerationService _pdfService;
        private readonly UnitOfWork _unitOfWork;

        public MandateController(
            MandateService mandateService, 
            PdfGenerationService pdfService,
            UnitOfWork unitOfWork)
        {
            _mandateService = mandateService;
            _pdfService = pdfService;
            _unitOfWork = unitOfWork;
        }

        /// <summary>
        /// Get all mandates for a user
        /// </summary>
        [HttpGet("list/{userId}")]
        public IActionResult GetMandates(int userId)
        {
            var mandates = _unitOfWork.Mandates.Get()
                .Where(m => m.UserId == userId)
                .OrderByDescending(m => m.GrantedAt)
                .Select(m => new
                {
                    m.MandateId,
                    m.MandateType,
                    m.Scope,
                    m.Status,
                    m.GrantedAt,
                    m.ExpiresAt,
                    m.RevokedAt,
                    DaysRemaining = m.Status == "active" 
                        ? (int)Math.Max(0, (m.ExpiresAt - DateTime.UtcNow).TotalDays) 
                        : 0,
                    IsExpired = m.ExpiresAt < DateTime.UtcNow
                })
                .ToList();

            return Ok(new { mandates });
        }

        /// <summary>
        /// Get mandate details
        /// </summary>
        [HttpGet("{mandateId}")]
        public IActionResult GetMandate(Guid mandateId)
        {
            var mandate = _unitOfWork.Mandates.Get()
                .FirstOrDefault(m => m.MandateId == mandateId);

            if (mandate == null)
            {
                return NotFound(new { message = "Mandate not found" });
            }

            return Ok(new
            {
                mandate.MandateId,
                mandate.MandateType,
                mandate.Scope,
                mandate.Status,
                mandate.GrantedAt,
                mandate.ExpiresAt,
                mandate.RevokedAt,
                mandate.RevokedReason,
                DaysRemaining = mandate.Status == "active"
                    ? (int)Math.Max(0, (mandate.ExpiresAt - DateTime.UtcNow).TotalDays)
                    : 0,
                IsExpired = mandate.ExpiresAt < DateTime.UtcNow
            });
        }

        /// <summary>
        /// Revoke a mandate
        /// </summary>
        [HttpPost("{mandateId}/revoke")]
        public IActionResult RevokeMandate(Guid mandateId, [FromBody] RevokeRequest request)
        {
            var mandate = _unitOfWork.Mandates.Get()
                .FirstOrDefault(m => m.MandateId == mandateId);

            if (mandate == null)
            {
                return NotFound(new { message = "Mandate not found" });
            }

            if (mandate.Status != "active")
            {
                return BadRequest(new { message = "Mandate is not active" });
            }

            mandate.Status = "revoked";
            mandate.RevokedAt = DateTime.UtcNow;
            mandate.RevokedReason = request?.Reason ?? "User requested revocation";
            
            _unitOfWork.SaveChanges();

            return Ok(new
            {
                message = "Mandate revoked successfully",
                mandate.MandateId,
                mandate.Status,
                mandate.RevokedAt
            });
        }

        /// <summary>
        /// Generate PDF for a mandate
        /// </summary>
        [HttpPost("{mandateId}/generate-pdf")]
        public IActionResult GeneratePdf(Guid mandateId)
        {
            var mandate = _unitOfWork.Mandates.Get()
                .FirstOrDefault(m => m.MandateId == mandateId);

            if (mandate == null)
            {
                return NotFound(new { message = "Mandate not found" });
            }

            // Get consent for this mandate
            var consent = _unitOfWork.Consents.Get()
                .FirstOrDefault(c => c.UserId == mandate.UserId && 
                                   c.ConsentType.Contains("MANDATE") &&
                                   c.GrantedAt >= mandate.GrantedAt.AddSeconds(-5) &&
                                   c.GrantedAt <= mandate.GrantedAt.AddSeconds(5));

            try
            {
                var result = _pdfService.GenerateMandatePdf(
                    mandate.MandateId,
                    mandate.UserId,
                    mandate.MandateType,
                    consent?.ConsentTextSnapshot,
                    mandate.ConsentEventId,
                    consent?.Ip,
                    consent?.UserAgent,
                    mandate.GrantedAt,
                    mandate.ExpiresAt
                );

                return Ok(new
                {
                    message = "PDF generated successfully",
                    blobPath = result.BlobPath,
                    sha256 = result.Sha256Base64,
                    fileSize = result.FileSize,
                    generatedAt = result.GeneratedAt,
                    downloadUrl = $"/api/mandate/{mandateId}/download"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = $"Error generating PDF: {ex.Message}" });
            }
        }

        /// <summary>
        /// Download mandate PDF
        /// </summary>
        [HttpGet("{mandateId}/download")]
        public IActionResult DownloadPdf(Guid mandateId)
        {
            var mandate = _unitOfWork.Mandates.Get()
                .FirstOrDefault(m => m.MandateId == mandateId);

            if (mandate == null)
            {
                return NotFound(new { message = "Mandate not found" });
            }

            // Construct file path
            var year = mandate.GrantedAt.Year;
            var month = mandate.GrantedAt.Month.ToString("D2");
            var blobPath = $"ms-docs/mandates/{year}/{month}/{mandateId}.pdf";
            var localPath = System.IO.Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", blobPath);

            // Check if file exists, if not generate it
            if (!System.IO.File.Exists(localPath))
            {
                // Try to generate PDF first
                var generateResult = GeneratePdf(mandateId);
                if (generateResult is not OkObjectResult)
                {
                    return generateResult;
                }
            }

            if (!System.IO.File.Exists(localPath))
            {
                return NotFound(new { message = "PDF file not found" });
            }

            var fileBytes = System.IO.File.ReadAllBytes(localPath);
            var fileName = $"Mandat_{mandate.MandateType}_{mandate.GrantedAt:yyyyMMdd}.pdf";

            return File(fileBytes, "application/pdf", fileName);
        }

        /// <summary>
        /// Create a new mandate (with OTP verification)
        /// </summary>
        [HttpPost("create")]
        public IActionResult CreateMandate([FromBody] CreateMandateRequest request)
        {
            if (request == null || request.UserId <= 0)
            {
                return BadRequest(new { message = "Invalid request" });
            }

            // Verify user exists
            var user = _unitOfWork.Users.Get()
                .FirstOrDefault(u => u.IdUtilizator == request.UserId);

            if (user == null)
            {
                return NotFound(new { message = "User not found" });
            }

            // Create mandate
            var mandate = new MoneyShop.Entities.Entities.Mandate
            {
                MandateId = Guid.NewGuid(),
                UserId = request.UserId,
                MandateType = request.MandateType ?? "ANAF",
                Scope = request.Scope ?? "credit_eligibility_only",
                Status = "active",
                GrantedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddDays(request.ExpiresInDays > 0 ? request.ExpiresInDays : 30),
                ConsentEventId = request.ConsentEventId
            };

            _unitOfWork.Mandates.Insert(mandate);

            // Also create consent record
            var consent = new MoneyShop.Entities.Entities.Consent
            {
                ConsentId = Guid.NewGuid(),
                UserId = request.UserId,
                ConsentType = $"MANDATE_{request.MandateType ?? "ANAF"}",
                Status = "granted",
                GrantedAt = DateTime.UtcNow,
                ConsentTextSnapshot = request.ConsentText ?? GetDefaultConsentText(request.MandateType),
                Ip = HttpContext.Connection.RemoteIpAddress?.ToString(),
                UserAgent = HttpContext.Request.Headers["User-Agent"].ToString(),
                SourceChannel = request.SourceChannel ?? "web"
            };

            _unitOfWork.Consents.Insert(consent);
            _unitOfWork.SaveChanges();

            return Ok(new
            {
                message = "Mandate created successfully",
                mandateId = mandate.MandateId,
                status = mandate.Status,
                grantedAt = mandate.GrantedAt,
                expiresAt = mandate.ExpiresAt
            });
        }

        private string GetDefaultConsentText(string? mandateType)
        {
            return mandateType?.ToUpper() switch
            {
                "ANAF" => "Împuternicesc MoneyShop să interogheze ANAF pentru verificarea veniturilor mele în scopul determinării eligibilității pentru credite. Valabilitate: 30 de zile.",
                "BC" => "Împuternicesc MoneyShop să interogheze Biroul de Credit pentru o analiză completă a eligibilității mele. Valabilitate: 30 de zile.",
                "ANAF_BC" => "Împuternicesc MoneyShop să interogheze ANAF și Biroul de Credit pentru o analiză completă a eligibilității mele. Valabilitate: 30 de zile.",
                _ => "Împuternicesc MoneyShop pentru verificarea eligibilității creditului. Valabilitate: 30 de zile."
            };
        }
    }

    public class RevokeRequest
    {
        public string? Reason { get; set; }
    }

    public class CreateMandateRequest
    {
        public int UserId { get; set; }
        public string? MandateType { get; set; } // ANAF, BC, ANAF_BC
        public string? Scope { get; set; }
        public int ExpiresInDays { get; set; } = 30;
        public string? ConsentEventId { get; set; }
        public string? ConsentText { get; set; }
        public string? SourceChannel { get; set; }
    }
}
