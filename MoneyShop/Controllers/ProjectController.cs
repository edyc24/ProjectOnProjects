using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.ProjectService;
using MoneyShop.BusinessLogic.Implementation.ProjectService.Models;
using MoneyShop.Code.Base;
using MoneyShop.WebApp.Code.Base;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;

namespace MoneyShop.Controllers
{
    public class ProjectsController : BaseController
    {
        private readonly ProjectService _service;

        public ProjectsController(ControllerDependencies dependencies, ProjectService service)
            : base(dependencies)
        {
            _service = service;
        }

        public async Task<IActionResult> Index()
        {
            var projects = await _service.GetAllAsync();
            return View(projects);
        }

        [HttpGet]
        [Authorize]
        public IActionResult Create()
        {
            var model = new ProjectModel();
            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Create(ProjectModel model, IFormFile FisierProiect)
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
                    model.FisierProiect = ms.ToArray();
                }

            }

                 _service.CreateAsync(model);
                 return RedirectToAction("Index", "Home");

        }

        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var project = await _service.GetByIdAsync(id);
            if (project == null) return NotFound();

            return View(project);
        }

        [HttpPost]
        public async Task<IActionResult> Edit(ProjectModel model)
        {
            if (ModelState.IsValid)
            {
                await _service.UpdateAsync(model);
                return RedirectToAction("Index");
            }

            return View(model);
        }

        [HttpGet]
        public async Task<IActionResult> Delete(int id)
        {
            var project = await _service.GetByIdAsync(id);
            if (project == null) return NotFound();

            return View(project);
        }

        [HttpPost]
        [ActionName("Delete")]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            await _service.DeleteAsync(id);
            return RedirectToAction("Index");
        }

        public async Task<IActionResult> SavedProjects()
        {
            var savedProjects = await _service.GetAllAsync(); // Assuming GetAllAsync returns saved projects as well
            return View(savedProjects);
        }

        [HttpPost]
        public async Task<IActionResult> RemoveFromSaved(int id)
        {
            // Implement the logic to remove the project from saved projects
            return RedirectToAction("SavedProjects");
        }
    }
}