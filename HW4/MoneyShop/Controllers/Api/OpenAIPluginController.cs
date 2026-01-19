using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.OpenAIPlugin;

namespace MoneyShop.Controllers.Api
{
    /// <summary>
    /// OpenAI Plugin Controller - Azure OpenAI Integration
    /// This controller implements the OpenAI plugin specification for HW4
    /// It is separate from the existing ChatController and does not interfere with existing functionality
    /// </summary>
    [ApiController]
    [Route("api/openai-plugin")]
    public class OpenAIPluginController : ControllerBase
    {
        private readonly AzureOpenAIPluginService _pluginService;
        private readonly ILogger<OpenAIPluginController> _logger;

        public OpenAIPluginController(
            AzureOpenAIPluginService pluginService,
            ILogger<OpenAIPluginController> logger)
        {
            _pluginService = pluginService;
            _logger = logger;
        }

        /// <summary>
        /// GET /info - Returns a description of what the plugin does
        /// </summary>
        /// <returns>Plugin information</returns>
        [HttpGet("info")]
        [ProducesResponseType(typeof(PluginInfo), 200)]
        public IActionResult GetInfo()
        {
            try
            {
                var info = _pluginService.GetPluginInfo();
                return Ok(info);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting plugin info");
                return StatusCode(500, new { error = "Internal server error", message = ex.Message });
            }
        }

        /// <summary>
        /// POST /prompt - Accepts a prompt and returns Azure OpenAI response
        /// </summary>
        /// <param name="request">Request containing the user prompt</param>
        /// <returns>AI-generated response</returns>
        [HttpPost("prompt")]
        [ProducesResponseType(typeof(PluginResponse), 200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(500)]
        public async Task<IActionResult> ProcessPrompt([FromBody] PromptRequest request)
        {
            // Error handling: Invalid or empty prompt
            if (request == null || string.IsNullOrWhiteSpace(request.Prompt))
            {
                _logger.LogWarning("Invalid or empty prompt received");
                return BadRequest(new 
                { 
                    error = "Invalid request",
                    message = "Prompt cannot be empty or null. Please provide a valid prompt in the request body."
                });
            }

            try
            {
                var response = await _pluginService.ProcessPromptAsync(request.Prompt);
                return Ok(response);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Invalid argument in prompt request");
                return BadRequest(new 
                { 
                    error = "Invalid request",
                    message = ex.Message 
                });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex, "Configuration or operation error");
                return StatusCode(500, new 
                { 
                    error = "Configuration error",
                    message = ex.Message 
                });
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "Azure OpenAI request failure");
                return StatusCode(502, new 
                { 
                    error = "Azure OpenAI request failed",
                    message = "Failed to communicate with Azure OpenAI service. Please check the configuration and try again."
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Internal server error processing prompt");
                return StatusCode(500, new 
                { 
                    error = "Internal server error",
                    message = "An unexpected error occurred while processing your request."
                });
            }
        }
    }

    /// <summary>
    /// Request model for prompt endpoint
    /// </summary>
    public class PromptRequest
    {
        public string Prompt { get; set; } = "";
    }
}

