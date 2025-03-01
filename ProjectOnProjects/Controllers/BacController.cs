using Microsoft.AspNetCore.Mvc;
using ProjectOnProjects.BusinessLogic.Implementation.Bac;
using ProjectOnProjects.Models;

namespace ProjectOnProjects.WebApp.Controllers
{
    public class BacController : Controller
    {
        private readonly BacService _bacService;

        public BacController(BacService bacService)
        {
            _bacService = bacService;
        }

        [HttpGet]
        public IActionResult Index()
        {
            var model = _bacService.GetBacDocuments();
            return View(model);
        }

        [HttpGet]
        public IActionResult AddDocument()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> AddDocument(BacDocumentModel model, IFormFile FisierProiect)
        {
            if (FisierProiect != null && FisierProiect.Length > 0)
            {
                // Validate file type
                if (FisierProiect.ContentType != "application/pdf")
                {
                    ModelState.AddModelError("Imagine", "Only PDF files are allowed.");
                    return View(model);
                }

                // Limit file size (e.g., max 10 MB)
                if (FisierProiect.Length > 10 * 1024 * 1024)
                {
                    ModelState.AddModelError("Imagine", "File size must be less than 10 MB.");
                    return View(model);
                }

                // Read the PDF file into a byte array
                using (var ms = new MemoryStream())
                {
                    await FisierProiect.CopyToAsync(ms);
                    model.Content = ms.ToArray();
                }

            }

            _bacService.AddBacDocument(model);
            return RedirectToAction("Index", "Home");
        }
    }
} 