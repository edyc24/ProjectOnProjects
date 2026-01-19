using System;

namespace MoneyShop.Entities.Entities
{
    public class ChatRateLimit
    {
        public int Id { get; set; }
        public string RateLimitKey { get; set; } = null!;
        public int Count { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }
}

