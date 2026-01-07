using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Account;
using MoneyShop.BusinessLogic.Implementation.Account.Models;
using MoneyShop.BusinessLogic.Implementation.Auth;
using MoneyShop.Services;
using MoneyShop.Common.DTOs;
using MoneyShop.DataAccess;
using System.Security.Claims;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AccountService _accountService;
        private readonly JwtService _jwtService;
        private readonly UnitOfWork _unitOfWork;
        private readonly OtpService _otpService;

        public AuthController(AccountService accountService, JwtService jwtService, UnitOfWork unitOfWork, OtpService otpService)
        {
            _accountService = accountService;
            _jwtService = jwtService;
            _unitOfWork = unitOfWork;
            _otpService = otpService;
        }

        /// <summary>
        /// Register a new user
        /// </summary>
        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterModel model)
        {
            if (model == null || !ModelState.IsValid)
            {
                return BadRequest(new { message = "Invalid registration data", errors = ModelState });
            }

            try
            {
                _accountService.RegisterNewUser(model);
                
                // Auto-login after registration
                var user = _accountService.Login(model.Email, model.Password);
                
                if (!user.IsAuthenticated)
                {
                    return BadRequest(new { message = "Registration successful but login failed" });
                }

                var token = _jwtService.GenerateToken(user.Id, user.Email, user.FirstName, user.Role);

                return Ok(new
                {
                    status = "success",
                    user_id = user.Id,
                    token = token,
                    user = new
                    {
                        id = user.Id,
                        email = user.Email,
                        name = user.FirstName,
                        role = user.Role
                    }
                });
            }
            catch (Microsoft.Data.SqlClient.SqlException sqlEx)
            {
                // SQL Server specific errors
                return StatusCode(500, new { 
                    message = "Database error occurred",
                    error = sqlEx.Message,
                    errorNumber = sqlEx.Number,
                    state = sqlEx.State,
                    server = sqlEx.Server,
                    suggestion = sqlEx.Number == 4060 ? "Database name might be incorrect. Check if 'moneyshop' database exists." :
                                  sqlEx.Number == 18456 ? "Login failed. Check username and password in connection string." :
                                  sqlEx.Number == 2 ? "Cannot connect to server. Check Azure SQL firewall settings and network connectivity." :
                                  "Check Azure SQL Database configuration and firewall settings."
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { 
                    message = ex.Message,
                    errorType = ex.GetType().Name,
                    innerException = ex.InnerException?.Message
                });
            }
        }

        /// <summary>
        /// Login with email and password
        /// </summary>
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginModel model)
        {
            if (model == null || string.IsNullOrEmpty(model.Email) || string.IsNullOrEmpty(model.Password))
            {
                return BadRequest(new { message = "Email and password are required" });
            }

            var user = _accountService.Login(model.Email, model.Password);

            if (!user.IsAuthenticated)
            {
                return Unauthorized(new { message = "Invalid email or password" });
            }

            var token = _jwtService.GenerateToken(user.Id, user.Email, user.FirstName, user.Role);

            return Ok(new
            {
                status = "success",
                user_id = user.Id,
                token = token,
                user = new
                {
                    id = user.Id,
                    email = user.Email,
                    name = user.FirstName,
                    role = user.Role
                }
            });
        }

        /// <summary>
        /// Get current user info (requires authentication)
        /// </summary>
        [HttpGet("me")]
        [Microsoft.AspNetCore.Authorization.Authorize]
        public IActionResult GetCurrentUser()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            // Get user directly from database
            var user = _unitOfWork.Users.Get().FirstOrDefault(u => u.IdUtilizator == userId);
            
            if (user == null)
            {
                return NotFound(new { message = "User not found" });
            }

            var userRoles = new UserRoles();
            var rolesDict = userRoles.CreateUserRolesDictionary();

            return Ok(new
            {
                id = user.IdUtilizator,
                email = user.Mail,
                name = $"{user.Nume} {user.Prenume}",
                role = rolesDict.ContainsKey(user.IdRol) ? rolesDict[user.IdRol] : "User"
            });
        }

        /// <summary>
        /// Send verification code to email
        /// </summary>
        [HttpPost("send-email-verification")]
        [Microsoft.AspNetCore.Authorization.Authorize]
        public IActionResult SendEmailVerification([FromBody] SendVerificationRequest request)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                {
                    return Unauthorized(new { message = "Invalid token" });
                }

                var user = _unitOfWork.Users.Get().FirstOrDefault(u => u.IdUtilizator == userId);
                if (user == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                var email = request.Email ?? user.Mail;
                if (string.IsNullOrEmpty(email))
                {
                    return BadRequest(new { message = "Email is required" });
                }

                var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
                var result = _otpService.RequestOtp(email, "EMAIL_VERIFY", userId, ip, null, "email");

                return Ok(new
                {
                    success = true,
                    message = "Verification code sent to email",
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
        /// Send verification code to phone via SMS
        /// </summary>
        [HttpPost("send-phone-verification")]
        [Microsoft.AspNetCore.Authorization.Authorize]
        public IActionResult SendPhoneVerification([FromBody] SendVerificationRequest request)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                {
                    return Unauthorized(new { message = "Invalid token" });
                }

                var user = _unitOfWork.Users.Get().FirstOrDefault(u => u.IdUtilizator == userId);
                if (user == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                var phone = request.Phone ?? user.NumarTelefon;
                if (string.IsNullOrEmpty(phone))
                {
                    return BadRequest(new { message = "Phone number is required" });
                }

                var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
                var result = _otpService.RequestOtp(phone, "PHONE_VERIFY", userId, ip, null, "sms");

                return Ok(new
                {
                    success = true,
                    message = "Verification code sent to phone",
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
        /// Verify email code
        /// </summary>
        [HttpPost("verify-email")]
        [Microsoft.AspNetCore.Authorization.Authorize]
        public IActionResult VerifyEmail([FromBody] VerifyCodeRequest request)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                {
                    return Unauthorized(new { message = "Invalid token" });
                }

                var user = _unitOfWork.Users.Get().FirstOrDefault(u => u.IdUtilizator == userId);
                if (user == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                var email = request.Email ?? user.Mail;
                if (string.IsNullOrEmpty(email))
                {
                    return BadRequest(new { message = "Email is required" });
                }

                var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
                var result = _otpService.VerifyOtp(request.OtpId, email, "EMAIL_VERIFY", request.Code, ip);

                if (!result.IsValid)
                {
                    return BadRequest(new { message = result.Message });
                }

                // Update user email verification status
                user.EmailVerified = true;
                if (!string.IsNullOrEmpty(request.Email) && request.Email != user.Mail)
                {
                    user.Mail = request.Email;
                }
                _unitOfWork.Users.Update(user);
                _unitOfWork.SaveChanges();

                return Ok(new
                {
                    success = true,
                    message = "Email verified successfully"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Verify phone code
        /// </summary>
        [HttpPost("verify-phone")]
        [Microsoft.AspNetCore.Authorization.Authorize]
        public IActionResult VerifyPhone([FromBody] VerifyCodeRequest request)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                {
                    return Unauthorized(new { message = "Invalid token" });
                }

                var user = _unitOfWork.Users.Get().FirstOrDefault(u => u.IdUtilizator == userId);
                if (user == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                var phone = request.Phone ?? user.NumarTelefon;
                if (string.IsNullOrEmpty(phone))
                {
                    return BadRequest(new { message = "Phone number is required" });
                }

                var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
                var result = _otpService.VerifyOtp(request.OtpId, phone, "PHONE_VERIFY", request.Code, ip);

                if (!result.IsValid)
                {
                    return BadRequest(new { message = result.Message });
                }

                // Update user phone verification status
                user.PhoneVerified = true;
                if (!string.IsNullOrEmpty(request.Phone) && request.Phone != user.NumarTelefon)
                {
                    user.NumarTelefon = request.Phone;
                }
                _unitOfWork.Users.Update(user);
                _unitOfWork.SaveChanges();

                return Ok(new
                {
                    success = true,
                    message = "Phone verified successfully"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }

    public class SendVerificationRequest
    {
        public string? Email { get; set; }
        public string? Phone { get; set; }
    }

    public class VerifyCodeRequest
    {
        public Guid OtpId { get; set; }
        public string Code { get; set; } = null!;
        public string? Email { get; set; }
        public string? Phone { get; set; }
    }
}

