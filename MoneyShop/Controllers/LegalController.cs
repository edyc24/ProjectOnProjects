using Microsoft.AspNetCore.Mvc;

namespace MoneyShop.WebApp.Controllers
{
    public class LegalController : Controller
    {
        public IActionResult Terms()
        {
            ViewData["Title"] = "Termeni și Condiții";
            return View();
        }

        public IActionResult Privacy()
        {
            ViewData["Title"] = "Politica de Confidențialitate";
            return View();
        }

        public IActionResult Mandate()
        {
            ViewData["Title"] = "Politica de Mandatare";
            return View();
        }

        public IActionResult DataTransfer()
        {
            ViewData["Title"] = "Politica de Transmitere Date";
            return View();
        }

        public IActionResult Compliance()
        {
            ViewData["Title"] = "Pachet de Conformitate";
            return View();
        }
    }
}

