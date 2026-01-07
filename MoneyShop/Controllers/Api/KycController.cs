using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using KycService = MoneyShop.BusinessLogic.Implementation.Kyc.KycService;
using System.Security.Claims;
using MoneyShop.DataAccess;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class KycController : ControllerBase
    {
        private readonly KycService _kycService;
        private readonly IWebHostEnvironment _environment;
        private readonly IConfiguration _configuration;
        private readonly UnitOfWork _unitOfWork;

        public KycController(
            KycService kycService,
            IWebHostEnvironment environment,
            IConfiguration configuration,
            UnitOfWork unitOfWork)
        {
            _kycService = kycService;
            _environment = environment;
            _configuration = configuration;
            _unitOfWork = unitOfWork;
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
        /// Start a new KYC session
        /// </summary>
        [HttpPost("start")]
        public IActionResult StartKycSession([FromBody] KycStartModel? model)
        {
            try
            {
                var userId = GetUserId();
                var kycType = model?.KycType ?? "USER_KYC";
                var result = _kycService.StartKycSession(userId, kycType);

                return Ok(new
                {
                    kycId = result.KycId,
                    status = result.Status,
                    createdAt = result.CreatedAt,
                    expiresAt = result.ExpiresAt
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Upload a file for KYC verification
        /// </summary>
        [HttpPost("upload")]
        [RequestSizeLimit(10_000_000)] // 10MB limit
        public async Task<IActionResult> UploadKycFile([FromForm] KycUploadModel model)
        {
            // Check ModelState for binding errors
            if (!ModelState.IsValid)
            {
                var errors = ModelState
                    .Where(x => x.Value?.Errors.Count > 0)
                    .Select(x => new { Field = x.Key, Errors = x.Value?.Errors.Select(e => e.ErrorMessage) })
                    .ToList();
                System.Diagnostics.Debug.WriteLine($"UploadKycFile ModelState errors: {System.Text.Json.JsonSerializer.Serialize(errors)}");
                return BadRequest(new { message = "Invalid model data", errors = errors });
            }

            if (model == null || model.File == null)
            {
                System.Diagnostics.Debug.WriteLine("UploadKycFile: model or File is null");
                return BadRequest(new { message = "File is required" });
            }

            if (string.IsNullOrEmpty(model.FileType))
            {
                System.Diagnostics.Debug.WriteLine("UploadKycFile: FileType is null or empty");
                return BadRequest(new { message = "FileType is required" });
            }

            if (model.KycId == Guid.Empty)
            {
                System.Diagnostics.Debug.WriteLine("UploadKycFile: KycId is empty");
                return BadRequest(new { message = "KycId is required" });
            }

            try
            {
                var userId = GetUserId();

                // Validate file type
                var allowedTypes = new[] { "selfie", "id_front", "id_back", "proof_of_address" };
                if (!allowedTypes.Contains(model.FileType.ToLower()))
                {
                    return BadRequest(new { message = $"Invalid file type. Allowed: {string.Join(", ", allowedTypes)}" });
                }

                // Validate file size (max 10MB)
                if (model.File.Length > 10_000_000)
                {
                    return BadRequest(new { message = "File size exceeds 10MB limit" });
                }

                // Read file content
                byte[] fileContent;
                using (var memoryStream = new MemoryStream())
                {
                    await model.File.CopyToAsync(memoryStream);
                    fileContent = memoryStream.ToArray();
                }

                // Store file as base64 in database (no need for blob storage)
                var kycId = model.KycId;

                // Add file to KYC session (stored as base64 in database)
                System.Diagnostics.Debug.WriteLine($"[UploadKycFile] Calling AddKycFile - KycId: {kycId}, UserId: {userId}, FileType: {model.FileType}, FileName: {model.File.FileName}, ContentType: {model.File.ContentType ?? "null"}, FileSize: {model.File.Length}, ContentLength: {fileContent.Length}");
                var result = _kycService.AddKycFile(
                    kycId,
                    userId,
                    model.FileType,
                    null, // No blob path needed, storing as base64
                    model.File.FileName,
                    model.File.ContentType ?? "application/octet-stream", // Default if null
                    model.File.Length,
                    fileContent
                );

                System.Diagnostics.Debug.WriteLine($"UploadKycFile: Successfully saved file, FileId: {result.FileId}");
                return Ok(new
                {
                    fileId = result.FileId,
                    fileType = result.FileType,
                    blobPath = result.BlobPath,
                    createdAt = result.CreatedAt,
                    expiresAt = result.ExpiresAt
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                System.Diagnostics.Debug.WriteLine($"UploadKycFile: Unauthorized - {ex.Message}");
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                // Log the full exception for debugging
                System.Diagnostics.Debug.WriteLine($"UploadKycFile error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner exception: {ex.InnerException.Message}");
                    System.Diagnostics.Debug.WriteLine($"Inner stack trace: {ex.InnerException.StackTrace}");
                }
                // Return more detailed error information
                var errorDetails = new
                {
                    message = ex.Message,
                    type = ex.GetType().Name,
                    innerException = ex.InnerException != null ? ex.InnerException.Message : null,
                    stackTrace = ex.StackTrace
                };
                return BadRequest(errorDetails);
            }
        }

        /// <summary>
        /// Get KYC status for current user
        /// </summary>
        [HttpGet("status")]
        public IActionResult GetKycStatus([FromQuery] string? kycType)
        {
            try
            {
                var userId = GetUserId();
                var result = _kycService.GetKycStatus(userId, kycType ?? "USER_KYC");

                if (result == null)
                {
                    return NotFound(new { message = "No KYC session found" });
                }

                // Get session to include form data fields
                var session = _unitOfWork.KycSessions.Get()
                    .FirstOrDefault(k => k.KycId == result.KycId);

                return Ok(new
                {
                    kycId = result.KycId,
                    status = result.Status,
                    createdAt = result.CreatedAt,
                    verifiedAt = result.VerifiedAt,
                    expiresAt = result.ExpiresAt,
                    rejectionReason = result.RejectionReason,
                    files = result.Files,
                    // Include form data fields
                    cnp = session?.Cnp,
                    address = session?.Address,
                    city = session?.City,
                    county = session?.County,
                    postalCode = session?.PostalCode
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Get all pending KYC sessions (admin only)
        /// </summary>
        [HttpGet("pending")]
        [Authorize(Roles = "Administrator")]
        public IActionResult GetAllPendingKyc()
        {
            try
            {
                var result = _kycService.GetAllPendingKyc();

                return Ok(result.Select(k => new
                {
                    kycId = k.KycId,
                    userId = k.UserId,
                    userName = k.UserName,
                    userEmail = k.UserEmail,
                    kycType = k.KycType,
                    createdAt = k.CreatedAt,
                    expiresAt = k.ExpiresAt,
                    fileCount = k.FileCount
                }).ToList());
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Get KYC details for admin review (admin only)
        /// </summary>
        [HttpGet("details/{kycId}")]
        [Authorize(Roles = "Administrator")]
        public IActionResult GetKycDetails(Guid kycId)
        {
            try
            {
                var session = _kycService.GetKycDetails(kycId);
                if (session == null)
                {
                    return NotFound(new { message = "KYC session not found" });
                }

                return Ok(new
                {
                    kycId = session.KycId,
                    userId = session.UserId,
                    userName = session.UserName,
                    userEmail = session.UserEmail,
                    status = session.Status,
                    createdAt = session.CreatedAt,
                    expiresAt = session.ExpiresAt,
                    rejectionReason = session.RejectionReason,
                    files = session.Files.Select(f => new
                    {
                        fileId = f.FileId,
                        fileType = f.FileType,
                        fileName = f.FileName,
                        blobPath = f.BlobPath, // Deprecated, kept for backward compatibility
                        fileContentBase64 = f.FileContentBase64, // Base64 encoded file content
                        mimeType = f.MimeType,
                        dataUri = !string.IsNullOrEmpty(f.FileContentBase64) 
                            ? $"data:{f.MimeType};base64,{f.FileContentBase64}" 
                            : null,
                        createdAt = f.CreatedAt
                    }),
                    // Include form data fields
                    cnp = session.Cnp,
                    address = session.Address,
                    city = session.City,
                    county = session.County,
                    postalCode = session.PostalCode
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Get KYC file for admin review (admin only)
        /// Returns file as JSON with base64 content
        /// </summary>
        [HttpGet("file/{fileId}")]
        [Authorize(Roles = "Administrator")]
        public IActionResult GetKycFile(Guid fileId)
        {
            try
            {
                var file = _kycService.GetKycFile(fileId);
                if (file == null)
                {
                    return NotFound(new { message = "File not found" });
                }

                // Return file as JSON with base64 content (stored in database)
                return Ok(new
                {
                    fileId = file.FileId,
                    fileType = file.FileType,
                    fileName = file.FileName,
                    blobPath = file.BlobPath, // Deprecated, kept for backward compatibility
                    fileContentBase64 = file.FileContentBase64, // Base64 encoded file content
                    mimeType = file.MimeType,
                    dataUri = !string.IsNullOrEmpty(file.FileContentBase64)
                        ? $"data:{file.MimeType};base64,{file.FileContentBase64}"
                        : null, // Pre-formatted data URI for easy display
                    createdAt = file.CreatedAt
                });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[GetKycFile] Error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"[GetKycFile] Stack trace: {ex.StackTrace}");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Update KYC form data (CNP, address, etc.)
        /// </summary>
        [HttpPost("update-form-data")]
        public IActionResult UpdateKycFormData([FromBody] KycFormDataModel model)
        {
            // Check ModelState for binding errors
            if (!ModelState.IsValid)
            {
                var errors = ModelState
                    .Where(x => x.Value?.Errors.Count > 0)
                    .Select(x => new { Field = x.Key, Errors = x.Value?.Errors.Select(e => e.ErrorMessage) })
                    .ToList();
                return BadRequest(new { message = "Invalid model data", errors = errors });
            }

            if (model == null)
            {
                return BadRequest(new { message = "Form data is required" });
            }

            // Validate KycId
            if (model.KycId == Guid.Empty)
            {
                return BadRequest(new { message = "KycId is required and must be a valid GUID", receivedKycId = model.KycId });
            }

            try
            {
                var userId = GetUserId();
                
                // Log for debugging
                System.Diagnostics.Debug.WriteLine($"UpdateKycFormData: KycId={model.KycId}, UserId={userId}, Address={model.Address}, City={model.City}");
                
                var success = _kycService.UpdateKycFormData(
                    model.KycId,
                    userId,
                    model.Cnp,
                    model.Address,
                    model.City,
                    model.County,
                    model.PostalCode
                );

                if (!success)
                {
                    return NotFound(new { message = "KYC session not found or access denied", kycId = model.KycId, userId = userId });
                }

                return Ok(new { message = "KYC form data updated successfully", kycId = model.KycId });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"UpdateKycFormData error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                return BadRequest(new { message = ex.Message, details = ex.ToString() });
            }
        }

        /// <summary>
        /// Update KYC status (admin only)
        /// </summary>
        [HttpPost("update-status")]
        [Authorize(Roles = "Administrator")]
        public IActionResult UpdateKycStatus([FromBody] KycStatusUpdateModel model)
        {
            if (model == null || string.IsNullOrEmpty(model.Status))
            {
                return BadRequest(new { message = "Status is required" });
            }

            if (model.Status == "rejected" && string.IsNullOrEmpty(model.RejectionReason))
            {
                return BadRequest(new { message = "Rejection reason is required when rejecting KYC" });
            }

            try
            {
                var success = _kycService.UpdateKycStatus(
                    model.KycId,
                    model.Status,
                    model.RejectionReason,
                    model.ProviderTransactionId
                );

                if (!success)
                {
                    return NotFound(new { message = "KYC session not found" });
                }

                return Ok(new { message = "KYC status updated successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }

    public class KycStartModel
    {
        public string? KycType { get; set; } = "USER_KYC";
    }

    public class KycUploadModel
    {
        public Guid KycId { get; set; }
        public string FileType { get; set; } = null!; // selfie, id_front, id_back, proof_of_address
        public IFormFile File { get; set; } = null!;
    }

    public class KycStatusUpdateModel
    {
        public Guid KycId { get; set; }
        public string Status { get; set; } = null!; // verified, rejected
        public string? RejectionReason { get; set; }
        public string? ProviderTransactionId { get; set; }
    }

    public class KycFormDataModel
    {
        public Guid KycId { get; set; }
        public string? Cnp { get; set; }
        public string? Address { get; set; }
        public string? City { get; set; }
        public string? County { get; set; }
        public string? PostalCode { get; set; }
    }
}

