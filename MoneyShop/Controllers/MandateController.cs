using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace MoneyShop.WebApp.Controllers
{
    [Authorize]
    public class MandateController : Controller
    {
        // Store mandate data in session (for demo purposes)
        private const string MandateSessionKey = "MandateData";
        private const string ConsentLogSessionKey = "ConsentLog";

        /// <summary>
        /// Main mandate management page
        /// </summary>
        [HttpGet]
        public IActionResult Index()
        {
            // Get user ID from claims
            var userIdClaim = User.FindFirstValue("Id");
            ViewBag.UserId = int.TryParse(userIdClaim, out int userId) ? userId : 1;
            return View();
        }

        [HttpGet]
        public IActionResult Step1()
        {
            ViewData["Title"] = "Mandat ANAF & Biroul de Credit";
            return View();
        }

        [HttpPost]
        public IActionResult Step1(bool acceptMandate)
        {
            if (!acceptMandate)
            {
                ModelState.AddModelError("", "Trebuie să accepți mandatul pentru a continua.");
                return View();
            }

            // Log consent
            LogConsent("Nivel 1 - Mandat ANAF/BC", acceptMandate);

            // Store in session
            var mandateData = new Dictionary<string, object>
            {
                { "Step1Accepted", true },
                { "Step1Date", DateTime.UtcNow.ToString("O") }
            };
            HttpContext.Session.SetString(MandateSessionKey, System.Text.Json.JsonSerializer.Serialize(mandateData));

            return RedirectToAction("Step2");
        }

        [HttpGet]
        public IActionResult Step2()
        {
            var mandateData = GetMandateData();
            if (mandateData == null || !mandateData.ContainsKey("Step1Accepted"))
            {
                return RedirectToAction("Step1");
            }

            ViewData["Title"] = "Informare Costuri";
            return View();
        }

        [HttpPost]
        public IActionResult Step2(bool acceptCosts)
        {
            if (!acceptCosts)
            {
                ModelState.AddModelError("", "Trebuie să accepți costurile pentru a continua.");
                return View();
            }

            LogConsent("Nivel 1 - Acceptare Costuri", acceptCosts);

            var mandateData = GetMandateData() ?? new Dictionary<string, object>();
            mandateData["Step2Accepted"] = true;
            mandateData["Step2Date"] = DateTime.UtcNow.ToString("O");
            HttpContext.Session.SetString(MandateSessionKey, System.Text.Json.JsonSerializer.Serialize(mandateData));

            return RedirectToAction("Step3");
        }

        [HttpGet]
        public IActionResult Step3()
        {
            var mandateData = GetMandateData();
            if (mandateData == null || !mandateData.ContainsKey("Step2Accepted"))
            {
                return RedirectToAction("Step1");
            }

            ViewData["Title"] = "Alegerea Brokerului";
            
            // Mock brokers list (in real app, this would come from database)
            ViewBag.Brokers = new[]
            {
                new { Id = 1, Name = "Broker Credit Expert SRL", Email = "contact@credit-expert.ro", Verified = true },
                new { Id = 2, Name = "Finanțare Rapidă PFA", Email = "info@finantare-rapida.ro", Verified = true },
                new { Id = 3, Name = "Credit Solutions SRL", Email = "office@credit-solutions.ro", Verified = true }
            };

            return View();
        }

        [HttpPost]
        public IActionResult Step3(int? brokerId)
        {
            var mandateData = GetMandateData() ?? new Dictionary<string, object>();
            if (brokerId.HasValue)
            {
                mandateData["SelectedBrokerId"] = brokerId.Value;
            }
            mandateData["Step3Date"] = DateTime.UtcNow.ToString("O");
            HttpContext.Session.SetString(MandateSessionKey, System.Text.Json.JsonSerializer.Serialize(mandateData));

            if (brokerId.HasValue)
            {
                return RedirectToAction("Step4");
            }
            else
            {
                // Skip broker selection, go to final step
                return RedirectToAction("Step5");
            }
        }

        [HttpGet]
        public IActionResult Step4()
        {
            var mandateData = GetMandateData();
            if (mandateData == null || !mandateData.ContainsKey("Step3Date"))
            {
                return RedirectToAction("Step1");
            }

            ViewData["Title"] = "Transmitere Date către Broker";
            return View();
        }

        [HttpPost]
        public IActionResult Step4(bool acceptTransfer)
        {
            var mandateData = GetMandateData() ?? new Dictionary<string, object>();
            
            if (acceptTransfer)
            {
                LogConsent("Nivel 2 - Transmitere Date Broker", acceptTransfer);
                mandateData["Step4Accepted"] = true;
                mandateData["Step4Date"] = DateTime.UtcNow.ToString("O");
            }
            else
            {
                mandateData["Step4Accepted"] = false;
            }

            HttpContext.Session.SetString(MandateSessionKey, System.Text.Json.JsonSerializer.Serialize(mandateData));

            return RedirectToAction("Step5");
        }

        [HttpGet]
        public IActionResult Step5()
        {
            var mandateData = GetMandateData();
            if (mandateData == null)
            {
                return RedirectToAction("Step1");
            }

            ViewData["Title"] = "Confirmare Finală";
            
            // Calculate expiry date (30 days from Step1)
            if (mandateData.ContainsKey("Step1Date") && DateTime.TryParse(mandateData["Step1Date"].ToString(), out DateTime step1Date))
            {
                ViewBag.ExpiryDate = step1Date.AddDays(30);
            }

            return View();
        }

        //[HttpPost]
        //public IActionResult Step5()
        //{
        //    var mandateData = GetMandateData();
        //    if (mandateData == null)
        //    {
        //        return RedirectToAction("Step1");
        //    }

        //    // Finalize mandate
        //    mandateData["Finalized"] = true;
        //    mandateData["FinalizedDate"] = DateTime.UtcNow.ToString("O");
        //    if (mandateData.ContainsKey("Step1Date") && DateTime.TryParse(mandateData["Step1Date"].ToString(), out DateTime step1Date))
        //    {
        //        mandateData["ExpiryDate"] = step1Date.AddDays(30).ToString("O");
        //    }
            
        //    HttpContext.Session.SetString(MandateSessionKey, System.Text.Json.JsonSerializer.Serialize(mandateData));

        //    // Save consent log to session (in real app, save to database)
        //    var consentLog = GetConsentLog();
        //    consentLog.Add(new
        //    {
        //        Event = "Mandat Finalizat",
        //        Timestamp = DateTime.UtcNow,
        //        IP = HttpContext.Connection.RemoteIpAddress?.ToString(),
        //        UserAgent = HttpContext.Request.Headers["User-Agent"].ToString(),
        //        UserId = User.FindFirstValue(ClaimTypes.NameIdentifier)
        //    });
        //    HttpContext.Session.SetString(ConsentLogSessionKey, System.Text.Json.JsonSerializer.Serialize(consentLog));

        //    TempData["Success"] = "Mandatul a fost acordat cu succes! Valabil până la " + ((DateTime)mandateData["ExpiryDate"]).ToString("dd.MM.yyyy");
        //    return RedirectToAction("Index", "Home");
        //}

        [HttpGet]
        public IActionResult ViewLog()
        {
            var consentLog = GetConsentLog();
            ViewBag.ConsentLog = consentLog;
            return View();
        }

        private Dictionary<string, object>? GetMandateData()
        {
            var data = HttpContext.Session.GetString(MandateSessionKey);
            if (string.IsNullOrEmpty(data))
                return null;

            return System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(data);
        }

        private List<object> GetConsentLog()
        {
            var data = HttpContext.Session.GetString(ConsentLogSessionKey);
            if (string.IsNullOrEmpty(data))
                return new List<object>();

            return System.Text.Json.JsonSerializer.Deserialize<List<object>>(data) ?? new List<object>();
        }

        private void LogConsent(string eventType, bool accepted)
        {
            var consentLog = GetConsentLog();
            consentLog.Add(new
            {
                Event = eventType,
                Accepted = accepted,
                Timestamp = DateTime.UtcNow,
                IP = HttpContext.Connection.RemoteIpAddress?.ToString(),
                UserAgent = HttpContext.Request.Headers["User-Agent"].ToString(),
                UserId = User.FindFirstValue(ClaimTypes.NameIdentifier),
                SessionId = HttpContext.Session.Id
            });

            HttpContext.Session.SetString(ConsentLogSessionKey, System.Text.Json.JsonSerializer.Serialize(consentLog));
        }
    }
}
