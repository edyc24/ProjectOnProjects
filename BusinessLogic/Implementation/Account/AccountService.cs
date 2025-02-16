using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography;
using System.Text.Json;
using ProjectOnProjects.Entities.Entities;
using AutoMapper;
using ProjectOnProjects.BusinessLogic.Base;
using ProjectOnProjects.BusinessLogic.Implementation.Account.Models;
using ProjectOnProjects.Common.DTOs;
using ProjectOnProjects.Common.Extensions;
using ProjectOnProjects.DataAccess;
using ProjectOnProjects.Entities.Entities;
using ProjectOnProjects.Models;

namespace ProjectOnProjects.BusinessLogic.Implementation.Account
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
                return new CurrentUserDto
                {
                    Id = user.IdUtilizator,
                    Email = user.Mail,
                    FirstName = user.Nume + " " + user.Prenume,
                    IsAuthenticated = true,
                    Role = userRoles[user.IdRol]
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
            user.Username = model.FirstName + model.LastName;
            user.Parola = HashPassword(user.Parola);
            user.IdRol = model.Role;
            user.IsDeleted = false;

            UnitOfWork.Users.Insert(user);

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
        public UserModel DisplayProfile()
        {
            UserRoles users = new UserRoles();
            Dictionary<int, string> userRoles = users.CreateUserRolesDictionary();
            var user = UnitOfWork.Users.Where(u => u.IdUtilizator == CurrentUser.Id).SingleOrDefault();
            var userProfile = Mapper.Map<Utilizatori, UserModel>(user);
            return userProfile;
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
            return new CurrentUserDto()
            {
                Email = user.Mail,
                Id = user.IdUtilizator,
                FirstName = user.Nume,
                LastName = user.Prenume,
                IsAuthenticated = true,
                Role = userRoles[user.IdRol]
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
            var favoriteList = UnitOfWork.Favorites.Get()
                .FirstOrDefault(fl => fl.UserId == userId && fl.ListName == listName);

            if (favoriteList == null)
            {
                favoriteList = new Favorites { UserId = userId, ListName = listName };
                UnitOfWork.Favorites.Insert(favoriteList);
            }

            var favorite = new Favorites { ProjectId = projectId, Id = favoriteList.Id };
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
