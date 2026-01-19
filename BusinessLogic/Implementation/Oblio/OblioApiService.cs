using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace MoneyShop.BusinessLogic.Implementation.Oblio
{
    public class OblioApiService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<OblioApiService> _logger;
        private string? _accessToken;
        private DateTime? _tokenExpiresAt;

        private const string BaseUrl = "https://www.oblio.eu/api";
        private const string TokenEndpoint = "/authorize/token";

        public OblioApiService(
            HttpClient httpClient,
            IConfiguration configuration,
            ILogger<OblioApiService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
            _httpClient.BaseAddress = new Uri(BaseUrl);
        }

        /// <summary>
        /// Obține token de acces OAuth 2.0
        /// </summary>
        public async Task<string> GetAccessTokenAsync()
        {
            // Verifică dacă token-ul există și este valid
            if (_accessToken != null && _tokenExpiresAt.HasValue && DateTime.UtcNow < _tokenExpiresAt.Value.AddMinutes(-5))
            {
                return _accessToken;
            }

            var clientId = _configuration["Oblio:ClientId"];
            var clientSecret = _configuration["Oblio:ClientSecret"];

            if (string.IsNullOrEmpty(clientId) || string.IsNullOrEmpty(clientSecret))
            {
                throw new InvalidOperationException("Oblio ClientId și ClientSecret trebuie configurate în appsettings.json");
            }

            try
            {
                var requestContent = new FormUrlEncodedContent(new[]
                {
                    new KeyValuePair<string, string>("client_id", clientId),
                    new KeyValuePair<string, string>("client_secret", clientSecret)
                });

                var response = await _httpClient.PostAsync(TokenEndpoint, requestContent);
                response.EnsureSuccessStatusCode();

                var responseContent = await response.Content.ReadAsStringAsync();
                var tokenResponse = JsonSerializer.Deserialize<OblioTokenResponse>(responseContent, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

                if (tokenResponse?.AccessToken == null)
                {
                    throw new Exception("Nu s-a putut obține token-ul de acces de la Oblio");
                }

                _accessToken = tokenResponse.AccessToken;
                var expiresIn = int.TryParse(tokenResponse.ExpiresIn, out var seconds) ? seconds : 3600;
                _tokenExpiresAt = DateTime.UtcNow.AddSeconds(expiresIn);

                _logger.LogInformation("Token Oblio obținut cu succes. Expiră la: {ExpiresAt}", _tokenExpiresAt);

                return _accessToken;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Eroare la obținerea token-ului Oblio");
                throw;
            }
        }

        /// <summary>
        /// Obține lista de companii asociate cu contul
        /// </summary>
        public async Task<List<OblioCompany>> GetCompaniesAsync()
        {
            var token = await GetAccessTokenAsync();
            var response = await GetAsync<OblioResponse<List<OblioCompany>>>("/nomenclature/companies", token);
            return response?.Data ?? new List<OblioCompany>();
        }

        /// <summary>
        /// Obține lista de cote TVA pentru o firmă
        /// </summary>
        public async Task<List<OblioVatRate>> GetVatRatesAsync(string cif)
        {
            var token = await GetAccessTokenAsync();
            var response = await GetAsync<OblioResponse<List<OblioVatRate>>>($"/nomenclature/vat_rates?cif={cif}", token);
            return response?.Data ?? new List<OblioVatRate>();
        }

        /// <summary>
        /// Obține lista de clienți pentru o firmă
        /// </summary>
        public async Task<List<OblioClient>> GetClientsAsync(string cif, string? name = null, string? clientCif = null, int offset = 0)
        {
            var token = await GetAccessTokenAsync();
            var queryParams = $"cif={cif}&offset={offset}";
            if (!string.IsNullOrEmpty(name)) queryParams += $"&name={Uri.EscapeDataString(name)}";
            if (!string.IsNullOrEmpty(clientCif)) queryParams += $"&clientCif={clientCif}";

            var response = await GetAsync<OblioResponse<List<OblioClient>>>($"/nomenclature/clients?{queryParams}", token);
            return response?.Data ?? new List<OblioClient>();
        }

        /// <summary>
        /// Obține lista de produse pentru o firmă
        /// </summary>
        public async Task<List<OblioProduct>> GetProductsAsync(string cif, string? name = null, string? code = null, string? management = null, string? workStation = null, int offset = 0)
        {
            var token = await GetAccessTokenAsync();
            var queryParams = $"cif={cif}&offset={offset}";
            if (!string.IsNullOrEmpty(name)) queryParams += $"&name={Uri.EscapeDataString(name)}";
            if (!string.IsNullOrEmpty(code)) queryParams += $"&code={Uri.EscapeDataString(code)}";
            if (!string.IsNullOrEmpty(management)) queryParams += $"&management={Uri.EscapeDataString(management)}";
            if (!string.IsNullOrEmpty(workStation)) queryParams += $"&workStation={Uri.EscapeDataString(workStation)}";

            var response = await GetAsync<OblioResponse<List<OblioProduct>>>($"/nomenclature/products?{queryParams}", token);
            return response?.Data ?? new List<OblioProduct>();
        }

        /// <summary>
        /// Emite o factură
        /// </summary>
        public async Task<OblioDocumentResponse> CreateInvoiceAsync(string cif, OblioInvoiceRequest invoiceRequest)
        {
            var token = await GetAccessTokenAsync();
            var response = await PostAsync<OblioDocumentResponse>($"/docs/invoice?cif={cif}", invoiceRequest, token);
            return response ?? throw new Exception("Nu s-a putut emite factura");
        }

        /// <summary>
        /// Emite o proformă
        /// </summary>
        public async Task<OblioDocumentResponse> CreateProformaAsync(string cif, OblioProformaRequest proformaRequest)
        {
            var token = await GetAccessTokenAsync();
            var response = await PostAsync<OblioDocumentResponse>($"/docs/proforma?cif={cif}", proformaRequest, token);
            return response ?? throw new Exception("Nu s-a putut emite proforma");
        }

        /// <summary>
        /// Vizualizează un document
        /// </summary>
        public async Task<byte[]> GetDocumentAsync(string cif, string seriesName, int number, string type = "pdf")
        {
            var token = await GetAccessTokenAsync();
            var url = $"/docs/{type}?cif={cif}&seriesName={seriesName}&number={number}";
            
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            var response = await _httpClient.GetAsync(url);
            response.EnsureSuccessStatusCode();

            return await response.Content.ReadAsByteArrayAsync();
        }

        /// <summary>
        /// Anulează un document
        /// </summary>
        public async Task<bool> CancelDocumentAsync(string cif, string seriesName, int number, string type = "invoice")
        {
            var token = await GetAccessTokenAsync();
            var url = $"/docs/{type}/cancel?cif={cif}&seriesName={seriesName}&number={number}";
            var response = await DeleteAsync<OblioResponse<object>>(url, token);
            return response != null;
        }

        /// <summary>
        /// Restaurează un document anulat
        /// </summary>
        public async Task<bool> RestoreDocumentAsync(string cif, string seriesName, int number, string type = "invoice")
        {
            var token = await GetAccessTokenAsync();
            var url = $"/docs/{type}/restore?cif={cif}&seriesName={seriesName}&number={number}";
            var response = await PostAsync<OblioResponse<object>>(url, null, token);
            return response != null;
        }

        /// <summary>
        /// Șterge un document
        /// </summary>
        public async Task<bool> DeleteDocumentAsync(string cif, string seriesName, int number, string type = "invoice")
        {
            var token = await GetAccessTokenAsync();
            var url = $"/docs/{type}/delete?cif={cif}&seriesName={seriesName}&number={number}";
            var response = await DeleteAsync<OblioResponse<object>>(url, token);
            return response != null;
        }

        // Helper methods
        private async Task<T?> GetAsync<T>(string endpoint, string token)
        {
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            var response = await _httpClient.GetAsync(endpoint);
            response.EnsureSuccessStatusCode();

            var content = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<T>(content, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
        }

        private async Task<T?> PostAsync<T>(string endpoint, object? data, string token)
        {
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            
            HttpContent? content = null;
            if (data != null)
            {
                var json = JsonSerializer.Serialize(data, new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                });
                content = new StringContent(json, Encoding.UTF8, "application/json");
            }

            var response = await _httpClient.PostAsync(endpoint, content);
            response.EnsureSuccessStatusCode();

            var responseContent = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<T>(responseContent, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
        }

        private async Task<T?> DeleteAsync<T>(string endpoint, string token)
        {
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            var response = await _httpClient.DeleteAsync(endpoint);
            response.EnsureSuccessStatusCode();

            var content = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<T>(content, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
        }
    }

    // DTOs pentru Oblio API
    public class OblioTokenResponse
    {
        public string AccessToken { get; set; } = null!;
        public string ExpiresIn { get; set; } = null!;
        public string TokenType { get; set; } = null!;
        public string Scope { get; set; } = null!;
        public string RequestTime { get; set; } = null!;
    }

    public class OblioResponse<T>
    {
        public int Status { get; set; }
        public string StatusMessage { get; set; } = null!;
        public T? Data { get; set; }
    }

    public class OblioCompany
    {
        public string Cif { get; set; } = null!;
        public string Company { get; set; } = null!;
        public string UserTypeAccess { get; set; } = null!;
    }

    public class OblioVatRate
    {
        public string Name { get; set; } = null!;
        public decimal Percent { get; set; }
        public bool Default { get; set; }
    }

    public class OblioClient
    {
        public string Cif { get; set; } = null!;
        public string Name { get; set; } = null!;
        public string? Rc { get; set; }
        public string? Code { get; set; }
        public string? Address { get; set; }
        public string? State { get; set; }
        public string? City { get; set; }
        public string? Country { get; set; }
        public string? Iban { get; set; }
        public string? Bank { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? Contact { get; set; }
        public bool VatPayer { get; set; }
    }

    public class OblioProduct
    {
        public string Name { get; set; } = null!;
        public string? Code { get; set; }
        public string? Management { get; set; }
        public string? WorkStation { get; set; }
        public decimal? Stock { get; set; }
        public string? Unit { get; set; }
        public decimal Price { get; set; }
        public decimal VatPercentage { get; set; }
    }

    public class OblioInvoiceRequest
    {
        public OblioClientRequest CachedName { get; set; } = null!;
        public OblioClientRequest Client { get; set; } = null!;
        public string IssueDate { get; set; } = null!;
        public string DueDate { get; set; } = null!;
        public string DeliveryDate { get; set; } = null!;
        public string CollectDate { get; set; } = null!;
        public string SeriesName { get; set; } = null!;
        public string Language { get; set; } = "RO";
        public int Precision { get; set; } = 2;
        public string Currency { get; set; } = "RON";
        public List<OblioProductRequest> Products { get; set; } = new();
        public string? IssuerName { get; set; }
        public string? IssuerId { get; set; }
        public string? NoticeNumber { get; set; }
        public string? InternalNote { get; set; }
        public string? DepName { get; set; }
        public string? DepId { get; set; }
        public string? SalesAgent { get; set; }
        public string? SalesAgentId { get; set; }
        public string? Mention { get; set; }
        public string? Observations { get; set; }
        public string? WorkStation { get; set; }
        public string? WorkStationId { get; set; }
        public string? Management { get; set; }
        public string? ManagementId { get; set; }
        public string? PaymentLink { get; set; }
        public string? PaymentLinkText { get; set; }
        public string? PaymentLinkTextSecondary { get; set; }
        public string? PaymentLinkSecondary { get; set; }
        public string? PaymentLinkSecondaryText { get; set; }
        public string? PaymentLinkSecondaryTextSecondary { get; set; }
        public string? PaymentLinkThird { get; set; }
        public string? PaymentLinkThirdText { get; set; }
        public string? PaymentLinkThirdTextSecondary { get; set; }
        public string? PaymentLinkFourth { get; set; }
        public string? PaymentLinkFourthText { get; set; }
        public string? PaymentLinkFourthTextSecondary { get; set; }
        public string? PaymentLinkFifth { get; set; }
        public string? PaymentLinkFifthText { get; set; }
        public string? PaymentLinkFifthTextSecondary { get; set; }
        public string? PaymentLinkSixth { get; set; }
        public string? PaymentLinkSixthText { get; set; }
        public string? PaymentLinkSixthTextSecondary { get; set; }
        public string? PaymentLinkSeventh { get; set; }
        public string? PaymentLinkSeventhText { get; set; }
        public string? PaymentLinkSeventhTextSecondary { get; set; }
        public string? PaymentLinkEighth { get; set; }
        public string? PaymentLinkEighthText { get; set; }
        public string? PaymentLinkEighthTextSecondary { get; set; }
        public string? PaymentLinkNinth { get; set; }
        public string? PaymentLinkNinthText { get; set; }
        public string? PaymentLinkNinthTextSecondary { get; set; }
        public string? PaymentLinkTenth { get; set; }
        public string? PaymentLinkTenthText { get; set; }
        public string? PaymentLinkTenthTextSecondary { get; set; }
        public string? PaymentLinkEleventh { get; set; }
        public string? PaymentLinkEleventhText { get; set; }
        public string? PaymentLinkEleventhTextSecondary { get; set; }
        public string? PaymentLinkTwelfth { get; set; }
        public string? PaymentLinkTwelfthText { get; set; }
        public string? PaymentLinkTwelfthTextSecondary { get; set; }
        public string? PaymentLinkThirteenth { get; set; }
        public string? PaymentLinkThirteenthText { get; set; }
        public string? PaymentLinkThirteenthTextSecondary { get; set; }
        public string? PaymentLinkFourteenth { get; set; }
        public string? PaymentLinkFourteenthText { get; set; }
        public string? PaymentLinkFourteenthTextSecondary { get; set; }
        public string? PaymentLinkFifteenth { get; set; }
        public string? PaymentLinkFifteenthText { get; set; }
        public string? PaymentLinkFifteenthTextSecondary { get; set; }
        public string? PaymentLinkSixteenth { get; set; }
        public string? PaymentLinkSixteenthText { get; set; }
        public string? PaymentLinkSixteenthTextSecondary { get; set; }
        public string? PaymentLinkSeventeenth { get; set; }
        public string? PaymentLinkSeventeenthText { get; set; }
        public string? PaymentLinkSeventeenthTextSecondary { get; set; }
        public string? PaymentLinkEighteenth { get; set; }
        public string? PaymentLinkEighteenthText { get; set; }
        public string? PaymentLinkEighteenthTextSecondary { get; set; }
        public string? PaymentLinkNineteenth { get; set; }
        public string? PaymentLinkNineteenthText { get; set; }
        public string? PaymentLinkNineteenthTextSecondary { get; set; }
        public string? PaymentLinkTwentieth { get; set; }
        public string? PaymentLinkTwentiethText { get; set; }
        public string? PaymentLinkTwentiethTextSecondary { get; set; }
        public string? PaymentLinkTwentyFirst { get; set; }
        public string? PaymentLinkTwentyFirstText { get; set; }
        public string? PaymentLinkTwentyFirstTextSecondary { get; set; }
        public string? PaymentLinkTwentySecond { get; set; }
        public string? PaymentLinkTwentySecondText { get; set; }
        public string? PaymentLinkTwentySecondTextSecondary { get; set; }
        public string? PaymentLinkTwentyThird { get; set; }
        public string? PaymentLinkTwentyThirdText { get; set; }
        public string? PaymentLinkTwentyThirdTextSecondary { get; set; }
        public string? PaymentLinkTwentyFourth { get; set; }
        public string? PaymentLinkTwentyFourthText { get; set; }
        public string? PaymentLinkTwentyFourthTextSecondary { get; set; }
        public string? PaymentLinkTwentyFifth { get; set; }
        public string? PaymentLinkTwentyFifthText { get; set; }
        public string? PaymentLinkTwentyFifthTextSecondary { get; set; }
        public string? PaymentLinkTwentySixth { get; set; }
        public string? PaymentLinkTwentySixthText { get; set; }
        public string? PaymentLinkTwentySixthTextSecondary { get; set; }
        public string? PaymentLinkTwentySeventh { get; set; }
        public string? PaymentLinkTwentySeventhText { get; set; }
        public string? PaymentLinkTwentySeventhTextSecondary { get; set; }
        public string? PaymentLinkTwentyEighth { get; set; }
        public string? PaymentLinkTwentyEighthText { get; set; }
        public string? PaymentLinkTwentyEighthTextSecondary { get; set; }
        public string? PaymentLinkTwentyNinth { get; set; }
        public string? PaymentLinkTwentyNinthText { get; set; }
        public string? PaymentLinkTwentyNinthTextSecondary { get; set; }
        public string? PaymentLinkThirtieth { get; set; }
        public string? PaymentLinkThirtiethText { get; set; }
        public string? PaymentLinkThirtiethTextSecondary { get; set; }
        public string? PaymentLinkThirtyFirst { get; set; }
        public string? PaymentLinkThirtyFirstText { get; set; }
        public string? PaymentLinkThirtyFirstTextSecondary { get; set; }
        public string? PaymentLinkThirtySecond { get; set; }
        public string? PaymentLinkThirtySecondText { get; set; }
        public string? PaymentLinkThirtySecondTextSecondary { get; set; }
        public string? PaymentLinkThirtyThird { get; set; }
        public string? PaymentLinkThirtyThirdText { get; set; }
        public string? PaymentLinkThirtyThirdTextSecondary { get; set; }
        public string? PaymentLinkThirtyFourth { get; set; }
        public string? PaymentLinkThirtyFourthText { get; set; }
        public string? PaymentLinkThirtyFourthTextSecondary { get; set; }
        public string? PaymentLinkThirtyFifth { get; set; }
        public string? PaymentLinkThirtyFifthText { get; set; }
        public string? PaymentLinkThirtyFifthTextSecondary { get; set; }
        public string? PaymentLinkThirtySixth { get; set; }
        public string? PaymentLinkThirtySixthText { get; set; }
        public string? PaymentLinkThirtySixthTextSecondary { get; set; }
        public string? PaymentLinkThirtySeventh { get; set; }
        public string? PaymentLinkThirtySeventhText { get; set; }
        public string? PaymentLinkThirtySeventhTextSecondary { get; set; }
        public string? PaymentLinkThirtyEighth { get; set; }
        public string? PaymentLinkThirtyEighthText { get; set; }
        public string? PaymentLinkThirtyEighthTextSecondary { get; set; }
        public string? PaymentLinkThirtyNinth { get; set; }
        public string? PaymentLinkThirtyNinthText { get; set; }
        public string? PaymentLinkThirtyNinthTextSecondary { get; set; }
        public string? PaymentLinkFortieth { get; set; }
        public string? PaymentLinkFortiethText { get; set; }
        public string? PaymentLinkFortiethTextSecondary { get; set; }
        public string? PaymentLinkFortyFirst { get; set; }
        public string? PaymentLinkFortyFirstText { get; set; }
        public string? PaymentLinkFortyFirstTextSecondary { get; set; }
        public string? PaymentLinkFortySecond { get; set; }
        public string? PaymentLinkFortySecondText { get; set; }
        public string? PaymentLinkFortySecondTextSecondary { get; set; }
        public string? PaymentLinkFortyThird { get; set; }
        public string? PaymentLinkFortyThirdText { get; set; }
        public string? PaymentLinkFortyThirdTextSecondary { get; set; }
        public string? PaymentLinkFortyFourth { get; set; }
        public string? PaymentLinkFortyFourthText { get; set; }
        public string? PaymentLinkFortyFourthTextSecondary { get; set; }
        public string? PaymentLinkFortyFifth { get; set; }
        public string? PaymentLinkFortyFifthText { get; set; }
        public string? PaymentLinkFortyFifthTextSecondary { get; set; }
        public string? PaymentLinkFortySixth { get; set; }
        public string? PaymentLinkFortySixthText { get; set; }
        public string? PaymentLinkFortySixthTextSecondary { get; set; }
        public string? PaymentLinkFortySeventh { get; set; }
        public string? PaymentLinkFortySeventhText { get; set; }
        public string? PaymentLinkFortySeventhTextSecondary { get; set; }
        public string? PaymentLinkFortyEighth { get; set; }
        public string? PaymentLinkFortyEighthText { get; set; }
        public string? PaymentLinkFortyEighthTextSecondary { get; set; }
        public string? PaymentLinkFortyNinth { get; set; }
        public string? PaymentLinkFortyNinthText { get; set; }
        public string? PaymentLinkFortyNinthTextSecondary { get; set; }
        public string? PaymentLinkFiftieth { get; set; }
        public string? PaymentLinkFiftiethText { get; set; }
        public string? PaymentLinkFiftiethTextSecondary { get; set; }
    }

    public class OblioProformaRequest
    {
        public OblioClientRequest CachedName { get; set; } = null!;
        public OblioClientRequest Client { get; set; } = null!;
        public string IssueDate { get; set; } = null!;
        public string DueDate { get; set; } = null!;
        public string DeliveryDate { get; set; } = null!;
        public string SeriesName { get; set; } = null!;
        public string Language { get; set; } = "RO";
        public int Precision { get; set; } = 2;
        public string Currency { get; set; } = "RON";
        public List<OblioProductRequest> Products { get; set; } = new();
        public string? InternalNote { get; set; }
        public string? DepName { get; set; }
        public string? DepId { get; set; }
        public string? SalesAgent { get; set; }
        public string? SalesAgentId { get; set; }
        public string? Mention { get; set; }
        public string? Observations { get; set; }
        public string? WorkStation { get; set; }
        public string? WorkStationId { get; set; }
        public string? Management { get; set; }
        public string? ManagementId { get; set; }
    }

    public class OblioClientRequest
    {
        public string? Cif { get; set; }
        public string? Name { get; set; }
        public string? Rc { get; set; }
        public string? Code { get; set; }
        public string? Address { get; set; }
        public string? State { get; set; }
        public string? City { get; set; }
        public string? Country { get; set; }
        public string? Iban { get; set; }
        public string? Bank { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? Contact { get; set; }
        public bool? VatPayer { get; set; }
    }

    public class OblioProductRequest
    {
        public string Name { get; set; } = null!;
        public string? Code { get; set; }
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public string MeasuringUnit { get; set; } = "buc";
        public string Currency { get; set; } = "RON";
        public decimal VatPercentage { get; set; }
        public decimal Quantity { get; set; } = 1;
        public string? ProductType { get; set; }
        public string? Management { get; set; }
        public string? ManagementId { get; set; }
        public string? WorkStation { get; set; }
        public string? WorkStationId { get; set; }
        public decimal? Discount { get; set; }
        public string? DiscountType { get; set; }
    }

    public class OblioDocumentResponse
    {
        public int Status { get; set; }
        public string StatusMessage { get; set; } = null!;
        public OblioDocumentData? Data { get; set; }
    }

    public class OblioDocumentData
    {
        public string SeriesName { get; set; } = null!;
        public int Number { get; set; }
        public string Link { get; set; } = null!;
        public string LinkPdf { get; set; } = null!;
        public string? LinkXml { get; set; }
        public string? LinkView { get; set; }
    }
}

