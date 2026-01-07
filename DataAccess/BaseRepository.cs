using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;
using MoneyShop.Common;
using MoneyShop.DataAccess.EntityFramework;

namespace MoneyShop.DataAccess
{
    public class BaseRepository<TEntity> : IRepository<TEntity>
        where TEntity : class, IEntity
    {
        private readonly MoneyShopContext Context;

        public BaseRepository(MoneyShopContext context)
        {
            this.Context = context;
        }

        public IQueryable<TEntity> Get()
        {
            return Context.Set<TEntity>().AsQueryable();
        }
        public TEntity Insert(TEntity entity)
        {
            Context.Set<TEntity>().Add(entity);
            return entity;
        }

        public IQueryable<TEntity> Where(Expression<Func<TEntity, bool>> predicate)
        {
            return Context.Set<TEntity>().Where(predicate);
        }

        public TEntity Update(TEntity entity)
        {
            Context.Set<TEntity>().Update(entity);
            return entity;
        }

        public TEntity FindById(int id)
        {
            return Context.Set<TEntity>().Find(id);
        }

        public TEntity Find(Guid id)
        {
            return Context.Set<TEntity>().Find(id);
        }

        public DbSet<TEntity> Set(TEntity entity)
        {
            return Context.Set<TEntity>();
        }

        public void Delete(TEntity entity)
        {
            Context.Set<TEntity>().Remove(entity);
        }
    }
}
