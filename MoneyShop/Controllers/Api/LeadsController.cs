using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Lead;
using MoneyShop.Entities.Entities;
using LeadEntity = MoneyShop.Entities.Entities.Lead;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class LeadsController : ControllerBase
    {
        private readonly LeadService _leadService;
        private readonly TelemetryClient _telemetryClient;
        private readonly ILogger<LeadsController> _logger;

        public LeadsController(LeadService leadService, TelemetryClient telemetryClient, ILogger<LeadsController> logger)
        {
            _leadService = leadService;
            _telemetryClient = telemetryClient;
            _logger = logger;
        }

        /// <summary>
        /// Create a new lead (public endpoint)
        /// </summary>
        [HttpPost]
        public IActionResult CreateLead([FromBody] LeadEntity lead)
        {
            // Track request start time for performance telemetry
            var startTime = DateTime.UtcNow;
            var requestTelemetry = HttpContext.Features.Get<Microsoft.ApplicationInsights.DataContracts.RequestTelemetry>();
            
            try
            {
                if (lead == null || string.IsNullOrEmpty(lead.Name) || string.IsNullOrEmpty(lead.Email))
                {
                    // Track validation error
                    _telemetryClient.TrackEvent("LeadValidationError", new Dictionary<string, string>
                    {
                        { "Error", "Name and email are required" },
                        { "Endpoint", "/api/leads" }
                    });
                    
                    _logger.LogWarning("Lead creation failed: Name and email are required");
                    return BadRequest(new { message = "Name and email are required" });
                }

                // Check for duplicate email (business rule for error trigger)
                var existingLead = _leadService.GetAllLeads().FirstOrDefault(l => l.Email == lead.Email);
                if (existingLead != null)
                {
                    // Track duplicate error
                    _telemetryClient.TrackException(new InvalidOperationException($"Duplicate lead with email: {lead.Email}"), new Dictionary<string, string>
                    {
                        { "Email", lead.Email },
                        { "Endpoint", "/api/leads" },
                        { "ErrorType", "DuplicateLead" }
                    });
                    
                    _logger.LogError("Lead creation failed: Duplicate email {Email}", lead.Email);
                    return Conflict(new { message = "A lead with this email already exists" });
                }

                // Get IP address
                lead.IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString();

                var created = _leadService.CreateLead(lead);
                
                // Business logging - Item successfully added
                _telemetryClient.TrackEvent("LeadSuccessfullyAdded", new Dictionary<string, string>
                {
                    { "LeadId", created.Id.ToString() },
                    { "Email", created.Email },
                    { "Name", created.Name },
                    { "TypeCredit", created.TypeCredit ?? "N/A" }
                });
                
                _logger.LogInformation("Lead successfully added: ID={LeadId}, Email={Email}, Name={Name}", 
                    created.Id, created.Email, created.Name);
                
                // Track request duration
                var duration = (DateTime.UtcNow - startTime).TotalMilliseconds;
                if (requestTelemetry != null)
                {
                    requestTelemetry.Properties.Add("LeadId", created.Id.ToString());
                    requestTelemetry.Properties.Add("LeadEmail", created.Email);
                }
                
                return CreatedAtAction(nameof(GetLead), new { id = created.Id }, created);
            }
            catch (Exception ex)
            {
                // Track exception
                _telemetryClient.TrackException(ex, new Dictionary<string, string>
                {
                    { "Endpoint", "/api/leads" },
                    { "ErrorType", "CreateLeadException" }
                });
                
                _logger.LogError(ex, "Error creating lead: {Message}", ex.Message);
                
                return StatusCode(500, new { message = "An error occurred while creating the lead", error = ex.Message });
            }
        }

        /// <summary>
        /// Get all leads (admin only)
        /// </summary>
        [HttpGet]
        [Authorize(Roles = "Admin")]
        public IActionResult GetLeads()
        {
            var leads = _leadService.GetAllLeads();
            return Ok(leads);
        }

        /// <summary>
        /// Get lead by ID
        /// </summary>
        [HttpGet("{id}")]
        [Authorize(Roles = "Admin")]
        public IActionResult GetLead(int id)
        {
            var lead = _leadService.GetLeadById(id);
            if (lead == null)
                return NotFound(new { message = "Lead not found" });

            return Ok(lead);
        }

        /// <summary>
        /// Convert lead to user (admin only)
        /// </summary>
        [HttpPut("{id}/convert")]
        [Authorize(Roles = "Admin")]
        public IActionResult ConvertLead(int id, [FromBody] ConvertLeadRequest request)
        {
            var lead = _leadService.GetLeadById(id);
            if (lead == null)
                return NotFound(new { message = "Lead not found" });

            _leadService.ConvertLeadToUser(id, request.UserId, request.ApplicationId);
            return Ok(new { message = "Lead converted successfully" });
        }
    }

    public class ConvertLeadRequest
    {
        public int UserId { get; set; }
        public int? ApplicationId { get; set; }
    }
}

