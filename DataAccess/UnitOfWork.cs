using ProjectOnProjects.Common;
using ProjectOnProjects.DataAccess.EntityFramework;
using ProjectOnProjects.Entities.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ProjectOnProjects.DataAccess
{
    public class UnitOfWork
    {
        private readonly ProjectOnProjectsContext Context;

        public UnitOfWork(ProjectOnProjectsContext context)
        {
            this.Context = context;
        }

        private IRepository<Utilizatori>? users;
        public IRepository<Utilizatori> Users => users ?? (users = new BaseRepository<Utilizatori>(Context));

        private IRepository<Proiecte>? projects;
        public IRepository<Proiecte> Projects => projects ?? (projects = new BaseRepository<Proiecte>(Context));

        private IRepository<BacDocument>? bacDocuments;
        public IRepository<BacDocument> BacDocuments => bacDocuments ?? (bacDocuments = new BaseRepository<BacDocument>(Context));


        public void SaveChanges()
        {
            Context.SaveChanges();
        }
    }
}
