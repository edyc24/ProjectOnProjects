using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Data;
using Microsoft.Extensions.Configuration;
// NOTĂ: Pentru Oracle, instalează: Install-Package Oracle.ManagedDataAccess.Core
// Apoi folosește: using Oracle.ManagedDataAccess.Client;
// Pentru moment, folosim un serviciu helper care execută SQL direct

namespace MoneyShop.Controllers
{
    [Authorize]
    public class ETLController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ETLController> _logger;

        public ETLController(IConfiguration configuration, ILogger<ETLController> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        // GET: ETL
        public IActionResult Index()
        {
            return View();
        }

        // GET: ETL/Status
        public IActionResult Status()
        {
            try
            {
                var status = GetETLStatus();
                return View(status);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting ETL status");
                ViewBag.Error = "Eroare la obținerea statusului ETL: " + ex.Message;
                return View();
            }
        }

        // POST: ETL/Trigger
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Trigger()
        {
            try
            {
                var result = ExecuteETL();
                TempData["ETLResult"] = result;
                return RedirectToAction(nameof(Status));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error triggering ETL");
                TempData["ETLError"] = "Eroare la rularea ETL: " + ex.Message;
                return RedirectToAction(nameof(Status));
            }
        }

        // GET: ETL/Validate
        public IActionResult Validate()
        {
            try
            {
                var validation = ValidateETL();
                return View(validation);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating ETL");
                ViewBag.Error = "Eroare la validarea ETL: " + ex.Message;
                return View();
            }
        }

        // API: ETL/Trigger (AJAX)
        [HttpPost]
        [Route("api/etl/trigger")]
        public IActionResult TriggerETL()
        {
            try
            {
                var result = ExecuteETL();
                return Json(new { success = true, message = result });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error triggering ETL via API");
                return Json(new { success = false, message = ex.Message });
            }
        }

        // API: ETL/Status (AJAX)
        [HttpGet]
        [Route("api/etl/status")]
        public IActionResult GetStatus()
        {
            try
            {
                var status = GetETLStatus();
                return Json(new { success = true, data = status });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting ETL status via API");
                return Json(new { success = false, message = ex.Message });
            }
        }

        // API: ETL/Validate (AJAX)
        [HttpGet]
        [Route("api/etl/validate")]
        public IActionResult ValidateETLAPI()
        {
            try
            {
                var validation = ValidateETL();
                return Json(new { success = true, data = validation });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating ETL via API");
                return Json(new { success = false, message = ex.Message });
            }
        }

        // Helper methods
        private string ExecuteETL()
        {
            // NOTĂ: Această metodă necesită Oracle.ManagedDataAccess.Core
            // Instalează: dotnet add package Oracle.ManagedDataAccess.Core
            // Apoi decomentează codul de mai jos și adaptează connection string
            
            var connectionString = _configuration.GetConnectionString("DWConnection");
            
            if (string.IsNullOrEmpty(connectionString))
            {
                // Fallback: folosește connection string Oracle dacă e configurat
                connectionString = _configuration.GetConnectionString("OracleConnection");
            }
            
            if (string.IsNullOrEmpty(connectionString))
            {
                throw new Exception("Connection string pentru DW (Oracle) nu este configurat. " +
                    "Adaugă 'DWConnection' sau 'OracleConnection' în appsettings.json");
            }

            // TEMPORAR: Returnează mesaj de configurare
            // TODO: Decomentează când instalezi Oracle.ManagedDataAccess.Core
            /*
            using var connection = new Oracle.ManagedDataAccess.Client.OracleConnection(connectionString);
            connection.Open();

            using var command = new Oracle.ManagedDataAccess.Client.OracleCommand("BEGIN SP_ETL_FULL_LOAD; END;", connection);
            command.CommandType = CommandType.Text;
            command.ExecuteNonQuery();
            */

            // Simulare pentru demo
            _logger.LogInformation("ETL ar fi rulat cu succes (simulare)");
            return "ETL rulat cu succes! (Notă: Instalează Oracle.ManagedDataAccess.Core pentru funcționalitate completă)";
        }

        private ETLStatusViewModel GetETLStatus()
        {
            // NOTĂ: Această metodă necesită Oracle.ManagedDataAccess.Core
            var connectionString = _configuration.GetConnectionString("DWConnection") 
                ?? _configuration.GetConnectionString("OracleConnection");
            
            if (string.IsNullOrEmpty(connectionString))
            {
                // Returnează status mock pentru demo
                return new ETLStatusViewModel
                {
                    FactTableCount = 0,
                    DimUtilizatorCount = 0,
                    DimBancaCount = 0,
                    DimBrokerCount = 0,
                    LastUpdate = DateTime.Now
                };
            }

            var status = new ETLStatusViewModel();

            // TODO: Decomentează când instalezi Oracle.ManagedDataAccess.Core
            /*
            using var connection = new Oracle.ManagedDataAccess.Client.OracleConnection(connectionString);
            connection.Open();

            using var cmdFact = new Oracle.ManagedDataAccess.Client.OracleCommand("SELECT COUNT(*) FROM FACT_APLICATII_CREDIT", connection);
            status.FactTableCount = Convert.ToInt32(cmdFact.ExecuteScalar());

            using var cmdUsers = new Oracle.ManagedDataAccess.Client.OracleCommand("SELECT COUNT(*) FROM DIM_UTILIZATOR", connection);
            status.DimUtilizatorCount = Convert.ToInt32(cmdUsers.ExecuteScalar());

            using var cmdBanks = new Oracle.ManagedDataAccess.Client.OracleCommand("SELECT COUNT(*) FROM DIM_BANCA", connection);
            status.DimBancaCount = Convert.ToInt32(cmdBanks.ExecuteScalar());

            using var cmdBrokers = new Oracle.ManagedDataAccess.Client.OracleCommand("SELECT COUNT(*) FROM DIM_BROKER", connection);
            status.DimBrokerCount = Convert.ToInt32(cmdBrokers.ExecuteScalar());
            */

            // Simulare pentru demo
            status.FactTableCount = 0;
            status.DimUtilizatorCount = 0;
            status.DimBancaCount = 0;
            status.DimBrokerCount = 0;
            status.LastUpdate = DateTime.Now;

            return status;
        }

        private ETLValidationViewModel ValidateETL()
        {
            // NOTĂ: Această metodă necesită Oracle.ManagedDataAccess.Core
            var connectionString = _configuration.GetConnectionString("DWConnection") 
                ?? _configuration.GetConnectionString("OracleConnection");
            
            if (string.IsNullOrEmpty(connectionString))
            {
                // Returnează validare mock pentru demo
                return new ETLValidationViewModel
                {
                    IsValid = true,
                    OrphanRecords = 0,
                    OLTPCount = 0,
                    DWCount = 0,
                    Difference = 0
                };
            }

            var validation = new ETLValidationViewModel();

            // TODO: Decomentează când instalezi Oracle.ManagedDataAccess.Core
            /*
            using var connection = new Oracle.ManagedDataAccess.Client.OracleConnection(connectionString);
            connection.Open();

            using var cmdFK = new Oracle.ManagedDataAccess.Client.OracleCommand(@"
                SELECT COUNT(*) 
                FROM FACT_APLICATII_CREDIT f
                WHERE NOT EXISTS (SELECT 1 FROM DIM_UTILIZATOR d WHERE d.IdUtilizator = f.IdUtilizator)
                   OR NOT EXISTS (SELECT 1 FROM DIM_BANCA d WHERE d.IdBanca = f.IdBanca)
                   OR NOT EXISTS (SELECT 1 FROM DIM_TIMP d WHERE d.IdTimp = f.IdTimp)
                   OR NOT EXISTS (SELECT 1 FROM DIM_TIP_CREDIT d WHERE d.IdTipCredit = f.IdTipCredit)
                   OR NOT EXISTS (SELECT 1 FROM DIM_STATUS d WHERE d.IdStatus = f.IdStatus)
            ", connection);
            validation.OrphanRecords = Convert.ToInt32(cmdFK.ExecuteScalar());
            validation.IsValid = validation.OrphanRecords == 0;

            using var cmdOLTP = new Oracle.ManagedDataAccess.Client.OracleCommand("SELECT COUNT(*) FROM MONEYSHOP.APLICATII WHERE IsDeleted = 0 OR IsDeleted IS NULL", connection);
            var oltpCount = Convert.ToInt32(cmdOLTP.ExecuteScalar());

            using var cmdDW = new Oracle.ManagedDataAccess.Client.OracleCommand("SELECT COUNT(*) FROM FACT_APLICATII_CREDIT", connection);
            var dwCount = Convert.ToInt32(cmdDW.ExecuteScalar());

            validation.OLTPCount = oltpCount;
            validation.DWCount = dwCount;
            validation.Difference = Math.Abs(oltpCount - dwCount);
            */

            // Simulare pentru demo
            validation.IsValid = true;
            validation.OrphanRecords = 0;
            validation.OLTPCount = 0;
            validation.DWCount = 0;
            validation.Difference = 0;

            return validation;
        }
    }

    // View Models
    public class ETLStatusViewModel
    {
        public int FactTableCount { get; set; }
        public int DimUtilizatorCount { get; set; }
        public int DimBancaCount { get; set; }
        public int DimBrokerCount { get; set; }
        public DateTime LastUpdate { get; set; }
    }

    public class ETLValidationViewModel
    {
        public bool IsValid { get; set; }
        public int OrphanRecords { get; set; }
        public int OLTPCount { get; set; }
        public int DWCount { get; set; }
        public int Difference { get; set; }
    }
}

