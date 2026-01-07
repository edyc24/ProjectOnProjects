using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Auth;
using System;
using System.Linq;
using Microsoft.Extensions.DependencyInjection;
using MoneyShop.DataAccess;
using MoneyShop.Services;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class OtpController : ControllerBase
    {
        private readonly OtpService _otpService;

        public OtpController(OtpService otpService)
        {
            _otpService = otpService;
        }

        /// <summary>
        /// Request OTP (SMS/Email)
        /// </summary>
        [HttpPost("request")]
        public IActionResult RequestOtp([FromBody] OtpRequestModel model)
        {
            if (model == null || string.IsNullOrEmpty(model.Phone) || string.IsNullOrEmpty(model.Purpose))
            {
                return BadRequest(new { message = "Phone and purpose are required" });
            }

            try
            {
                var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
                var deviceHash = ComputeDeviceHash();

                var result = _otpService.RequestOtp(
                    model.Phone,
                    model.Purpose,
                    model.UserId,
                    ip,
                    deviceHash
                );

                return Ok(new
                {
                    otpId = result.OtpId,
                    expiresInSeconds = result.ExpiresInSeconds
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Verify OTP and issue session token (for login flows)
        /// </summary>
        [HttpPost("verify")]
        public IActionResult VerifyOtp([FromBody] OtpVerifyModel model)
        {
            if (model == null || 
                model.OtpId == Guid.Empty || 
                string.IsNullOrEmpty(model.Phone) || 
                string.IsNullOrEmpty(model.Code) ||
                string.IsNullOrEmpty(model.Purpose))
            {
                return BadRequest(new { message = "OtpId, phone, code, and purpose are required" });
            }

            try
            {
                var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
                var result = _otpService.VerifyOtp(
                    model.OtpId,
                    model.Phone,
                    model.Purpose,
                    model.Code,
                    ip
                );

                if (!result.IsValid)
                {
                    return Unauthorized(new { message = result.Message });
                }

                // For LOGIN_SMS, we need to create a session and return JWT
                if (model.Purpose == "LOGIN_SMS" && result.UserId.HasValue)
                {
                    // Get user and generate JWT
                    var jwtService = HttpContext.RequestServices.GetRequiredService<MoneyShop.Services.JwtService>();
                    var unitOfWork = HttpContext.RequestServices.GetRequiredService<MoneyShop.DataAccess.UnitOfWork>();
                    
                    var user = unitOfWork.Users.Get().FirstOrDefault(u => u.IdUtilizator == result.UserId.Value);
                    if (user == null)
                    {
                        return Unauthorized(new { message = "User not found" });
                    }

                    // Create session
                    var session = new MoneyShop.Entities.Entities.Session
                    {
                        SessionId = Guid.NewGuid(),
                        UserId = result.UserId.Value,
                        CreatedAt = DateTime.UtcNow,
                        ExpiresAt = DateTime.UtcNow.AddHours(24),
                        Ip = HttpContext.Connection.RemoteIpAddress?.ToString(),
                        UserAgent = HttpContext.Request.Headers["User-Agent"].ToString(),
                        SourceChannel = "web" // TODO: Detect from request
                    };

                    unitOfWork.Sessions.Insert(session);
                    unitOfWork.SaveChanges();

                    // Generate JWT
                    var userRoles = new UserRoles();
                    var rolesDict = userRoles.CreateUserRolesDictionary();
                    var role = rolesDict.ContainsKey(user.IdRol) ? rolesDict[user.IdRol] : "User";
                    
                    var token = jwtService.GenerateToken(
                        user.IdUtilizator,
                        user.Mail ?? "",
                        $"{user.Nume} {user.Prenume}",
                        role
                    );

                    return Ok(new
                    {
                        status = "success",
                        accessToken = token,
                        expiresInSeconds = 3600 * 24,
                        user = new
                        {
                            id = user.IdUtilizator,
                            email = user.Mail,
                            name = $"{user.Nume} {user.Prenume}",
                            phone = user.NumarTelefon,
                            role = role
                        }
                    });
                }

                return Ok(new
                {
                    status = "success",
                    message = result.Message
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        private byte[]? ComputeDeviceHash()
        {
            // Simple device fingerprinting from User-Agent
            var userAgent = HttpContext.Request.Headers["User-Agent"].ToString();
            if (string.IsNullOrEmpty(userAgent))
                return null;

            using var sha256 = System.Security.Cryptography.SHA256.Create();
            return sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(userAgent));
        }
    }

    public class OtpRequestModel
    {
        public string Phone { get; set; } = null!;
        public string Purpose { get; set; } = null!; // LOGIN_SMS, SIGN_SMS, EMAIL_VERIFY, STEP_UP_SECURITY
        public string? Channel { get; set; } = "sms"; // sms, email
        public int? UserId { get; set; }
    }

    public class OtpVerifyModel
    {
        public Guid OtpId { get; set; }
        public string Code { get; set; } = null!;
        public string Phone { get; set; } = null!;
        public string Purpose { get; set; } = null!;
    }
}
