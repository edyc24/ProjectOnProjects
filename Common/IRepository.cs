using System.Linq.Expressions;

namespace MoneyShop.Common;

public interface IRepository<TEntity>
    where TEntity : class, IEntity
{
    IQueryable<TEntity> Get();
    TEntity Insert(TEntity entity);
    TEntity Update(TEntity entitty);
    TEntity Find(Guid id);
    IQueryable<TEntity> Where(Expression<Func<TEntity, bool>> predicate);
    void Delete(TEntity entity);
}