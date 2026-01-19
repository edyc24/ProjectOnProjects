using System;

namespace MoneyShop.Entities.Entities
{
    public class ChatUsage
    {
        public int Id { get; set; }
        public string MonthKey { get; set; } = null!; // YYYY-MM
        public decimal UsdSpent { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string? MetaLast { get; set; }
    }
}

