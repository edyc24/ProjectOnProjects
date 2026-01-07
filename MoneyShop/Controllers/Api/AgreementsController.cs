using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Application;
using MoneyShop.DataAccess;
using MoneyShop.Entities.Entities;
using System.Security.Claims;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AgreementsController : ControllerBase
    {
        private readonly ApplicationService _applicationService;
        private readonly UnitOfWork _unitOfWork;

        public AgreementsController(ApplicationService applicationService, UnitOfWork unitOfWork)
        {
            _applicationService = applicationService;
            _unitOfWork = unitOfWork;
        }

        /// <summary>
        /// Generate PDF agreements for an application
        /// </summary>
        [HttpPost("generate")]
        public IActionResult GenerateAgreements([FromBody] GenerateAgreementsRequest request)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var application = _applicationService.GetApplicationById(request.ApplicationId);
            if (application == null)
                return NotFound(new { message = "Application not found" });

            if (application.UserId != userId)
                return Forbid();

            var agreementTypes = new[] { "acord_marketing", "consimtamant_gdpr", "acord_intermediere", "mandat_brokeraj" };

            var generatedAgreements = new List<Agreement>();

            foreach (var agreementType in agreementTypes)
            {
                // TODO: Generate actual PDF using iTextSharp/iText7
                // For now, we'll just create the agreement record
                var agreement = new Agreement
                {
                    ApplicationId = request.ApplicationId,
                    AgreementType = agreementType,
                    PdfBlobPath = $"agreements/{request.ApplicationId}/{agreementType}.pdf", // Temporary path
                    Version = "1.0",
                    CreatedAt = DateTime.UtcNow
                };

                _unitOfWork.Agreements.Insert(agreement);
                generatedAgreements.Add(agreement);
            }

            _unitOfWork.SaveChanges();

            return Ok(generatedAgreements);
        }

        /// <summary>
        /// Sign an agreement (upload signature image)
        /// </summary>
        [HttpPost("{id}/sign")]
        public async Task<IActionResult> SignAgreement(int id, [FromForm] IFormFile signature)
        {
            if (signature == null || signature.Length == 0)
                return BadRequest(new { message = "No signature uploaded" });

            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var agreement = _unitOfWork.Agreements.Get()
                .FirstOrDefault(a => a.Id == id);

            if (agreement == null)
                return NotFound(new { message = "Agreement not found" });

            var application = _applicationService.GetApplicationById(agreement.ApplicationId);
            if (application == null || application.UserId != userId)
                return Forbid();

            // TODO: Upload signature to Azure Blob and merge with PDF
            agreement.SignatureImagePath = $"signatures/{agreement.ApplicationId}/{id}.png"; // Temporary path
            agreement.SignedAt = DateTime.UtcNow;

            _unitOfWork.Agreements.Update(agreement);
            _unitOfWork.SaveChanges();

            return Ok(new { message = "Agreement signed successfully" });
        }

        /// <summary>
        /// Get all agreements for an application
        /// </summary>
        [HttpGet("application/{applicationId}")]
        public IActionResult GetApplicationAgreements(int applicationId)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var application = _applicationService.GetApplicationById(applicationId);
            if (application == null)
                return NotFound(new { message = "Application not found" });

            if (application.UserId != userId)
                return Forbid();

            var agreements = _unitOfWork.Agreements.Get()
                .Where(a => a.ApplicationId == applicationId)
                .ToList();

            return Ok(agreements);
        }

        /// <summary>
        /// Get agreement by ID
        /// </summary>
        [HttpGet("{id}")]
        public IActionResult GetAgreement(int id)
        {
            var agreement = _unitOfWork.Agreements.Get()
                .FirstOrDefault(a => a.Id == id);

            if (agreement == null)
                return NotFound(new { message = "Agreement not found" });

            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var application = _applicationService.GetApplicationById(agreement.ApplicationId);
            if (application == null || application.UserId != userId)
                return Forbid();

            return Ok(agreement);
        }

        private int? GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                return null;
            return userId;
        }
    }

    public class GenerateAgreementsRequest
    {
        public int ApplicationId { get; set; }
    }
}

