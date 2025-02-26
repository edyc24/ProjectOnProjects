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
        public IActionResult AddDocument(BacDocumentModel model)
        {
            if (ModelState.IsValid)
            {
                _bacService.AddBacDocument(model);
                return RedirectToAction("Index");
            }
            return View(model);
        }
    }
} 