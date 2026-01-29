using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Data;
using Microsoft.Extensions.Configuration;
using System.Text.Json;
// NOTĂ: Pentru Oracle, instalează: Install-Package Oracle.ManagedDataAccess.Core
// Apoi folosește: using Oracle.ManagedDataAccess.Client;

namespace MoneyShop.Controllers
{
    [Authorize]
    public class ReportsController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ReportsController> _logger;

        public ReportsController(IConfiguration configuration, ILogger<ReportsController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        // GET: Reports
        public IActionResult Index()
        {
            return View();
        }

        // GET: Reports/EvolutieAplicatii
        public IActionResult EvolutieAplicatii()
        {
            return View();
        }

        // GET: Reports/DistributieStatus
        public IActionResult DistributieStatus()
        {
            return View();
        }

        // GET: Reports/TopBanci
        public IActionResult TopBanci()
        {
            return View();
        }

        // GET: Reports/ComparatieTipuriCredit
        public IActionResult ComparatieTipuriCredit()
        {
            return View();
        }

        // GET: Reports/PerformantaBrokeri
        public IActionResult PerformantaBrokeri()
        {
            return View();
        }

        // GET: Reports/ScoringCategorii
        public IActionResult ScoringCategorii()
        {
            return View();
        }

        // GET: Reports/RataAprobareBanca
        public IActionResult RataAprobareBanca()
        {
            return View();
        }

        // API Endpoints pentru rapoarte

        [HttpGet]
        [Route("api/reports/evolutie-aplicatii")]
        public IActionResult GetEvolutieAplicatii()
        {
            try
            {
                var data = GetReportData("VW_REPORT_EVOLUTIE_APLICATII");
                return Json(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting EvolutieAplicatii report");
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpGet]
        [Route("api/reports/distributie-status")]
        public IActionResult GetDistributieStatus()
        {
            try
            {
                var data = GetReportData("VW_REPORT_DISTRIBUTIE_STATUS");
                return Json(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting DistributieStatus report");
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpGet]
        [Route("api/reports/top-banci")]
        public IActionResult GetTopBanci()
        {
            try
            {
                var data = GetReportData("VW_REPORT_TOP_BANCI");
                return Json(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting TopBanci report");
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpGet]
        [Route("api/reports/comparatie-tipuri-credit")]
        public IActionResult GetComparatieTipuriCredit()
        {
            try
            {
                var data = GetReportData("VW_REPORT_COMPARATIE_TIPURI_CREDIT");
                return Json(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting ComparatieTipuriCredit report");
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpGet]
        [Route("api/reports/performanta-brokeri")]
        public IActionResult GetPerformantaBrokeri()
        {
            try
            {
                var data = GetReportData("VW_REPORT_PERFORMANTA_BROKERI");
                return Json(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting PerformantaBrokeri report");
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpGet]
        [Route("api/reports/scoring-categorii")]
        public IActionResult GetScoringCategorii()
        {
            try
            {
                var data = GetReportData("VW_REPORT_SCORING_CATEGORII");
                return Json(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting ScoringCategorii report");
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpGet]
        [Route("api/reports/rata-aprobare-banca")]
        public IActionResult GetRataAprobareBanca()
        {
            try
            {
                var data = GetReportData("VW_REPORT_RATA_APROBARE_BANCA");
                return Json(new { success = true, data = data });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting RataAprobareBanca report");
                return Json(new { success = false, message = ex.Message });
            }
        }

        // Helper method
        private List<Dictionary<string, object>> GetReportData(string viewName)
        {
            // NOTĂ: Această metodă necesită Oracle.ManagedDataAccess.Core
            var connectionString = _configuration.GetConnectionString("DWConnection") 
                ?? _configuration.GetConnectionString("OracleConnection");
            
            if (string.IsNullOrEmpty(connectionString))
            {
                // Returnează date mock pentru demo
                _logger.LogWarning("Connection string pentru DW nu este configurat. Returnez date mock.");
                return new List<Dictionary<string, object>>();
            }

            var results = new List<Dictionary<string, object>>();

            // TODO: Decomentează când instalezi Oracle.ManagedDataAccess.Core
            /*
            using var connection = new Oracle.ManagedDataAccess.Client.OracleConnection(connectionString);
            connection.Open();

            using var command = new Oracle.ManagedDataAccess.Client.OracleCommand($"SELECT * FROM {viewName}", connection);
            using var reader = command.ExecuteReader();

            while (reader.Read())
            {
                var row = new Dictionary<string, object>();
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                }
                results.Add(row);
            }
            */

            // Simulare pentru demo - returnează listă goală
            return results;
        }
    }
}

