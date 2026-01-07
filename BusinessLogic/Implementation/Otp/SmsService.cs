using Microsoft.Extensions.Configuration;
using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;

namespace MoneyShop.BusinessLogic.Implementation.Otp
{
    public class SmsService
    {
        private readonly IConfiguration _configuration;
        private readonly string _accountSid;
        private readonly string _authToken;
        private readonly string _fromPhoneNumber;

        public SmsService(IConfiguration configuration)
        {
            _configuration = configuration;
            _accountSid = _configuration["Twilio:AccountSid"] ?? "";
            _authToken = _configuration["Twilio:AuthToken"] ?? "";
            _fromPhoneNumber = _configuration["Twilio:FromPhoneNumber"] ?? "";
        }

        public async Task<bool> SendVerificationCodeAsync(string toPhoneNumber, string code)
        {
            try
            {
                if (string.IsNullOrEmpty(_accountSid) || string.IsNullOrEmpty(_authToken))
                {
                    // In development, just log the code
                    System.Diagnostics.Debug.WriteLine($"[DEV] SMS verification code for {toPhoneNumber}: {code}");
                    return true;
                }

                // Initialize Twilio client
                TwilioClient.Init(_accountSid, _authToken);

                // Send SMS via Twilio
                var message = await MessageResource.CreateAsync(
                    body: $"Codul dvs. de verificare MoneyShop este: {code}. Expiră în 10 minute.",
                    from: new PhoneNumber(_fromPhoneNumber),
                    to: new PhoneNumber(toPhoneNumber)
                );

                if (message.Status == MessageResource.StatusEnum.Failed || 
                    message.Status == MessageResource.StatusEnum.Undelivered)
                {
                    System.Diagnostics.Debug.WriteLine($"[SmsService] Failed to send SMS to {toPhoneNumber}. Status: {message.Status}");
                    return false;
                }

                System.Diagnostics.Debug.WriteLine($"[SmsService] SMS sent successfully to {toPhoneNumber}. Status: {message.Status}");
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[SmsService] Error sending SMS: {ex.Message}");
                // In case of error, still log the code for development
                System.Diagnostics.Debug.WriteLine($"[DEV] SMS verification code for {toPhoneNumber}: {code}");
                return false;
            }
        }
    }
}

