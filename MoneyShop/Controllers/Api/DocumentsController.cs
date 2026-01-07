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
    public class DocumentsController : ControllerBase
    {
        private readonly ApplicationService _applicationService;
        private readonly UnitOfWork _unitOfWork;

        public DocumentsController(ApplicationService applicationService, UnitOfWork unitOfWork)
        {
            _applicationService = applicationService;
            _unitOfWork = unitOfWork;
        }

        /// <summary>
        /// Upload a document for an application
        /// </summary>
        [HttpPost("upload")]
        public async Task<IActionResult> UploadDocument([FromForm] IFormFile file, [FromForm] int applicationId, [FromForm] string docType)
        {
            if (file == null || file.Length == 0)
                return BadRequest(new { message = "No file uploaded" });

            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var application = _applicationService.GetApplicationById(applicationId);
            if (application == null)
                return NotFound(new { message = "Application not found" });

            if (application.UserId != userId)
                return Forbid();

            // TODO: Upload to Azure Blob Storage
            // For now, we'll just save the metadata
            var document = new Document
            {
                ApplicationId = applicationId,
                DocType = docType,
                AzureBlobPath = $"temp/{applicationId}/{file.FileName}", // Temporary path
                FileName = file.FileName,
                FileSize = file.Length,
                MimeType = file.ContentType,
                CreatedAt = DateTime.UtcNow
            };

            _unitOfWork.Documents.Insert(document);
            _unitOfWork.SaveChanges();

            return Ok(new { id = document.Id, message = "Document uploaded successfully" });
        }

        /// <summary>
        /// Get all documents for an application
        /// </summary>
        [HttpGet("application/{applicationId}")]
        public IActionResult GetApplicationDocuments(int applicationId)
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var application = _applicationService.GetApplicationById(applicationId);
            if (application == null)
                return NotFound(new { message = "Application not found" });

            if (application.UserId != userId)
                return Forbid();

            var documents = _unitOfWork.Documents.Get()
                .Where(d => d.ApplicationId == applicationId)
                .ToList();

            return Ok(documents);
        }

        /// <summary>
        /// Get document by ID
        /// </summary>
        [HttpGet("{id}")]
        public IActionResult GetDocument(int id)
        {
            var document = _unitOfWork.Documents.Get()
                .FirstOrDefault(d => d.Id == id);

            if (document == null)
                return NotFound(new { message = "Document not found" });

            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var application = _applicationService.GetApplicationById(document.ApplicationId);
            if (application == null || application.UserId != userId)
                return Forbid();

            return Ok(document);
        }

        /// <summary>
        /// Delete document
        /// </summary>
        [HttpDelete("{id}")]
        public IActionResult DeleteDocument(int id)
        {
            var document = _unitOfWork.Documents.Get()
                .FirstOrDefault(d => d.Id == id);

            if (document == null)
                return NotFound();

            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var application = _applicationService.GetApplicationById(document.ApplicationId);
            if (application == null || application.UserId != userId)
                return Forbid();

            _unitOfWork.Documents.Delete(document);
            _unitOfWork.SaveChanges();

            return NoContent();
        }

        private int? GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                return null;
            return userId;
        }
    }
}

