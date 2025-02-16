using Microsoft.AspNetCore.Mvc;
using ProjectOnProjects.BusinessLogic.Implementation.ProjectService;
using ProjectOnProjects.BusinessLogic.Implementation.ProjectService.Models;
using ProjectOnProjects.Code.Base;
using ProjectOnProjects.WebApp.Code.Base;
using System.Threading.Tasks;

namespace ProjectOnProjects.Controllers
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
        public IActionResult Create()
        {
            var model = new ProjectModel();
            return View(model);
        }

        [HttpPost]
        public IActionResult Create(ProjectModel model)
        {
            if (ModelState.IsValid)
            {
                 _service.CreateAsync(model);
                return RedirectToAction("Index");
            }

            return RedirectToAction("Index","Home");
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