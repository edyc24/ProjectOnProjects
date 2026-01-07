using MoneyShop.BusinessLogic.Base;
using MoneyShop.BusinessLogic.Implementation.Account;
using MoneyShop.DataAccess;
using MoneyShop.Entities.Entities;
using MoneyShop.Models;
using System.Collections.Generic;
using System.Linq;

namespace MoneyShop.BusinessLogic.Implementation.Bac
{
    public class BacService : BaseService
    {
        public BacService(ServiceDependencies dependencies /*MailService mailService*/)
            : base(dependencies)
        {
        }

        public List<BacDocumentModel> GetBacDocuments()
        {
            return UnitOfWork.BacDocuments.Get()
                .Select(doc => new BacDocumentModel
                {
                    Id = doc.IdDocument,
                    Name = doc.NumeDocument,
                    SubjectType = doc.TipMaterie
                })
                .ToList();
        }

        public void AddBacDocument(BacDocumentModel model)
        {
            var document = new BacDocument
            {
                NumeDocument = model.Name,
                TipMaterie = model.SubjectType,
                Continut = model.Content,
                DataAdaugare = DateTime.Now
            };

            UnitOfWork.BacDocuments.Insert(document);
            UnitOfWork.SaveChanges();
        }
    }
} 