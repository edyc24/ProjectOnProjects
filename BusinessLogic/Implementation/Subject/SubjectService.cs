using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using SubjectMapEntity = MoneyShop.Entities.Entities.SubjectMap;
using MoneyShop.Entities.Entities;
using Microsoft.Extensions.Configuration;

namespace MoneyShop.BusinessLogic.Implementation.Subject
{
    public class SubjectService : BaseService
    {
        private readonly IConfiguration _configuration;
        private const string PEPPER1_KEY = "Subject:Pepper1";
        private const string PEPPER2_KEY = "Subject:Pepper2";

        public SubjectService(ServiceDependencies dependencies, IConfiguration configuration)
            : base(dependencies)
        {
            _configuration = configuration;
        }

        /// <summary>
        /// Creates or gets a subject_id for a user based on CNP
        /// </summary>
        public SubjectMapResult GetOrCreateSubject(int userId, string cnp)
        {
            if (string.IsNullOrWhiteSpace(cnp))
            {
                throw new ArgumentException("CNP cannot be empty", nameof(cnp));
            }

            // Get peppers from configuration (in production, these should be in Key Vault)
            var pepper1 = GetPepper(PEPPER1_KEY);
            var pepper2 = GetPepper(PEPPER2_KEY);

            // Compute CNP hash
            var cnpHash = ComputeCnpHash(cnp, pepper1);

            // Check if subject already exists
            var existingSubject = UnitOfWork.SubjectMaps.Get()
                .FirstOrDefault(s => s.CnpHash.SequenceEqual(cnpHash));

            if (existingSubject != null)
            {
                return new SubjectMapResult
                {
                    SubjectId = existingSubject.SubjectId,
                    CnpHash = existingSubject.CnpHash,
                    CnpLast4 = existingSubject.CnpLast4,
                    CnpMasked = MaskCnp(existingSubject.CnpLast4),
                    IsNew = false
                };
            }

            // Create new subject
            var subjectId = GenerateSubjectId(cnp, pepper2);
            var cnpLast4 = cnp.Length >= 4 ? cnp.Substring(cnp.Length - 4) : null;

            var subject = new SubjectMapEntity
            {
                SubjectId = subjectId,
                UserId = userId,
                CnpHash = cnpHash,
                CnpLast4 = cnpLast4,
                CreatedAt = DateTime.UtcNow
            };

            UnitOfWork.SubjectMaps.Insert(subject);
            UnitOfWork.SaveChanges();

            return new SubjectMapResult
            {
                SubjectId = subject.SubjectId,
                CnpHash = subject.CnpHash,
                CnpLast4 = subject.CnpLast4,
                CnpMasked = MaskCnp(subject.CnpLast4),
                IsNew = true
            };
        }

        /// <summary>
        /// Gets subject by user ID
        /// </summary>
        public SubjectMapResult? GetSubjectByUserId(int userId)
        {
            var subject = UnitOfWork.SubjectMaps.Get()
                .FirstOrDefault(s => s.UserId == userId);

            if (subject == null)
                return null;

            return new SubjectMapResult
            {
                SubjectId = subject.SubjectId,
                CnpHash = subject.CnpHash,
                CnpLast4 = subject.CnpLast4,
                CnpMasked = MaskCnp(subject.CnpLast4),
                IsNew = false
            };
        }

        /// <summary>
        /// Gets subject by subject_id
        /// </summary>
        public SubjectMapResult? GetSubjectById(string subjectId)
        {
            var subject = UnitOfWork.SubjectMaps.Get()
                .FirstOrDefault(s => s.SubjectId == subjectId);

            if (subject == null)
                return null;

            return new SubjectMapResult
            {
                SubjectId = subject.SubjectId,
                CnpHash = subject.CnpHash,
                CnpLast4 = subject.CnpLast4,
                CnpMasked = MaskCnp(subject.CnpLast4),
                IsNew = false
            };
        }

        /// <summary>
        /// Masks CNP for display (e.g., ******5579)
        /// </summary>
        public static string MaskCnp(string? cnpLast4)
        {
            if (string.IsNullOrEmpty(cnpLast4))
                return "******";

            return $"******{cnpLast4}";
        }

        /// <summary>
        /// Computes HMAC-SHA256 hash of CNP with pepper1
        /// </summary>
        private byte[] ComputeCnpHash(string cnp, string pepper)
        {
            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(pepper));
            return hmac.ComputeHash(Encoding.UTF8.GetBytes(cnp));
        }

        /// <summary>
        /// Generates subject_id: "MS-" + BASE32(HMAC-SHA256(pepper2, CNP))[0:16]
        /// </summary>
        private string GenerateSubjectId(string cnp, string pepper)
        {
            using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(pepper));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(cnp));
            
            // Convert to BASE32 and take first 16 characters
            var base32 = ConvertToBase32(hash);
            var subjectId = $"MS-{base32.Substring(0, Math.Min(16, base32.Length))}";
            
            return subjectId;
        }

        /// <summary>
        /// Converts byte array to BASE32 string
        /// </summary>
        private string ConvertToBase32(byte[] bytes)
        {
            const string base32Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
            var result = new StringBuilder();
            int bits = 0;
            int value = 0;

            foreach (byte b in bytes)
            {
                value = (value << 8) | b;
                bits += 8;

                while (bits >= 5)
                {
                    result.Append(base32Chars[(value >> (bits - 5)) & 31]);
                    bits -= 5;
                }
            }

            if (bits > 0)
            {
                result.Append(base32Chars[(value << (5 - bits)) & 31]);
            }

            return result.ToString();
        }

        /// <summary>
        /// Gets pepper from configuration (in production, should be from Key Vault)
        /// </summary>
        private string GetPepper(string key)
        {
            var pepper = _configuration[key];
            if (string.IsNullOrEmpty(pepper))
            {
                // Fallback for development
                pepper = _configuration["Subject:DefaultPepper"] ?? "MoneyShop_Default_Pepper_Change_In_Production_2024";
            }
            return pepper;
        }
    }

    public class SubjectMapResult
    {
        public string SubjectId { get; set; } = null!;
        public byte[] CnpHash { get; set; } = null!;
        public string? CnpLast4 { get; set; }
        public string CnpMasked { get; set; } = null!;
        public bool IsNew { get; set; }
    }
}

