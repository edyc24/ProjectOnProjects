using Microsoft.Extensions.Configuration;
using System.Net;
using System.Net.Mail;

namespace MoneyShop.BusinessLogic.Implementation.Otp
{
    public class EmailService
    {
        private readonly IConfiguration _configuration;
        private readonly string _smtpHost;
        private readonly int _smtpPort;
        private readonly string _smtpUsername;
        private readonly string _smtpPassword;
        private readonly string _fromEmail;
        private readonly string _fromName;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
            _smtpHost = _configuration["Email:SmtpHost"] ?? "smtp-mail.outlook.com";
            _smtpPort = int.Parse(_configuration["Email:SmtpPort"] ?? "587");
            _smtpUsername = _configuration["Email:SmtpUsername"] ?? "";
            _smtpPassword = _configuration["Email:SmtpPassword"] ?? "";
            _fromEmail = _configuration["Email:FromEmail"] ?? _smtpUsername;
            _fromName = _configuration["Email:FromName"] ?? "MoneyShop";
        }

        public async Task<bool> SendVerificationCodeAsync(string toEmail, string code)
        {
            try
            {
                if (string.IsNullOrEmpty(_smtpUsername) || string.IsNullOrEmpty(_smtpPassword))
                {
                    // In development, just log the code
                    System.Diagnostics.Debug.WriteLine($"[DEV] Email verification code for {toEmail}: {code}");
                    return true;
                }

                var subject = "Cod de verificare MoneyShop";
                var body = $@"
<div style=""font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;"">
    <h2 style=""color: #333;"">Verificare adresă de email</h2>
    <p>Bună ziua,</p>
    <p>Vă rugăm să folosiți următorul cod pentru a verifica adresa dvs. de email:</p>
    <div style=""background-color: #f5f5f5; border: 2px solid #333; border-radius: 5px; padding: 20px; text-align: center; margin: 20px 0;"">
        <h1 style=""color: #333; margin: 0; font-size: 32px; letter-spacing: 5px;"">{code}</h1>
    </div>
    <p>Acest cod expiră în 10 minute.</p>
    <p>Dacă nu ați solicitat acest cod, vă rugăm să ignorați acest email.</p>
    <p style=""margin-top: 30px; color: #666; font-size: 12px;"">Echipa MoneyShop</p>
</div>";

                using var client = new SmtpClient(_smtpHost, _smtpPort)
                {
                    EnableSsl = true,
                    Credentials = new NetworkCredential(_smtpUsername, _smtpPassword),
                    DeliveryMethod = SmtpDeliveryMethod.Network
                };

                using var message = new MailMessage
                {
                    From = new MailAddress(_fromEmail, _fromName),
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = true
                };

                message.To.Add(toEmail);

                await client.SendMailAsync(message);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[EmailService] Error sending email: {ex.Message}");
                return false;
            }
        }
    }
}

