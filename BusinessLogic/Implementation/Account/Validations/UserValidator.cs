using ProjectOnProjects.BusinessLogic.Implementation.Account.Models;
using ProjectOnProjects.DataAccess;
using FluentValidation;
using ProjectOnProjects.BusinessLogic.Implementation.Account.Models;
using ProjectOnProjects.DataAccess;

namespace ProjectOnProjects.BusinessLogic.Implementation.Account
{
    public class UserValidator : AbstractValidator<UserModelEdit>
    {
        private UnitOfWork _unitOfWork;
        public UserValidator(UnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
            RuleFor(r => r.FirstName)
                .NotEmpty().WithMessage("Camp obligatoriu!")
                .Length(3, 20).WithMessage("First Name must have atleast 3 letters and max 20 letters");
            RuleFor(r => r.LastName)
                .NotEmpty().WithMessage("Camp obligatoriu!")
                .Length(3, 20).WithMessage("Last Name must have atleast 3 letters and max 20 letters");
        }
        private bool BeAtLeastThirdteenYearsAgo(DateTime birthDay)
        {
            var today = DateTime.Today;
            var age = today.Year - birthDay.Year;

            if (birthDay > today.AddYears(-age))
            {
                age--;
            }

            return age >= 16;
        }
    }
}
