using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using MoneyShop.Entities.Entities;
using System.Text.Json;
using System.Linq;
using System;
using ApplicationEntity = MoneyShop.Entities.Entities.Application;

namespace MoneyShop.BusinessLogic.Implementation.Application
{
    public class ApplicationService : BaseService
    {
        public ApplicationService(ServiceDependencies dependencies)
            : base(dependencies)
        {
        }

        public ApplicationEntity CreateApplication(ApplicationEntity application)
        {
            application.Status = "INREGISTRAT";
            application.CreatedAt = DateTime.UtcNow;
            application.UpdatedAt = DateTime.UtcNow;

            UnitOfWork.Applications.Insert(application);
            UnitOfWork.SaveChanges();

            return application;
        }

        public ApplicationEntity? GetApplicationById(int id)
        {
            return UnitOfWork.Applications.Get()
                .FirstOrDefault(a => a.Id == id);
        }

        public List<ApplicationEntity> GetUserApplications(int userId)
        {
            return UnitOfWork.Applications.Get()
                .Where(a => a.UserId == userId)
                .OrderByDescending(a => a.CreatedAt)
                .ToList();
        }

        public ApplicationEntity UpdateApplication(ApplicationEntity application)
        {
            application.UpdatedAt = DateTime.UtcNow;
            UnitOfWork.Applications.Update(application);
            UnitOfWork.SaveChanges();

            return application;
        }

        public void UpdateApplicationStatus(int applicationId, string status)
        {
            var application = GetApplicationById(applicationId);
            if (application != null)
            {
                application.Status = status;
                application.UpdatedAt = DateTime.UtcNow;
                UnitOfWork.Applications.Update(application);
                UnitOfWork.SaveChanges();
            }
        }

        public void DeleteApplication(int id)
        {
            var application = GetApplicationById(id);
            if (application != null)
            {
                UnitOfWork.Applications.Delete(application);
                UnitOfWork.SaveChanges();
            }
        }
    }
}

