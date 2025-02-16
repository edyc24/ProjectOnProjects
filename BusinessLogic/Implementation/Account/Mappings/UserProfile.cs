using ProjectOnProjects.BusinessLogic.Implementation.Account.Models;
using ProjectOnProjects.BusinessLogic.Implementation.Account;
using AutoMapper;
using System;
using ProjectOnProjects.Entities.Entities;

namespace ProjectOnProjects.BusinessLogic.Implementation.Account
{
    public class UserProfile : Profile
    {
        public Dictionary<int, string> userRoles { get; set; }
        public UserProfile()
        {

            UserRoles usersList = new UserRoles();
            this.userRoles = usersList.CreateUserRolesDictionary();

            CreateMap<RegisterModel, Utilizatori>()
                .ForMember(a => a.Parola, a => a.MapFrom(s => s.Password))
                .ForMember(a => a.Prenume, a => a.MapFrom(s => s.LastName))
                .ForMember(a => a.Nume, a => a.MapFrom(s => s.FirstName))
                .ForMember(a => a.Mail, a => a.MapFrom(s => s.Email));

            CreateMap<Utilizatori, UserModel>()
                .ForMember(a => a.Id, a => a.MapFrom(s => s.IdUtilizator))
                .ForMember(a => a.BirthDay, a => a.MapFrom(s => s.DataNastere))
                .ForMember(a => a.RegistrationDay, a => a.MapFrom(s => s.DataIncepere))
                .ForMember(a => a.Email, a => a.MapFrom(s => s.Mail))
                .ForMember(a => a.Role, a => a.MapFrom(s => userRoles[s.IdRol]))
                .ForMember(a => a.FirstName, a => a.MapFrom(s => s.Nume))
                .ForMember(a => a.LastName, a => a.MapFrom(s => s.Prenume));

            CreateMap<UserModel, Utilizatori>()
                .ForMember(a => a.DataNastere, a => a.MapFrom(s => s.BirthDay))
                .ForMember(a => a.IdRol, a => a.MapFrom(s => userRoles.FirstOrDefault(role => role.Value == s.Role).Key))
                .ForMember(a => a.Nume, a => a.MapFrom(s => s.FirstName))
                .ForMember(a => a.Prenume, a => a.MapFrom(s => s.LastName))
                .ForMember(a => a.Mail, a => a.MapFrom(s => s.Email))
                .ForMember(a => a.Parola, a => a.Ignore())
                .ForMember(a => a.IdUtilizator, a => a.MapFrom(s => s.Id))
                .ForMember(a => a.DataIncepere, a => a.MapFrom(s => s.RegistrationDay));


            CreateMap<Utilizatori, UserModelEdit>()
               .ForMember(a => a.Id, a => a.MapFrom(s => s.IdUtilizator))
               .ForMember(a => a.BirthDay, a => a.MapFrom(s => s.DataNastere))
               .ForMember(a => a.Email, a => a.MapFrom(s => s.Mail))
               .ForMember(a => a.FirstName, a => a.MapFrom(s => s.Nume))
               .ForMember(a => a.LastName, a => a.MapFrom(s => s.Prenume));

            CreateMap<UserModelEdit, Utilizatori>()
                .ForMember(a => a.DataNastere, a => a.MapFrom(s => s.BirthDay))
                .ForMember(a => a.Nume, a => a.MapFrom(s => s.FirstName))
                .ForMember(a => a.Prenume, a => a.MapFrom(s => s.LastName))
                .ForMember(a => a.Mail, a => a.MapFrom(s => s.Email))
                .ForMember(a => a.Parola, a => a.Ignore());
        }
    }
}

