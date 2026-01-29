using System;
using System.ComponentModel.DataAnnotations;

namespace MoneyShop.BusinessLogic.Implementation.Account
{
    public class RegisterModel
    {
        // Date personale
        [Required(ErrorMessage = "Email-ul este obligatoriu")]
        [EmailAddress(ErrorMessage = "Adresa de email nu este validă")]
        public string Email { get; set; }
        
        [Required(ErrorMessage = "Parola este obligatorie")]
        [MinLength(8, ErrorMessage = "Parola trebuie să aibă minim 8 caractere")]
        public string Password { get; set; }
        
        [Required(ErrorMessage = "Confirmarea parolei este obligatorie")]
        [Compare("Password", ErrorMessage = "Parolele nu coincid")]
        public string ConfirmPassword { get; set; }
        
        [Required(ErrorMessage = "Prenumele este obligatoriu")]
        public string FirstName { get; set; }
        
        [Required(ErrorMessage = "Numele este obligatoriu")]
        public string LastName { get; set; }
        
        [Phone(ErrorMessage = "Numărul de telefon nu este valid")]
        public string Phone { get; set; }
        
        public int Role { get; set; } = 1; // Default: Utilizator
        
        // Consimțăminte obligatorii
        [Required(ErrorMessage = "Trebuie să accepți Termenii și Condițiile")]
        [Range(typeof(bool), "true", "true", ErrorMessage = "Trebuie să accepți Termenii și Condițiile")]
        public bool AcceptTerms { get; set; }
        
        [Required(ErrorMessage = "Trebuie să accepți Politica GDPR")]
        [Range(typeof(bool), "true", "true", ErrorMessage = "Trebuie să accepți Politica GDPR")]
        public bool AcceptGdpr { get; set; }
        
        [Required(ErrorMessage = "Trebuie să accepți informațiile despre costuri")]
        [Range(typeof(bool), "true", "true", ErrorMessage = "Trebuie să accepți informațiile despre costuri")]
        public bool AcceptCosts { get; set; }
        
        // Mandate (obligatorii pentru funcționalitatea de eligibilitate)
        [Required(ErrorMessage = "Mandatul ANAF este necesar pentru verificarea eligibilității")]
        [Range(typeof(bool), "true", "true", ErrorMessage = "Mandatul ANAF este necesar pentru verificarea eligibilității")]
        public bool MandateAnaf { get; set; }
        
        // Opțional - Mandat Birou Credit
        public bool MandateBiroCredit { get; set; }
        
        // Opțional - Transfer date către broker (implicit OFF)
        public bool ShareToBroker { get; set; }
        
        // Metadate pentru audit
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public string DeviceHash { get; set; }
        public DateTime ConsentTimestamp { get; set; } = DateTime.UtcNow;
    }
}
