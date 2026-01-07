using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using OfficeOpenXml;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using BrokerDirectoryEntity = MoneyShop.Entities.Entities.BrokerDirectory;
using MoneyShop.Entities.Entities;
using Microsoft.Extensions.Hosting;

namespace MoneyShop.BusinessLogic.Implementation.Broker
{
    public class BrokerDirectoryService : BaseService
    {
        private readonly IHostEnvironment _environment;

        public BrokerDirectoryService(ServiceDependencies dependencies, IHostEnvironment environment)
            : base(dependencies)
        {
            _environment = environment;
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
        }

        /// <summary>
        /// Uploads Excel file and saves metadata
        /// </summary>
        public BrokerDirectoryUploadResult UploadExcelFile(
            int userId,
            string fileName,
            byte[] fileContent,
            string? notes = null)
        {
            // Validate file extension
            var extension = Path.GetExtension(fileName).ToLower();
            if (extension != ".xlsx" && extension != ".xls")
            {
                throw new ArgumentException("Only Excel files (.xlsx, .xls) are allowed");
            }

            // Generate storage path
            var year = DateTime.UtcNow.Year;
            var month = DateTime.UtcNow.Month.ToString("D2");
            var uniqueFileName = $"{Guid.NewGuid()}{extension}";
            var blobPath = $"brokers/excel/{year}/{month}/{uniqueFileName}";
            var localPath = Path.Combine(_environment.ContentRootPath, "wwwroot", blobPath);

            // Ensure directory exists
            var directory = Path.GetDirectoryName(localPath);
            if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }

            // Save file locally (in production, upload to Azure Blob Storage)
            File.WriteAllBytes(localPath, fileContent);

            // Save metadata
            var directoryEntry = new BrokerDirectoryEntity
            {
                ExcelFileName = fileName,
                BlobPath = blobPath,
                FileSize = fileContent.Length,
                UploadedAt = DateTime.UtcNow,
                UploadedByUserId = userId,
                Notes = notes
            };

            UnitOfWork.BrokerDirectories.Insert(directoryEntry);
            UnitOfWork.SaveChanges();

            return new BrokerDirectoryUploadResult
            {
                DirectoryId = directoryEntry.Id,
                ExcelFileName = directoryEntry.ExcelFileName,
                BlobPath = directoryEntry.BlobPath,
                UploadedAt = directoryEntry.UploadedAt
            };
        }

        /// <summary>
        /// Gets the latest uploaded Excel file
        /// </summary>
        public BrokerDirectoryInfo? GetLatestDirectory()
        {
            var directory = UnitOfWork.BrokerDirectories.Get()
                .OrderByDescending(d => d.UploadedAt)
                .FirstOrDefault();

            if (directory == null)
                return null;

            return new BrokerDirectoryInfo
            {
                DirectoryId = directory.Id,
                ExcelFileName = directory.ExcelFileName,
                BlobPath = directory.BlobPath,
                FileSize = directory.FileSize,
                UploadedAt = directory.UploadedAt,
                UploadedByUserId = directory.UploadedByUserId,
                Notes = directory.Notes
            };
        }

        /// <summary>
        /// Reads brokers from Excel file and searches
        /// </summary>
        public List<BrokerInfo> SearchBrokers(string? searchTerm = null, int? limit = null)
        {
            // Get latest Excel file
            var directory = GetLatestDirectory();
            if (directory == null)
            {
                return new List<BrokerInfo>();
            }

            var localPath = Path.Combine(_environment.ContentRootPath, "wwwroot", directory.BlobPath);
            if (!File.Exists(localPath))
            {
                throw new FileNotFoundException("Excel file not found");
            }

            var brokers = new List<BrokerInfo>();

            using (var package = new ExcelPackage(new FileInfo(localPath)))
            {
                var worksheet = package.Workbook.Worksheets[0]; // First sheet
                if (worksheet == null)
                {
                    return brokers;
                }

                // Assume first row is header
                var startRow = 2; // Skip header row
                var endRow = worksheet.Dimension?.End.Row ?? startRow;

                // Try to detect column positions (flexible) - match Romanian ANPC format
                var denumireCol = FindColumn(worksheet, new[] { "Denumire", "Nume", "Name", "Nume complet", "Full Name", "Denumirea" });
                var tipCol = FindColumn(worksheet, new[] { "Tip", "Tip intermediar", "Type" });
                var creditorCol = FindColumn(worksheet, new[] { "Creditorul", "Creditor", "Creditorul/intermediarul", "Creditorul/intermediarul in numele caruia actioneaza" });
                var numeConducereCol = FindColumn(worksheet, new[] { "Nume conducere", "Nume conducere / persoane responsabile", "Persoane responsabile", "Conducere", "Responsabile", "Nume conducere / persoane responsabile cu activitatea de intermediere credite" });
                var statMembruCol = FindColumn(worksheet, new[] { "Statul membru", "Stat Membru", "STATUL MEMBRU", "Member State", "STATUL MEMBRU IN CARE INTERMEDIARUL DE CREDITE ISI DESFASOARA ACTIVITATEA" });
                
                // Optional columns (might not exist in all files)
                var cuiCol = FindColumn(worksheet, new[] { "CUI", "CIF", "Tax ID", "Cod fiscal" });
                var emailCol = FindColumn(worksheet, new[] { "Email", "E-mail", "Mail" });
                var phoneCol = FindColumn(worksheet, new[] { "Telefon", "Phone", "Tel" });
                var statusCol = FindColumn(worksheet, new[] { "Status", "Stare" });

                // Fallback to fixed positions for ANPC format if columns not found
                // ANPC format: A=Nr.Crt, B=Denumire, C=Tip, D=Creditorul, E=Nume conducere, F=Stat Membru
                if (worksheet.Dimension != null)
                {
                    // Log all headers for debugging
                    var headers = new System.Text.StringBuilder();
                    for (int col = 1; col <= Math.Min(worksheet.Dimension.End.Column, 6); col++)
                    {
                        var header = GetCellValue(worksheet, 1, col);
                        headers.Append($"Col{col}: '{header}' ");
                    }
                    System.Diagnostics.Debug.WriteLine($"Excel Headers: {headers}");
                    
                    if (!denumireCol.HasValue && worksheet.Dimension.End.Column >= 2)
                    {
                        denumireCol = 2; // Column B = Denumire
                        System.Diagnostics.Debug.WriteLine("Using fallback: denumireCol = 2");
                    }
                    if (!numeConducereCol.HasValue && worksheet.Dimension.End.Column >= 5)
                    {
                        numeConducereCol = 5; // Column E = Nume conducere
                        System.Diagnostics.Debug.WriteLine("Using fallback: numeConducereCol = 5");
                    }
                    
                    System.Diagnostics.Debug.WriteLine($"Final columns - Denumire: {denumireCol}, NumeConducere: {numeConducereCol}, EndRow: {endRow}");
                }

                for (int row = startRow; row <= endRow; row++)
                {
                    // Try to get name from "Denumire" column first (company name)
                    var denumire = GetCellValue(worksheet, row, denumireCol);
                    
                    // If no denumire, try to get from "Nume conducere" (person name)
                    var numeConducere = GetCellValue(worksheet, row, numeConducereCol);
                    
                    // Use denumire as primary, fallback to numeConducere
                    var name = !string.IsNullOrWhiteSpace(denumire) ? denumire : numeConducere;
                    
                    if (string.IsNullOrWhiteSpace(name))
                        continue;

                    // Extract person name from "Nume conducere" column
                    // Format is usually "FirstName LastName administrator" or multiple names
                    var personName = ExtractPersonName(numeConducere);
                    
                    // Use person name as FullName if we have it, otherwise use company name
                    var fullName = !string.IsNullOrWhiteSpace(personName) ? personName : name;
                    
                    // Extract CUI from denumire if it's in the format "SC COMPANY SRL CUI:12345678"
                    var cui = GetCellValue(worksheet, row, cuiCol);
                    if (string.IsNullOrWhiteSpace(cui) && !string.IsNullOrWhiteSpace(denumire))
                    {
                        cui = ExtractCuiFromText(denumire);
                    }

                    var broker = new BrokerInfo
                    {
                        BrokerId = Guid.NewGuid(), // Generate temporary ID
                        FullName = fullName,
                        FirmName = !string.IsNullOrWhiteSpace(denumire) && denumire != fullName ? denumire : null,
                        FirmCui = cui,
                        PublicEmail = GetCellValue(worksheet, row, emailCol),
                        PublicPhone = GetCellValue(worksheet, row, phoneCol),
                        Status = GetCellValue(worksheet, row, statusCol) ?? "pending"
                    };

                    // Apply search filter
                    if (string.IsNullOrEmpty(searchTerm) || 
                        MatchesSearch(broker, searchTerm))
                    {
                        brokers.Add(broker);
                    }

                    // Apply limit
                    if (limit.HasValue && brokers.Count >= limit.Value)
                    {
                        break;
                    }
                }
            }

            return brokers;
        }

        private int? FindColumn(ExcelWorksheet worksheet, string[] possibleNames)
        {
            if (worksheet.Dimension == null)
                return null;

            for (int col = 1; col <= worksheet.Dimension.End.Column; col++)
            {
                var headerValue = GetCellValue(worksheet, 1, col);
                if (string.IsNullOrWhiteSpace(headerValue))
                    continue;

                var headerLower = headerValue.ToLower().Trim();
                
                foreach (var name in possibleNames)
                {
                    var nameLower = name.ToLower().Trim();
                    
                    // Try exact match first
                    if (headerLower == nameLower)
                    {
                        return col;
                    }
                    
                    // Try contains match (both ways)
                    if (headerLower.Contains(nameLower) || nameLower.Contains(headerLower))
                    {
                        return col;
                    }
                    
                    // Try removing special characters and spaces for comparison
                    var headerNormalized = System.Text.RegularExpressions.Regex.Replace(headerLower, @"[^\w]", "");
                    var nameNormalized = System.Text.RegularExpressions.Regex.Replace(nameLower, @"[^\w]", "");
                    if (headerNormalized.Contains(nameNormalized) || nameNormalized.Contains(headerNormalized))
                    {
                        return col;
                    }
                }
            }

            return null;
        }

        private string? GetCellValue(ExcelWorksheet worksheet, int row, int? col)
        {
            if (!col.HasValue)
                return null;

            var cell = worksheet.Cells[row, col.Value];
            if (cell.Value == null)
                return null;

            return cell.Value.ToString()?.Trim();
        }

        private bool MatchesSearch(BrokerInfo broker, string searchTerm)
        {
            if (string.IsNullOrEmpty(searchTerm))
                return true;

            var term = searchTerm.ToLower();
            return
                (broker.FullName?.ToLower().Contains(term) ?? false) ||
                (broker.FirmName?.ToLower().Contains(term) ?? false) ||
                (broker.FirmCui?.ToLower().Contains(term) ?? false) ||
                (broker.PublicEmail?.ToLower().Contains(term) ?? false) ||
                (broker.PublicPhone?.ToLower().Contains(term) ?? false);
        }

        /// <summary>
        /// Extracts person name from "Nume conducere" column
        /// Format: "FirstName LastName administrator" or "FirstName1 LastName1 FirstName2 LastName2 administrator"
        /// </summary>
        private string? ExtractPersonName(string? text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return null;

            // Remove "administrator" and other common suffixes
            var cleaned = text
                .Replace("administrator", "", StringComparison.OrdinalIgnoreCase)
                .Replace("admin", "", StringComparison.OrdinalIgnoreCase)
                .Trim();

            // Split by common separators and take first name
            var parts = cleaned.Split(new[] { ' ', '-', ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            
            if (parts.Length >= 2)
            {
                // Take first two parts as "FirstName LastName"
                return $"{parts[0]} {parts[1]}";
            }
            else if (parts.Length == 1)
            {
                return parts[0];
            }

            return cleaned;
        }

        /// <summary>
        /// Extracts CUI from text if present
        /// </summary>
        private string? ExtractCuiFromText(string? text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return null;

            // Look for CUI pattern: "CUI:12345678" or "CUI 12345678" or "RO12345678"
            var cuiPattern = System.Text.RegularExpressions.Regex.Match(
                text,
                @"(?:CUI[:\s]*)?(?:RO)?(\d{8,13})",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase
            );

            if (cuiPattern.Success)
            {
                return cuiPattern.Groups[1].Value;
            }

            return null;
        }
    }

    public class BrokerDirectoryUploadResult
    {
        public int DirectoryId { get; set; }
        public string ExcelFileName { get; set; } = null!;
        public string BlobPath { get; set; } = null!;
        public DateTime UploadedAt { get; set; }
    }

    public class BrokerDirectoryInfo
    {
        public int DirectoryId { get; set; }
        public string ExcelFileName { get; set; } = null!;
        public string BlobPath { get; set; } = null!;
        public long FileSize { get; set; }
        public DateTime UploadedAt { get; set; }
        public int UploadedByUserId { get; set; }
        public string? Notes { get; set; }
    }

    public class BrokerInfo
    {
        public Guid BrokerId { get; set; }
        public string FullName { get; set; } = null!;
        public string? FirmName { get; set; }
        public string? FirmCui { get; set; }
        public string? PublicEmail { get; set; }
        public string? PublicPhone { get; set; }
        public string Status { get; set; } = "pending";
    }
}

