using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.ProjectService;
using MoneyShop.BusinessLogic.Implementation.BacDocumentService;
using MoneyShop.BusinessLogic.Implementation.ProjectService.Models;
using System.Threading.Tasks;

namespace MoneyShop.Controllers
{
    public class HomeController : Controller
    {
        private readonly ProjectService _projectService;
        private readonly BacDocumentService _bacDocumentService;

        public HomeController(ProjectService projectService, BacDocumentService bacDocumentService)
        {
            _projectService = projectService;
            _bacDocumentService = bacDocumentService;
        }

        public async Task<IActionResult> Index()
        {
            var projects = await _projectService.GetAllAsync();
            ViewData["CurrentTime"] = DateTime.Now.ToString("HH:mm:ss");
            ViewData["CurrentDate"] = DateTime.Now.ToString("yyyy-MM-dd");

            return View(projects);
        }

        public IActionResult CVForm()
        {
            return View();
        }

        public IActionResult AddProject()
        {
            return View();
        }

        public async Task<IActionResult> SavedProjects()
        {
            var savedProjects = await _projectService.GetAllAsync(); // Assuming GetAllAsync returns saved projects as well
            return View(savedProjects);
        }

        public IActionResult BacDocuments()
        {
            var documents = _bacDocumentService.GetAllDocuments();
            return View(documents);
        }
    }
}