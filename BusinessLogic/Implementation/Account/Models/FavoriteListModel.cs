using ProjectOnProjects.BusinessLogic.Implementation.ProjectService.Models;
using ProjectOnProjects.Entities.Entities;
using System.Collections.Generic;

namespace ProjectOnProjects.Models
{
    public class FavoriteListModels
    {
        public string ListName { get; set; }
        public List<Proiecte> Projects { get; set; }
    }
} 