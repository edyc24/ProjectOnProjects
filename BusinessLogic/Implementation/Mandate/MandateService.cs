using System;
using System.Linq;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using MandateEntity = MoneyShop.Entities.Entities.Mandate;
using MoneyShop.Entities.Entities;

namespace MoneyShop.BusinessLogic.Implementation.Mandate
{
    public class MandateService : BaseService
    {
        public MandateService(ServiceDependencies dependencies)
            : base(dependencies)
        {
        }

        public MandateCreateResult CreateMandate(
            int userId,
            string mandateType,
            string? consentEventId,
            int expiresInDays = 30)
        {
            // Check if user already has an active mandate of this type
            var existingMandate = UnitOfWork.Mandates.Get()
                .FirstOrDefault(m => m.UserId == userId &&
                                    m.MandateType == mandateType &&
                                    m.Status == "active" &&
                                    m.ExpiresAt > DateTime.UtcNow);

            if (existingMandate != null)
            {
                // Return existing mandate
                return new MandateCreateResult
                {
                    MandateId = existingMandate.MandateId,
                    Status = existingMandate.Status,
                    GrantedAt = existingMandate.GrantedAt,
                    ExpiresAt = existingMandate.ExpiresAt
                };
            }

            // Create new mandate
            var mandate = new MandateEntity
            {
                MandateId = Guid.NewGuid(),
                UserId = userId,
                MandateType = mandateType,
                Scope = "credit_eligibility_only",
                Status = "active",
                GrantedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddDays(expiresInDays),
                ConsentEventId = consentEventId
            };

            UnitOfWork.Mandates.Insert(mandate);
            UnitOfWork.SaveChanges();

            return new MandateCreateResult
            {
                MandateId = mandate.MandateId,
                Status = mandate.Status,
                GrantedAt = mandate.GrantedAt,
                ExpiresAt = mandate.ExpiresAt
            };
        }

        public MandateInfo? GetMandate(Guid mandateId, int userId)
        {
            var mandate = UnitOfWork.Mandates.Get()
                .FirstOrDefault(m => m.MandateId == mandateId && m.UserId == userId);

            if (mandate == null)
                return null;

            // Check if expired
            if (mandate.Status == "active" && mandate.ExpiresAt < DateTime.UtcNow)
            {
                mandate.Status = "expired";
                UnitOfWork.Mandates.Update(mandate);
                UnitOfWork.SaveChanges();
            }

            return new MandateInfo
            {
                MandateId = mandate.MandateId,
                MandateType = mandate.MandateType,
                Status = mandate.Status,
                GrantedAt = mandate.GrantedAt,
                ExpiresAt = mandate.ExpiresAt,
                RevokedAt = mandate.RevokedAt
            };
        }

        public List<MandateInfo> GetUserMandates(int userId)
        {
            return UnitOfWork.Mandates.Get()
                .Where(m => m.UserId == userId)
                .OrderByDescending(m => m.GrantedAt)
                .Select(m => new MandateInfo
                {
                    MandateId = m.MandateId,
                    MandateType = m.MandateType,
                    Status = m.Status,
                    GrantedAt = m.GrantedAt,
                    ExpiresAt = m.ExpiresAt,
                    RevokedAt = m.RevokedAt
                })
                .ToList();
        }

        public bool RevokeMandate(Guid mandateId, int userId, string? reason = null)
        {
            var mandate = UnitOfWork.Mandates.Get()
                .FirstOrDefault(m => m.MandateId == mandateId && m.UserId == userId);

            if (mandate == null || mandate.Status != "active")
            {
                return false;
            }

            mandate.Status = "revoked";
            mandate.RevokedAt = DateTime.UtcNow;
            mandate.RevokedReason = reason;
            UnitOfWork.Mandates.Update(mandate);
            UnitOfWork.SaveChanges();

            return true;
        }

        public bool HasActiveMandate(int userId, string mandateType)
        {
            return UnitOfWork.Mandates.Get()
                .Any(m => m.UserId == userId &&
                         m.MandateType == mandateType &&
                         m.Status == "active" &&
                         m.ExpiresAt > DateTime.UtcNow);
        }
    }

    public class MandateCreateResult
    {
        public Guid MandateId { get; set; }
        public string Status { get; set; } = null!;
        public DateTime GrantedAt { get; set; }
        public DateTime ExpiresAt { get; set; }
    }

    public class MandateInfo
    {
        public Guid MandateId { get; set; }
        public string MandateType { get; set; } = null!;
        public string Status { get; set; } = null!;
        public DateTime GrantedAt { get; set; }
        public DateTime ExpiresAt { get; set; }
        public DateTime? RevokedAt { get; set; }
    }
}

