using MoneyShop.BusinessLogic.Implementation.ProjectService.Models;
using MoneyShop.Entities.Entities;
using System.Collections.Generic;

namespace MoneyShop.Models
{
    public class FavoriteListModels
    {
        public string ListName { get; set; }
        public List<Proiecte> Projects { get; set; }
    }
} 