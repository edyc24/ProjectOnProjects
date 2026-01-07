using System;
using MoneyShop.Common;

namespace MoneyShop.Entities.Entities
{
    public partial class Lead : IEntity
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string? Phone { get; set; }
        public string? Email { get; set; }
        public string? Judet { get; set; }
        public string? TypeCredit { get; set; }
        public bool GdprConsent { get; set; }
        public string? IpAddress { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public bool Converted { get; set; } = false; // Dacă a fost convertit în user/application
        public int? ConvertedToUserId { get; set; }
        public int? ConvertedToApplicationId { get; set; }
    }
}

