using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Account;
using MoneyShop.Common.DTOs;
using MoneyShop.WebApp.Code.Base;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using MoneyShop.Code.Base;
using Microsoft.AspNetCore.Authorization;
using MoneyShop.BusinessLogic.Implementation.Account.Models;
using MoneyShop.Entities.Entities;

namespace MoneyShop.WebApp.Controllers
{
    public class AccountController : BaseController
    {
        private readonly AccountService Service;

        public AccountController(ControllerDependencies dependencies, AccountService service)
           : base(dependencies)
        {
            this.Service = service;
        }

        [HttpGet]
        public IActionResult Register()
        {
            var model = new RegisterModel();

            return View("Register", model);
        }

        [HttpPost]
        public IActionResult Register(RegisterModel model)
        {
            if (model == null)
            {
                return View("Error_NotFound");
            }

            // Capture IP and UserAgent for audit
            model.IpAddress = HttpContext.Connection.RemoteIpAddress?.ToString();
            model.UserAgent = HttpContext.Request.Headers["User-Agent"].ToString();

            Service.RegisterNewUser(model);

            // After registration, redirect to OTP verification if phone provided
            if (!string.IsNullOrEmpty(model.Phone))
            {
                // Request OTP for phone verification
                var otpService = HttpContext.RequestServices.GetService<MoneyShop.BusinessLogic.Implementation.Auth.OtpService>();
                if (otpService != null)
                {
                    try
                    {
                        var result = otpService.RequestOtp(
                            model.Phone,
                            "PHONE_VERIFY",
                            null,
                            model.IpAddress,
                            null
                        );

                        return RedirectToAction("VerifyOtp", new { 
                            otpId = result.OtpId, 
                            phone = model.Phone, 
                            purpose = "PHONE_VERIFY",
                            expires = result.ExpiresInSeconds,
                            redirect = "/Account/Login"
                        });
                    }
                    catch
                    {
                        // If OTP fails, just redirect to login
                    }
                }
            }

            return RedirectToAction("Login");
        }
        
        [HttpGet]
        public IActionResult VerifyOtp(Guid otpId, string phone, string purpose, int expires = 300, string redirect = "/")
        {
            ViewBag.OtpId = otpId;
            ViewBag.Phone = phone;
            ViewBag.Purpose = purpose;
            ViewBag.Expires = expires;
            ViewBag.Redirect = redirect;
            return View();
        }

        [HttpGet]
        public IActionResult Login()
        {
            var model = new LoginModel();

            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Login(LoginModel model)
        {
            var user = Service.Login(model.Email, model.Password);

            if (!user.IsAuthenticated)
            {
                model.AreCredentialsInvalid = true;
                return View(model);
            }

            await LogIn(user);

            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public async Task<IActionResult> Logout()
        {
            await LogOut();

            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public IActionResult DemoPage()
        {
            var model = Service.GetUsers();

            return View(model);
        }

        [HttpGet]
        public IActionResult ResetPassword()
        {
            return View();
        }

        [HttpPost]
        public JsonResult ResetPassword([FromQuery] string email)
        {
            return Json(Service.SendMailResetPassword(email));
        }

        [HttpGet]
        public IActionResult CreateNewPassword()
        {
            return View();
        }

        //[HttpPost]
        //public IActionResult CreateNewPassword([FromQuery] string email, [FromQuery] string code)
        //{
        //    return Ok(Service.ValidateCode(email, code));
        //}

        //[HttpPost]
        //public IActionResult ValidatePassword([FromQuery] ValidatePasswordModel model)
        //{
        //    return Json(Service.ValidatePassword(model));
        //}

        [Authorize]
        public IActionResult ProfilePage()
        {
            var currentUserDetails = Service.DisplayProfile();
            return View(currentUserDetails);
        }

        public IActionResult Edit()
        {
            var user = Service.GetUserById();
            return View(user);
        }
        [HttpPost]
        public async Task<IActionResult> UploadProfilePicture(IFormFile ProfilePicture)
        {
            if (ProfilePicture != null && ProfilePicture.Length > 0)
            {
                using (var memoryStream = new MemoryStream())
                {
                    await ProfilePicture.CopyToAsync(memoryStream);
                    var userId = Service.GetUserById().Id; 
                    Service.UpdateProfilePicture(userId, memoryStream.ToArray());
                }
            }

            return RedirectToAction("ProfilePage");
        }

        [HttpGet]
        public IActionResult Test()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Edit(UserModelEdit userModelEdit)
        {
            var user = new CurrentUserDto();

            user = Service.UpdateUser(userModelEdit);
            await LogOut();
            await LogIn(user);
            return RedirectToAction("ProfilePage");
        }

        [HttpPost]
        public IActionResult SaveProfile(string[] skills, string description)
        {
            var skillsString = string.Join(",", skills);
            Service.SaveProfile(CurrentUser.Id, skillsString, description);
            return RedirectToAction("ProfilePage");
        }

        [HttpPost]
        public IActionResult AddToFavoriteList([FromBody] FavoriteRequest request)
        {
            if (request == null || request.ProjectId == 0 || string.IsNullOrEmpty(request.ListName))
            {
                return BadRequest("Invalid data.");
            }

            Service.AddProjectToFavorites(CurrentUser.Id, request.ProjectId, request.ListName);
            return Ok();
        }

        public class FavoriteRequest
        {
            public int ProjectId { get; set; }
            public string ListName { get; set; }
        }

        [HttpGet]
        public IActionResult FavoriteLists()
        {
            var favoriteLists = Service.GetFavoriteLists(CurrentUser.Id);
            return View(favoriteLists);
        }

        private async Task LogIn(CurrentUserDto user)
        {
            var claims = new List<Claim>
            {
                new Claim("Id", user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.FirstName),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role),
            };

            var identity = new ClaimsIdentity(claims, "Cookies");
            var principal = new ClaimsPrincipal(identity);

            await HttpContext.SignInAsync(
                    scheme: "MoneyShopCookies",
                    principal: principal);
        }
        private async Task LogOut()
        {
            await HttpContext.SignOutAsync(scheme: "MoneyShopCookies");
        }
    }
}