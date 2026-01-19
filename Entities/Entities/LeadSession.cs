using System;

namespace MoneyShop.Entities.Entities
{
    public class LeadSession
    {
        public int Id { get; set; }
        public string SessionKey { get; set; } = null!; // "lead_session:<userId>:<conversationId>"
        public int? UserId { get; set; }
        public string? ConversationId { get; set; }
        public int Step { get; set; } // 1-9 (9 = DONE)
        
        // Session data (JSON pentru flexibilitate)
        public string? SessionDataJson { get; set; }
        
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }
}

