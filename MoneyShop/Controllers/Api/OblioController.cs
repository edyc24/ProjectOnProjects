using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Oblio;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using OblioInvoiceRequest = MoneyShop.BusinessLogic.Implementation.Oblio.OblioInvoiceRequest;
using OblioProformaRequest = MoneyShop.BusinessLogic.Implementation.Oblio.OblioProformaRequest;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OblioController : ControllerBase
    {
        private readonly OblioApiService _oblioService;
        private readonly ILogger<OblioController> _logger;

        public OblioController(
            OblioApiService oblioService,
            ILogger<OblioController> logger)
        {
            _oblioService = oblioService;
            _logger = logger;
        }

        /// <summary>
        /// Obține lista de companii Oblio
        /// </summary>
        [HttpGet("companies")]
        public async Task<IActionResult> GetCompanies()
        {
            try
            {
                var companies = await _oblioService.GetCompaniesAsync();
                return Ok(companies);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la obținerea companiilor Oblio");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Obține cotele TVA pentru o firmă
        /// </summary>
        [HttpGet("vat-rates")]
        public async Task<IActionResult> GetVatRates([FromQuery] string cif)
        {
            if (string.IsNullOrEmpty(cif))
            {
                return BadRequest(new { message = "CIF-ul este obligatoriu" });
            }

            try
            {
                var vatRates = await _oblioService.GetVatRatesAsync(cif);
                return Ok(vatRates);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la obținerea cotelor TVA");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Obține lista de clienți
        /// </summary>
        [HttpGet("clients")]
        public async Task<IActionResult> GetClients(
            [FromQuery] string cif,
            [FromQuery] string? name = null,
            [FromQuery] string? clientCif = null,
            [FromQuery] int offset = 0)
        {
            if (string.IsNullOrEmpty(cif))
            {
                return BadRequest(new { message = "CIF-ul este obligatoriu" });
            }

            try
            {
                var clients = await _oblioService.GetClientsAsync(cif, name, clientCif, offset);
                return Ok(clients);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la obținerea clienților");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Obține lista de produse
        /// </summary>
        [HttpGet("products")]
        public async Task<IActionResult> GetProducts(
            [FromQuery] string cif,
            [FromQuery] string? name = null,
            [FromQuery] string? code = null,
            [FromQuery] string? management = null,
            [FromQuery] string? workStation = null,
            [FromQuery] int offset = 0)
        {
            if (string.IsNullOrEmpty(cif))
            {
                return BadRequest(new { message = "CIF-ul este obligatoriu" });
            }

            try
            {
                var products = await _oblioService.GetProductsAsync(cif, name, code, management, workStation, offset);
                return Ok(products);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la obținerea produselor");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Emite o factură
        /// </summary>
        [HttpPost("invoice")]
        public async Task<IActionResult> CreateInvoice(
            [FromQuery] string cif,
            [FromBody] OblioInvoiceRequest invoiceRequest)
        {
            if (string.IsNullOrEmpty(cif))
            {
                return BadRequest(new { message = "CIF-ul este obligatoriu" });
            }

            if (invoiceRequest == null)
            {
                return BadRequest(new { message = "Datele facturii sunt obligatorii" });
            }

            try
            {
                var result = await _oblioService.CreateInvoiceAsync(cif, invoiceRequest);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la emiterea facturii");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Emite o proformă
        /// </summary>
        [HttpPost("proforma")]
        public async Task<IActionResult> CreateProforma(
            [FromQuery] string cif,
            [FromBody] OblioProformaRequest proformaRequest)
        {
            if (string.IsNullOrEmpty(cif))
            {
                return BadRequest(new { message = "CIF-ul este obligatoriu" });
            }

            if (proformaRequest == null)
            {
                return BadRequest(new { message = "Datele proformei sunt obligatorii" });
            }

            try
            {
                var result = await _oblioService.CreateProformaAsync(cif, proformaRequest);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la emiterea proformei");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Descarcă un document (PDF)
        /// </summary>
        [HttpGet("document")]
        public async Task<IActionResult> GetDocument(
            [FromQuery] string cif,
            [FromQuery] string seriesName,
            [FromQuery] int number,
            [FromQuery] string type = "pdf")
        {
            if (string.IsNullOrEmpty(cif) || string.IsNullOrEmpty(seriesName))
            {
                return BadRequest(new { message = "CIF-ul și seria sunt obligatorii" });
            }

            try
            {
                var documentBytes = await _oblioService.GetDocumentAsync(cif, seriesName, number, type);
                return File(documentBytes, type == "pdf" ? "application/pdf" : "application/json", 
                    $"document_{seriesName}_{number}.{type}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la descărcarea documentului");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Anulează un document
        /// </summary>
        [HttpDelete("document")]
        public async Task<IActionResult> CancelDocument(
            [FromQuery] string cif,
            [FromQuery] string seriesName,
            [FromQuery] int number,
            [FromQuery] string type = "invoice")
        {
            if (string.IsNullOrEmpty(cif) || string.IsNullOrEmpty(seriesName))
            {
                return BadRequest(new { message = "CIF-ul și seria sunt obligatorii" });
            }

            try
            {
                var result = await _oblioService.CancelDocumentAsync(cif, seriesName, number, type);
                return Ok(new { success = result });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la anularea documentului");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Restaurează un document anulat
        /// </summary>
        [HttpPost("document/restore")]
        public async Task<IActionResult> RestoreDocument(
            [FromQuery] string cif,
            [FromQuery] string seriesName,
            [FromQuery] int number,
            [FromQuery] string type = "invoice")
        {
            if (string.IsNullOrEmpty(cif) || string.IsNullOrEmpty(seriesName))
            {
                return BadRequest(new { message = "CIF-ul și seria sunt obligatorii" });
            }

            try
            {
                var result = await _oblioService.RestoreDocumentAsync(cif, seriesName, number, type);
                return Ok(new { success = result });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la restaurarea documentului");
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Șterge un document
        /// </summary>
        [HttpDelete("document/delete")]
        public async Task<IActionResult> DeleteDocument(
            [FromQuery] string cif,
            [FromQuery] string seriesName,
            [FromQuery] int number,
            [FromQuery] string type = "invoice")
        {
            if (string.IsNullOrEmpty(cif) || string.IsNullOrEmpty(seriesName))
            {
                return BadRequest(new { message = "CIF-ul și seria sunt obligatorii" });
            }

            try
            {
                var result = await _oblioService.DeleteDocumentAsync(cif, seriesName, number, type);
                return Ok(new { success = result });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la ștergerea documentului");
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

