using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OCRController : ControllerBase
    {
        /// <summary>
        /// Process ID card image and extract data
        /// </summary>
        [HttpPost("process-id")]
        public async Task<IActionResult> ProcessIdCard([FromForm] IFormFile image)
        {
            if (image == null || image.Length == 0)
                return BadRequest(new { message = "No image uploaded" });

            // TODO: Implement OCR using Azure Computer Vision or Tesseract
            // For now, return mock data
            var mockData = new
            {
                nume = "Ion",
                prenume = "Popescu",
                cnp = "1234567890123",
                serie = "AB",
                numar = "123456",
                adresa = "Str. Exemplu, Nr. 1, București"
            };

            return Ok(mockData);
        }
    }
}

