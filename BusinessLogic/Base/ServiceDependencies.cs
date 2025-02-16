
using ProjectOnProjects.Common.DTOs;
using ProjectOnProjects.DataAccess;
using AutoMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectOnProjects.BusinessLogic.Base
{
    public class ServiceDependencies
    {
        public IMapper Mapper { get; set; }
        public UnitOfWork UnitOfWork { get; set; }
        public CurrentUserDto CurrentUser { get; set; }

        public ServiceDependencies(IMapper mapper, UnitOfWork unitOfWork, CurrentUserDto currentUser)
        {
            Mapper = mapper;
            UnitOfWork = unitOfWork;
            CurrentUser = currentUser;
        }
    }
}
