using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MoneyShop.BusinessLogic.Implementation.Lead;
using MoneyShop.Entities.Entities;
using MoneyShop.DataAccess;

namespace MoneyShop.Controllers
{
    public class HomeController : Controller
    {
        private readonly LeadService _leadService;
        private readonly UnitOfWork _unitOfWork;

        public HomeController(LeadService leadService, UnitOfWork unitOfWork)
        {
            _leadService = leadService;
            _unitOfWork = unitOfWork;
        }

        public IActionResult Index()
        {
            return View();
        }

        // Homework 2 - Simple page with input + button + list
        // Public access - no authentication required
        [AllowAnonymous]
        public IActionResult Simple()
        {
            // Get all leads as items for the list (public access)
            var items = _unitOfWork.Leads.Get()
                .OrderByDescending(l => l.CreatedAt)
                .Select(l => new SimpleItemViewModel
                {
                    Id = l.Id,
                    Text = l.Name ?? "Unknown",
                    CreatedAt = l.CreatedAt
                })
                .ToList();

            return View(items);
        }

        // API endpoint for adding item (used by AJAX)
        // Public access - no authentication required
        [HttpPost]
        [Route("api/simple/add")]
        [AllowAnonymous]
        public IActionResult AddItem([FromBody] AddItemRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Text))
            {
                return BadRequest(new { message = "Text cannot be empty" });
            }

            try
            {
                // Create a lead as the item
                var lead = new Lead
                {
                    Name = request.Text.Trim(),
                    Email = $"item{DateTime.UtcNow.Ticks}@example.com", // Dummy email for simple items
                    CreatedAt = DateTime.UtcNow,
                    GdprConsent = true,
                    IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString()
                };

                var created = _leadService.CreateLead(lead);

                return Ok(new SimpleItemViewModel
                {
                    Id = created.Id,
                    Text = created.Name,
                    CreatedAt = created.CreatedAt
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }

    public class SimpleItemViewModel
    {
        public int Id { get; set; }
        public string Text { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

    public class AddItemRequest
    {
        public string Text { get; set; } = string.Empty;
    }
}
