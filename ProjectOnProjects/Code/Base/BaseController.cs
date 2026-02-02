using MoneyShop.Code.Base;
using MoneyShop.Common.DTOs;
using Microsoft.AspNetCore.Mvc;

namespace MoneyShop.WebApp.Code.Base
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
