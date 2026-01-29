using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography;
using System.Text.Json;
using MoneyShop.Entities.Entities;
using AutoMapper;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.BusinessLogic.Implementation.Account.Models;
using MoneyShop.Common.DTOs;
using MoneyShop.Common.Extensions;
using MoneyShop.DataAccess;
using MoneyShop.Models;
using ConsentEntity = MoneyShop.Entities.Entities.Consent;
using MandateEntity = MoneyShop.Entities.Entities.Mandate;

namespace MoneyShop.BusinessLogic.Implementation.Account
{
    public class AccountService : BaseService
    {
        public static bool VerifyPassword(string enteredPassword, string hashedPassword)
        {
            string enteredPasswordHash = HashPassword(enteredPassword);
            return enteredPasswordHash == hashedPassword;
        }

        public static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(hashedBytes);
            }
        }

        private readonly UserValidator UserValidator;
        //private readonly MailService _mailService;
        private readonly RegisterUserValidator RegisterUserValidator;

        public AccountService(ServiceDependencies dependencies /*MailService mailService*/)
            : base(dependencies)
        {
            this.RegisterUserValidator = new RegisterUserValidator();
            this.UserValidator = new UserValidator(dependencies.UnitOfWork);
            //_mailService = mailService;
        }

        public CurrentUserDto Login(string email, string password)
        {
            UserRoles users = new UserRoles();
            Dictionary<int, string> userRoles = users.CreateUserRolesDictionary();
            var user = UnitOfWork.Users.Get()
                .FirstOrDefault(u => u.Mail == email);

            if (user == null)
            {
                return new CurrentUserDto { IsAuthenticated = false };
            }

            var storedHashedPassword = user.Parola;
            bool isAuthenticated = VerifyPassword(password, storedHashedPassword);

            if (isAuthenticated)
            {
                // Safely get role, default to "Utilizator" if role not found
                string role = userRoles.ContainsKey(user.IdRol) ? userRoles[user.IdRol] : "Utilizator";
                
                return new CurrentUserDto
                {
                    Id = user.IdUtilizator,
                    Email = user.Mail,
                    FirstName = user.Nume + " " + user.Prenume,
                    IsAuthenticated = true,
                    Role = role
                };
            }
            else
                return new CurrentUserDto { IsAuthenticated = false };
        }

        public void RegisterNewUser(RegisterModel model)
        {
            RegisterUserValidator.Validate(model).ThenThrow(model);

            var user = Mapper.Map<RegisterModel, Utilizatori>(model);
            user.Mail = model.Email;
            user.NumarTelefon = model.Phone;
            user.Username = model.FirstName + model.LastName;
            user.Parola = HashPassword(user.Parola);
            
            // Set default role to 1 (Utilizator) if Role is 0 or not provided
            // First, verify that role 1 exists in the database
            var roleExists = UnitOfWork.Roles.Get().Any(r => r.IdRol == 1);
            if (!roleExists)
            {
                // If role 1 doesn't exist, try to find the first available role
                var firstRole = UnitOfWork.Roles.Get().OrderBy(r => r.IdRol).FirstOrDefault();
                if (firstRole != null)
                {
                    user.IdRol = firstRole.IdRol;
                }
                else
                {
                    throw new Exception("No roles found in database. Please run PopulateRoles.sql script first.");
                }
            }
            else
            {
                user.IdRol = model.Role > 0 ? model.Role : 1;
            }
            
            user.IsDeleted = false;
            user.DataIncepere = DateTime.UtcNow;
            
            // Set email and phone verification to false (will be verified via OTP)
            user.EmailVerified = false;
            user.PhoneVerified = false;

            UnitOfWork.Users.Insert(user);
            UnitOfWork.SaveChanges();
            
            // Save consents and mandates
            SaveUserConsentsAndMandates(user.IdUtilizator, model);
        }
        
        private void SaveUserConsentsAndMandates(int userId, RegisterModel model)
        {
            var now = DateTime.UtcNow;
            var sourceChannel = "web";
            var deviceHashBytes = !string.IsNullOrEmpty(model.DeviceHash) 
                ? Encoding.UTF8.GetBytes(model.DeviceHash) 
                : null;
            
            // 1. Terms & Conditions consent
            if (model.AcceptTerms)
            {
                var termsConsent = new ConsentEntity
                {
                    ConsentId = Guid.NewGuid(),
                    UserId = userId,
                    ConsentType = "TC_ACCEPT",
                    Status = "granted",
                    GrantedAt = now,
                    ConsentTextSnapshot = "Accept Termenii și Condițiile de utilizare a platformei MoneyShop.",
                    Ip = model.IpAddress,
                    UserAgent = model.UserAgent,
                    DeviceHash = deviceHashBytes,
                    SourceChannel = sourceChannel
                };
                UnitOfWork.Consents.Insert(termsConsent);
            }
            
            // 2. GDPR consent
            if (model.AcceptGdpr)
            {
                var gdprConsent = new ConsentEntity
                {
                    ConsentId = Guid.NewGuid(),
                    UserId = userId,
                    ConsentType = "GDPR_ACCEPT",
                    Status = "granted",
                    GrantedAt = now,
                    ConsentTextSnapshot = "Am citit și înțeleg cum sunt prelucrate datele mele personale conform GDPR.",
                    Ip = model.IpAddress,
                    UserAgent = model.UserAgent,
                    DeviceHash = deviceHashBytes,
                    SourceChannel = sourceChannel
                };
                UnitOfWork.Consents.Insert(gdprConsent);
            }
            
            // 3. Costs consent
            if (model.AcceptCosts)
            {
                var costsConsent = new ConsentEntity
                {
                    ConsentId = Guid.NewGuid(),
                    UserId = userId,
                    ConsentType = "COSTS_ACCEPT",
                    Status = "granted",
                    GrantedAt = now,
                    ConsentTextSnapshot = "Confirm că am luat la cunoștință că serviciile MoneyShop sunt gratuite pentru utilizatori.",
                    Ip = model.IpAddress,
                    UserAgent = model.UserAgent,
                    DeviceHash = deviceHashBytes,
                    SourceChannel = sourceChannel
                };
                UnitOfWork.Consents.Insert(costsConsent);
            }
            
            // 4. ANAF Mandate
            if (model.MandateAnaf)
            {
                var anafMandate = new MandateEntity
                {
                    MandateId = Guid.NewGuid(),
                    UserId = userId,
                    MandateType = "ANAF",
                    Scope = "credit_eligibility_only",
                    Status = "active",
                    GrantedAt = now,
                    ExpiresAt = now.AddDays(30)
                };
                UnitOfWork.Mandates.Insert(anafMandate);
                
                // Also create the consent record for audit
                var anafConsent = new ConsentEntity
                {
                    ConsentId = Guid.NewGuid(),
                    UserId = userId,
                    ConsentType = "MANDATE_ANAF",
                    Status = "granted",
                    GrantedAt = now,
                    ConsentTextSnapshot = "Împuternicesc MoneyShop să interogheze ANAF pentru verificarea veniturilor mele în scopul determinării eligibilității pentru credite. Valabilitate: 30 de zile.",
                    Ip = model.IpAddress,
                    UserAgent = model.UserAgent,
                    DeviceHash = deviceHashBytes,
                    SourceChannel = sourceChannel
                };
                UnitOfWork.Consents.Insert(anafConsent);
            }
            
            // 5. Birou Credit Mandate (optional)
            if (model.MandateBiroCredit)
            {
                var bcMandate = new MandateEntity
                {
                    MandateId = Guid.NewGuid(),
                    UserId = userId,
                    MandateType = "BC",
                    Scope = "credit_eligibility_only",
                    Status = "active",
                    GrantedAt = now,
                    ExpiresAt = now.AddDays(30)
                };
                UnitOfWork.Mandates.Insert(bcMandate);
                
                // Also create the consent record for audit
                var bcConsent = new ConsentEntity
                {
                    ConsentId = Guid.NewGuid(),
                    UserId = userId,
                    ConsentType = "MANDATE_BC",
                    Status = "granted",
                    GrantedAt = now,
                    ConsentTextSnapshot = "Împuternicesc MoneyShop să interogheze Biroul de Credit pentru o analiză completă a eligibilității mele. Valabilitate: 30 de zile.",
                    Ip = model.IpAddress,
                    UserAgent = model.UserAgent,
                    DeviceHash = deviceHashBytes,
                    SourceChannel = sourceChannel
                };
                UnitOfWork.Consents.Insert(bcConsent);
            }
            
            // 6. Share to Broker (optional, default OFF)
            if (model.ShareToBroker)
            {
                var brokerConsent = new ConsentEntity
                {
                    ConsentId = Guid.NewGuid(),
                    UserId = userId,
                    ConsentType = "SHARE_TO_BROKER",
                    Status = "granted",
                    GrantedAt = now,
                    ConsentTextSnapshot = "Accept ca datele mele să fie transmise brokerilor parteneri MoneyShop pentru a primi oferte personalizate.",
                    Ip = model.IpAddress,
                    UserAgent = model.UserAgent,
                    DeviceHash = deviceHashBytes,
                    SourceChannel = sourceChannel
                };
                UnitOfWork.Consents.Insert(brokerConsent);
            }
            
            UnitOfWork.SaveChanges();
        }

        public List<ListItemModel<string, int>> GetUsers()
        {
            return UnitOfWork.Users.Get()
                .Select(u => new ListItemModel<string, int>
                {
                    Text = $"{u.Nume} {u.Prenume}",
                    Value = u.IdUtilizator
                })
                .ToList();
        }

        public bool SendMailResetPassword(string email)
        {
            string emailSubject = "Reset Password";
            var randomString = GenerateRandomString(8);
            string emailBody = $"Your reset code is {randomString}. It is available for only 1 hour so hurry up!";

            //_mailService.SendNotificationEmail(email, emailSubject, emailBody);
            var user = UnitOfWork.Users.Get().Where(u => u.Mail == email).FirstOrDefault();
            //var lastRecovery = UnitOfWork.PasswordRecoveries.Get().Include(l => l.User).Where(l => l.User.Mail == email && l.IsAvailable == true).FirstOrDefault();
            //var passRecovery = new PasswordRecovery();
            //passRecovery.IsAvailable = true;
            //passRecovery.Date = DateTime.Now;
            //passRecovery.UserId = user.IdUtilizator;
            //passRecovery.Code = randomString;
            //passRecovery.Id = Guid.NewGuid();
            //if (lastRecovery != null)
            //{
            //    lastRecovery.IsAvailable = false;
            //    UnitOfWork.PasswordRecoveries.Update(lastRecovery);
            //}
            //UnitOfWork.PasswordRecoveries.Insert(passRecovery);
            UnitOfWork.SaveChanges();
            return true;
        }

        //public bool ValidateCode(string email, string code)
        //{
        //    var lastRec = UnitOfWork.PasswordRecoveries.Get()
        //        .Include(p => p.User)
        //        .Where(p => p.User.Mail == email && p.IsAvailable == true)
        //        .FirstOrDefault();
        //    if (lastRec != null)
        //    {
        //        if (lastRec.Date < DateTime.Now.AddHours(-1))
        //        {
        //            lastRec.IsAvailable = false;
        //        }
        //        if (lastRec.IsAvailable)
        //        {
        //            if (lastRec.Code == code)
        //            {
        //                return true;
        //            }
        //            return false;
        //        }
        //        return false;
        //    }
        //    return false;
        //}
        //public bool ValidatePassword(ValidatePasswordModel model)
        //{
        //    if (model.NewPassword == model.ConfirmPassword)
        //    {
        //        var user = UnitOfWork.Users.Get().Where(u => u.Mail == model.Email).FirstOrDefault();
        //        user.Parola = HashPassword(model.NewPassword);
        //        UnitOfWork.Users.Update(user);
        //        var lastRec = UnitOfWork.PasswordRecoveries.Get().Where(p => p.User.Mail == model.Email && p.IsAvailable == true).FirstOrDefault();
        //        if (lastRec != null)
        //        {
        //            lastRec.IsAvailable = false;
        //            UnitOfWork.PasswordRecoveries.Update(lastRec);
        //        }
        //        UnitOfWork.SaveChanges();
        //        return true;
        //    }
        //    else
        //        return false;
        //}
        public UserProfileModel DisplayProfile()
        {
            var user = UnitOfWork.Users.Get().FirstOrDefault(u => u.IdUtilizator == CurrentUser.Id);
            return new UserProfileModel
            {
                Skills = user.Skills?.Split(',') ?? new string[0],
                Description = user.Description,
                DataIncepere = user.DataIncepere
            };
        }

        public UserModelEdit GetUserById()
        {
            UserRoles usersList = new UserRoles();
            Dictionary<int, string> userRoles = usersList.CreateUserRolesDictionary();
            var user = UnitOfWork.Users.Get().Where(u => u.IdUtilizator == CurrentUser.Id).FirstOrDefault();
            var userModelEdit = Mapper.Map<Utilizatori, UserModelEdit>(user);
            userModelEdit.Roles = userRoles;
            return userModelEdit;
        }

        public void UpdateProfilePicture(int userId, byte[] profilePicture)
        {
            var user = UnitOfWork.Users.Get().FirstOrDefault(u => u.IdUtilizator == userId);
            if (user != null)
            {
                UnitOfWork.Users.Update(user);
                UnitOfWork.SaveChanges();
            }
        }
        public CurrentUserDto UpdateUser(UserModelEdit model)
        {
            UserValidator.Validate(model).ThenThrow(model);

            UserRoles usersList = new UserRoles();
            Dictionary<int, string> userRoles = usersList.CreateUserRolesDictionary();
            var user = UnitOfWork.Users.Get().Where(u => u.IdUtilizator == CurrentUser.Id).FirstOrDefault();
            user.DataNastere = model.BirthDay;
            user.Nume = model.FirstName;
            user.Prenume = model.LastName;
            UnitOfWork.Users.Update(user);
            UnitOfWork.SaveChanges();
            // Safely get role, default to "Utilizator" if role not found
            string role = userRoles.ContainsKey(user.IdRol) ? userRoles[user.IdRol] : "Utilizator";
            
            return new CurrentUserDto()
            {
                Email = user.Mail,
                Id = user.IdUtilizator,
                FirstName = user.Nume,
                LastName = user.Prenume,
                IsAuthenticated = true,
                Role = role
            };
        }

        public void SaveProfile(int userId, string skills, string description)
        {
            var user = UnitOfWork.Users.Get().FirstOrDefault(u => u.IdUtilizator == userId);
            if (user != null)
            {
                user.Skills = skills;
                user.Description = description;
                UnitOfWork.Users.Update(user);
                UnitOfWork.SaveChanges();
            }
        }

        static string GenerateRandomString(int length)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            Random random = new Random();
            return new string(Enumerable.Repeat(chars, length)
                .Select(s => s[random.Next(s.Length)]).ToArray());
        }

        public void AddProjectToFavorites(int userId, int projectId, string listName)
        {


            var favorite = new Favorites { ProjectId = projectId, UserId = userId, ListName = listName};
            UnitOfWork.Favorites.Insert(favorite);
            UnitOfWork.SaveChanges();
        }

        public List<FavoriteListModels> GetFavoriteLists(int userId)
        {
            return UnitOfWork.Favorites.Get()
                .Where(fl => fl.UserId == userId)
                .GroupBy(fl => fl.ListName)
                .Select(g => new FavoriteListModels
                {
                    ListName = g.Key,
                    Projects = g.Select(f => f.Project).ToList()
                })
                .ToList();
        }
    }
}
