using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using ConsentEntity = MoneyShop.Entities.Entities.Consent;
using MoneyShop.Entities.Entities;

namespace MoneyShop.BusinessLogic.Implementation.Consent
{
    public class ConsentService : BaseService
    {
        public ConsentService(ServiceDependencies dependencies)
            : base(dependencies)
        {
        }

        public ConsentGrantResult GrantConsent(
            int userId,
            string consentType,
            string docType,
            string docVersion,
            string consentTextSnapshot,
            Guid? sessionId,
            string? ip,
            string? userAgent,
            byte[]? deviceHash,
            string sourceChannel)
        {
            // Find or create legal doc
            var legalDoc = UnitOfWork.LegalDocs.Get()
                .FirstOrDefault(d => d.DocType == docType && d.Version == docVersion && d.IsActive);

            if (legalDoc == null)
            {
                // Create new legal doc entry
                var contentHash = ComputeContentHash(consentTextSnapshot);
                legalDoc = new LegalDoc
                {
                    DocId = Guid.NewGuid(),
                    DocType = docType,
                    Version = docVersion,
                    PublishedAt = DateTime.UtcNow,
                    ContentHash = contentHash,
                    IsActive = true
                };
                UnitOfWork.LegalDocs.Insert(legalDoc);
            }

            // Create consent
            var consent = new ConsentEntity
            {
                ConsentId = Guid.NewGuid(),
                UserId = userId,
                ConsentType = consentType,
                Status = "granted",
                GrantedAt = DateTime.UtcNow,
                DocId = legalDoc.DocId,
                ConsentTextSnapshot = consentTextSnapshot,
                SessionId = sessionId,
                Ip = ip,
                UserAgent = userAgent,
                DeviceHash = deviceHash,
                SourceChannel = sourceChannel
            };

            UnitOfWork.Consents.Insert(consent);
            UnitOfWork.SaveChanges();

            return new ConsentGrantResult
            {
                ConsentId = consent.ConsentId,
                Status = consent.Status,
                GrantedAt = consent.GrantedAt
            };
        }

        public bool RevokeConsent(Guid consentId, int userId)
        {
            var consent = UnitOfWork.Consents.Get()
                .FirstOrDefault(c => c.ConsentId == consentId && c.UserId == userId);

            if (consent == null || consent.Status == "revoked")
            {
                return false;
            }

            consent.Status = "revoked";
            consent.RevokedAt = DateTime.UtcNow;
            UnitOfWork.Consents.Update(consent);
            UnitOfWork.SaveChanges();

            return true;
        }

        public List<ConsentInfo> GetUserConsents(int userId)
        {
            return UnitOfWork.Consents.Get()
                .Where(c => c.UserId == userId)
                .OrderByDescending(c => c.GrantedAt)
                .Select(c => new ConsentInfo
                {
                    ConsentId = c.ConsentId,
                    ConsentType = c.ConsentType,
                    Status = c.Status,
                    GrantedAt = c.GrantedAt,
                    RevokedAt = c.RevokedAt,
                    DocType = c.Doc != null ? c.Doc.DocType : null,
                    DocVersion = c.Doc != null ? c.Doc.Version : null
                })
                .ToList();
        }

        private byte[] ComputeContentHash(string content)
        {
            using var sha256 = SHA256.Create();
            return sha256.ComputeHash(Encoding.UTF8.GetBytes(content));
        }
    }

    public class ConsentGrantResult
    {
        public Guid ConsentId { get; set; }
        public string Status { get; set; } = null!;
        public DateTime GrantedAt { get; set; }
    }

    public class ConsentInfo
    {
        public Guid ConsentId { get; set; }
        public string ConsentType { get; set; } = null!;
        public string Status { get; set; } = null!;
        public DateTime GrantedAt { get; set; }
        public DateTime? RevokedAt { get; set; }
        public string? DocType { get; set; }
        public string? DocVersion { get; set; }
    }
}

