using Microsoft.AspNetCore.Mvc;

namespace MoneyShop.Controllers
{
    /// <summary>
    /// Web Controller for Azure OpenAI Plugin - Provides a web UI for testing the plugin
    /// This is separate from the API controller and provides a user-friendly interface
    /// </summary>
    public class OpenAIPluginWebController : Controller
    {
        private readonly ILogger<OpenAIPluginWebController> _logger;

        public OpenAIPluginWebController(ILogger<OpenAIPluginWebController> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Display the plugin test page
        /// </summary>
        [HttpGet]
        [Route("openai-plugin")]
        public IActionResult Index()
        {
            return View();
        }
    }
}

