using ProjectOnProjects.Common;
using System;
using System.Collections.Generic;

namespace ProjectOnProjects.Entities.Entities
{
    public class Favorites : IEntity
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int ProjectId { get; set; }
        public string ListName { get; set; }

        public virtual Utilizatori User { get; set; }
        public virtual Proiecte Project { get; set; }
    }
} 