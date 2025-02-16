using ProjectOnProjects.Code.Base;
using ProjectOnProjects.Common.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace ProjectOnProjects.WebApp.Code.Base
{
    public class BaseController : Controller
    {
        protected readonly CurrentUserDto CurrentUser;

        public BaseController(ControllerDependencies dependencies)
            : base()
        {
            CurrentUser = dependencies.CurrentUser;
        }
    }
}
