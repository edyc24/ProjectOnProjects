using iText.Kernel.Pdf.Canvas.Parser.ClipperLib;
using System;

namespace MoneyShop.BusinessLogic.Implementation.Account
{
    public class RegisterModel
    {
        public string Email { get; set; }
        public string Password { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int Role { get; set; }
    }
}
