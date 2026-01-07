using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Application;
using MoneyShop.Entities.Entities;
using System.Security.Claims;
using ApplicationEntity = MoneyShop.Entities.Entities.Application;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ApplicationsController : ControllerBase
    {
        private readonly ApplicationService _applicationService;
        private readonly TelemetryClient _telemetryClient;
        private readonly ILogger<ApplicationsController> _logger;

        public ApplicationsController(ApplicationService applicationService, TelemetryClient telemetryClient, ILogger<ApplicationsController> logger)
        {
            _applicationService = applicationService;
            _telemetryClient = telemetryClient;
            _logger = logger;
        }

        /// <summary>
        /// Get all applications for current user
        /// </summary>
        [HttpGet]
        public IActionResult GetApplications()
        {
            var userId = GetCurrentUserId();
            if (userId == null)
                return Unauthorized();

            var applications = _applicationService.GetUserApplications(userId.Value);
            return Ok(applications);
        }

        /// <summary>
        /// Get application by ID
        /// </summary>
        [HttpGet("{id}")]
        public IActionResult GetApplication(int id)
        {
            var application = _applicationService.GetApplicationById(id);
            if (application == null)
                return NotFound(new { message = "Application not found" });

            var userId = GetCurrentUserId();
            if (application.UserId != userId)
                return Forbid();

            return Ok(application);
        }

        /// <summary>
        /// Create new application
        /// </summary>
        [HttpPost]
        public IActionResult CreateApplication([FromBody] ApplicationEntity application)
        {
            var startTime = DateTime.UtcNow;
            var requestTelemetry = HttpContext.Features.Get<Microsoft.ApplicationInsights.DataContracts.RequestTelemetry>();
            
            try
            {
                if (application == null)
                {
                    _telemetryClient.TrackEvent("ApplicationValidationError", new Dictionary<string, string>
                    {
                        { "Error", "Invalid application data" },
                        { "Endpoint", "/api/applications" }
                    });
                    
                    _logger.LogWarning("Application creation failed: Invalid application data");
                    return BadRequest(new { message = "Invalid application data" });
                }

                var userId = GetCurrentUserId();
                if (userId == null)
                {
                    _logger.LogWarning("Application creation failed: Unauthorized");
                    return Unauthorized();
                }

                // Check for duplicate application (same user, same type credit) - business rule for error trigger
                var existingApplications = _applicationService.GetUserApplications(userId.Value);
                if (existingApplications.Any(a => a.TypeCredit == application.TypeCredit && 
                                                   a.Status == "INREGISTRAT" && 
                                                   a.TipOperatiune == application.TipOperatiune))
                {
                    _telemetryClient.TrackException(new InvalidOperationException($"Duplicate application for user {userId}"), new Dictionary<string, string>
                    {
                        { "UserId", userId.Value.ToString() },
                        { "TypeCredit", application.TypeCredit ?? "N/A" },
                        { "Endpoint", "/api/applications" },
                        { "ErrorType", "DuplicateApplication" }
                    });
                    
                    _logger.LogError("Application creation failed: Duplicate application for user {UserId}, TypeCredit={TypeCredit}", 
                        userId.Value, application.TypeCredit);
                    return Conflict(new { message = "An application of this type already exists" });
                }

                application.UserId = userId.Value;
                var created = _applicationService.CreateApplication(application);
                
                // Business logging - Item successfully added
                _telemetryClient.TrackEvent("ApplicationSuccessfullyAdded", new Dictionary<string, string>
                {
                    { "ApplicationId", created.Id.ToString() },
                    { "UserId", userId.Value.ToString() },
                    { "TypeCredit", created.TypeCredit ?? "N/A" },
                    { "Status", created.Status }
                });
                
                _logger.LogInformation("Application successfully added: ID={ApplicationId}, UserId={UserId}, TypeCredit={TypeCredit}", 
                    created.Id, userId.Value, created.TypeCredit);
                
                // Track request duration and properties
                var duration = (DateTime.UtcNow - startTime).TotalMilliseconds;
                if (requestTelemetry != null)
                {
                    requestTelemetry.Properties.Add("ApplicationId", created.Id.ToString());
                    requestTelemetry.Properties.Add("TypeCredit", created.TypeCredit ?? "N/A");
                }
                
                return CreatedAtAction(nameof(GetApplication), new { id = created.Id }, created);
            }
            catch (Exception ex)
            {
                _telemetryClient.TrackException(ex, new Dictionary<string, string>
                {
                    { "Endpoint", "/api/applications" },
                    { "ErrorType", "CreateApplicationException" }
                });
                
                _logger.LogError(ex, "Error creating application: {Message}", ex.Message);
                
                return StatusCode(500, new { message = "An error occurred while creating the application", error = ex.Message });
            }
        }

        /// <summary>
        /// Update application
        /// </summary>
        [HttpPut("{id}")]
        public IActionResult UpdateApplication(int id, [FromBody] ApplicationEntity application)
        {
            if (application == null || application.Id != id)
                return BadRequest();

            var existing = _applicationService.GetApplicationById(id);
            if (existing == null)
                return NotFound();

            var userId = GetCurrentUserId();
            if (existing.UserId != userId)
                return Forbid();

            application.Id = id;
            application.UserId = existing.UserId;
            var updated = _applicationService.UpdateApplication(application);
            return Ok(updated);
        }

        /// <summary>
        /// Delete application
        /// </summary>
        [HttpDelete("{id}")]
        public IActionResult DeleteApplication(int id)
        {
            var application = _applicationService.GetApplicationById(id);
            if (application == null)
                return NotFound();

            var userId = GetCurrentUserId();
            if (application.UserId != userId)
                return Forbid();

            _applicationService.DeleteApplication(id);
            return NoContent();
        }

        /// <summary>
        /// Get application status
        /// </summary>
        [HttpGet("{id}/status")]
        public IActionResult GetApplicationStatus(int id)
        {
            var application = _applicationService.GetApplicationById(id);
            if (application == null)
                return NotFound();

            var userId = GetCurrentUserId();
            if (application.UserId != userId)
                return Forbid();

            return Ok(new { status = application.Status });
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

