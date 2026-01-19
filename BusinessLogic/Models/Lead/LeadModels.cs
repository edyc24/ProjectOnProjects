namespace MoneyShop.BusinessLogic.Models.Lead
{
    public class LeadCaptureRequest
    {
        public string NumePrenume { get; set; } = null!;
        public string Telefon { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string Oras { get; set; } = null!;

        public bool CrediteActive { get; set; }
        public decimal? SoldTotalAprox { get; set; }
        public string? TipCreditor { get; set; } // BANCA, IFN, LEASING, MIXT, NU_STIU

        public bool Intarzieri { get; set; }
        public int? IntarzieriNumarAprox { get; set; }
        public int? IntarzieriZileMax { get; set; } // 0, 30, 60, 90, 120

        public decimal VenitNetLunar { get; set; }
        public decimal? BonuriMasaAprox { get; set; }

        public bool PoprireSauExecutorUltimii5Ani { get; set; }
        public bool? SituatiePoprireInchisa { get; set; }
    }

    public class LeadCaptureResponse
    {
        public int LeadId { get; set; }
        public string Status { get; set; } = "OK";
        public string Mesaj { get; set; } = null!;
    }

    public class LeadSessionData
    {
        public string? NumePrenume { get; set; }
        public string? Telefon { get; set; }
        public string? Email { get; set; }
        public string? Oras { get; set; }
        public bool? CrediteActive { get; set; }
        public decimal? SoldTotalAprox { get; set; }
        public string? TipCreditor { get; set; }
        public bool? Intarzieri { get; set; }
        public int? IntarzieriNumarAprox { get; set; }
        public int? IntarzieriZileMax { get; set; }
        public decimal? VenitNetLunar { get; set; }
        public decimal? BonuriMasaAprox { get; set; }
        public bool? PoprireSauExecutorUltimii5Ani { get; set; }
        public bool? SituatiePoprireInchisa { get; set; }
    }

    public class LeadNextRequest
    {
        public string? ConversationId { get; set; }
        public string Action { get; set; } = "answer"; // start, answer, reset
        public string? Answer { get; set; }
    }

    public class LeadNextResponse
    {
        public bool Done { get; set; }
        public int Step { get; set; }
        public string Mesaj { get; set; } = null!;
        public int? LeadId { get; set; }
    }
}

