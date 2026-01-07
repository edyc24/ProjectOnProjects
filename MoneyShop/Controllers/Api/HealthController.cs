using Microsoft.AspNetCore.Mvc;
using Microsoft.ApplicationInsights;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class HealthController : ControllerBase
    {
        private readonly TelemetryClient _telemetryClient;
        private readonly ILogger<HealthController> _logger;

        public HealthController(TelemetryClient telemetryClient, ILogger<HealthController> logger)
        {
            _telemetryClient = telemetryClient;
            _logger = logger;
        }

        /// <summary>
        /// Health check endpoint - returns 200 if app is healthy
        /// </summary>
        [HttpGet]
        [HttpGet("ping")]
        public IActionResult Health()
        {
            // Track custom metric for health checks
            _telemetryClient.TrackMetric("HealthCheck", 1);
            
            // Log health check
            _logger.LogInformation("Health check endpoint called at {Time}", DateTime.UtcNow);
            
            return Ok(new
            {
                status = "healthy",
                timestamp = DateTime.UtcNow,
                version = "1.0.0"
            });
        }
    }
}

