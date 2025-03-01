using ProjectOnProjects.BusinessLogic.Base;
using ProjectOnProjects.BusinessLogic.Implementation.ProjectService.Models;
using ProjectOnProjects.Entities.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;


namespace ProjectOnProjects.BusinessLogic.Implementation.ProjectService
{
    public class ProjectService : BaseService
    {
        public ProjectService(ServiceDependencies dependencies)
            : base(dependencies)
        {
        }

        public async Task<List<ProjectModel>> GetAllAsync()
        {
            var projects = await UnitOfWork.Projects.Get()
                .Select(p => new ProjectModel
                {
                    IdProiect = p.IdProject,
                    NumeProiect = p.ProjectName,
                    DataStart = p.StartDate,
                    DataSfarsit = p.Deadline,
                    DetaliiProiect = p.ProjectDetails,
                    FisierProiect = p.ProjectFile,
                    FileFormat = p.FileFormat,
                    ContestCreator = p.ContestCreator,
                    OrganizatieInstitutie = p.Organization,
                    LinkSite = p.WebsiteLink,
                    InformatiiCompetitie = p.ContestRules,
                    UserId = p.UserId,
                    IsActive = p.IsActive,
                    TimeStamp = p.TimeStamp
                })
                .OrderBy(p => p.DataStart)
                .ToListAsync();

            return projects;
        }

        public async Task<ProjectModel?> GetByIdAsync(int id)
        {
            var project = await UnitOfWork.Projects.Get()
                .FirstOrDefaultAsync(a => a.IdProject == id);

            if (project == null) return null;

            return new ProjectModel
            {
                IdProiect = project.IdProject,
                NumeProiect = project.ProjectName,
                DataStart = project.StartDate,
                DataSfarsit = project.Deadline,
                DetaliiProiect = project.ProjectDetails,
                FisierProiect = project.ProjectFile,
                FileFormat = project.FileFormat,
                ContestCreator = project.ContestCreator,
                OrganizatieInstitutie = project.Organization,
                LinkSite = project.WebsiteLink,
                InformatiiCompetitie = project.ContestRules,
                UserId = project.UserId,
                IsActive = project.IsActive,
                TimeStamp = project.TimeStamp
            };
        }

        public bool CreateAsync(ProjectModel model)
        {
            var project = new Proiecte
            {
                ProjectName = model.NumeProiect,
                StartDate = model.DataStart,
                Deadline = model.DataSfarsit,
                ProjectDetails = model.DetaliiProiect,
                ProjectFile = model.FisierProiect,
                FileFormat = "pdf",
                ContestCreator = model.ContestCreator,
                Organization = model.OrganizatieInstitutie,
                WebsiteLink = model.LinkSite,
                ContestRules = model.InformatiiCompetitie,
                UserId = CurrentUser.Id,
                IsActive = true,
                TimeStamp = DateTime.UtcNow
            };

            UnitOfWork.Projects.Insert(project);
            UnitOfWork.SaveChanges();
            return true;
        }

        public async Task<bool> UpdateAsync(ProjectModel model)
        {
            var project = await UnitOfWork.Projects.Get()
                .FirstOrDefaultAsync(a => a.IdProject == model.IdProiect);

            if (project == null) return false;

            project.ProjectName = model.NumeProiect;
            project.StartDate = model.DataStart;
            project.Deadline = model.DataSfarsit;
            project.ProjectDetails = model.DetaliiProiect;
            project.ProjectFile = model.FisierProiect;
            project.FileFormat = model.FileFormat;
            project.ContestCreator = model.ContestCreator;
            project.Organization = model.OrganizatieInstitutie;
            project.WebsiteLink = model.LinkSite;
            project.ContestRules = model.InformatiiCompetitie;
            project.IsActive = model.IsActive;
            project.TimeStamp = DateTime.UtcNow;

            UnitOfWork.Projects.Update(project);
            UnitOfWork.SaveChanges();
            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var project = await UnitOfWork.Projects.Get()
                .FirstOrDefaultAsync(a => a.IdProject == id);

            if (project == null) return false;

            // Soft delete - just mark as inactive
            project.IsActive = false;
            project.TimeStamp = DateTime.UtcNow;

            UnitOfWork.Projects.Update(project);
            UnitOfWork.SaveChanges();
            return true;
        }

        public async Task<List<ProjectModel>> GetProjectsInDateRangeAsync(DateTime startDate, DateTime endDate)
        {
            var projects = await UnitOfWork.Projects.Get()
                .Where(p => p.IsActive &&
                           p.StartDate >= startDate &&
                           p.Deadline <= endDate)
                .Select(p => new ProjectModel
                {
                    IdProiect = p.IdProject,
                    NumeProiect = p.ProjectName,
                    DataStart = p.StartDate,
                    DataSfarsit = p.Deadline,
                    DetaliiProiect = p.ProjectDetails,
                    FisierProiect = p.ProjectFile,
                    FileFormat = p.FileFormat,
                    ContestCreator = p.ContestCreator,
                    OrganizatieInstitutie = p.Organization,
                    LinkSite = p.WebsiteLink,
                    InformatiiCompetitie = p.ContestRules,
                    UserId = p.UserId,
                    IsActive = p.IsActive,
                    TimeStamp = p.TimeStamp
                })
                .OrderBy(p => p.DataStart)
                .ToListAsync();

            return projects;
        }
    }
}