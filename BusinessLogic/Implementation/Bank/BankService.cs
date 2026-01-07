using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using MoneyShop.Entities.Entities;
using System.Linq;
using BankEntity = MoneyShop.Entities.Entities.Bank;

namespace MoneyShop.BusinessLogic.Implementation.Bank
{
    public class BankService : BaseService
    {
        public BankService(ServiceDependencies dependencies)
            : base(dependencies)
        {
        }

        public List<BankEntity> GetAllBanks()
        {
            return UnitOfWork.Banks.Get()
                .Where(b => b.Active)
                .OrderBy(b => b.Name)
                .ToList();
        }

        public BankEntity? GetBankById(int id)
        {
            return UnitOfWork.Banks.Get()
                .FirstOrDefault(b => b.Id == id);
        }

        public BankEntity CreateBank(BankEntity bank)
        {
            UnitOfWork.Banks.Insert(bank);
            UnitOfWork.SaveChanges();
            return bank;
        }

        public BankEntity UpdateBank(BankEntity bank)
        {
            UnitOfWork.Banks.Update(bank);
            UnitOfWork.SaveChanges();
            return bank;
        }
    }
}

