using Microsoft.AspNetCore.Mvc;

namespace ProjectOnProjects.Controllers
{
    public class CVController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
