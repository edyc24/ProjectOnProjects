using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using MoneyShop.Entities.Entities;
using System.Linq;
using LeadEntity = MoneyShop.Entities.Entities.Lead;

namespace MoneyShop.BusinessLogic.Implementation.Lead
{
    public class LeadService : BaseService
    {
        public LeadService(ServiceDependencies dependencies)
            : base(dependencies)
        {
        }

        public LeadEntity CreateLead(LeadEntity lead)
        {
            lead.CreatedAt = DateTime.UtcNow;
            lead.Converted = false;
            UnitOfWork.Leads.Insert(lead);
            UnitOfWork.SaveChanges();
            return lead;
        }

        public List<LeadEntity> GetAllLeads()
        {
            return UnitOfWork.Leads.Get()
                .OrderByDescending(l => l.CreatedAt)
                .ToList();
        }

        public LeadEntity? GetLeadById(int id)
        {
            return UnitOfWork.Leads.Get()
                .FirstOrDefault(l => l.Id == id);
        }

        public void ConvertLeadToUser(int leadId, int userId, int? applicationId = null)
        {
            var lead = GetLeadById(leadId);
            if (lead != null)
            {
                lead.Converted = true;
                lead.ConvertedToUserId = userId;
                lead.ConvertedToApplicationId = applicationId;
                UnitOfWork.Leads.Update(lead);
                UnitOfWork.SaveChanges();
            }
        }
    }
}

