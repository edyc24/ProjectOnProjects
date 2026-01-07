using MoneyShop.BusinessLogic.Base;
using MoneyShop.BusinessLogic.Implementation.BacDocumentService.Models;
using System.Collections.Generic;
using System.Linq;

namespace MoneyShop.BusinessLogic.Implementation.BacDocumentService
{
    public class BacDocumentService : BaseService
    {
        public BacDocumentService(ServiceDependencies dependencies)
            : base(dependencies)
        {
        }

        public BacDocumentsViewModel GetAllDocuments()
        {
            var documents = new BacDocumentsViewModel
            {
                RomanianDocuments = UnitOfWork.BacDocuments.Get().Where(d => d.TipMaterie == "Română").Select(d => d.NumeDocument).ToList(),
                MathDocuments = UnitOfWork.BacDocuments.Get().Where(d => d.TipMaterie == "Matematică").Select(d => d.NumeDocument).ToList(),
                PhysicsInfoDocuments = UnitOfWork.BacDocuments.Get().Where(d => d.TipMaterie == "Fizică" || d.TipMaterie == "Info").Select(d => d.NumeDocument).ToList()
            };

            return documents;
        }
    }
}