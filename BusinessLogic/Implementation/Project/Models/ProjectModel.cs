namespace ProjectOnProjects.BusinessLogic.Implementation.ProjectService.Models
{
    public class ProjectModel
    {
        public int IdProiect { get; set; }
        public string NumeProiect { get; set; } = null!;
        public DateTime DataStart { get; set; }
        public DateTime DataSfarsit { get; set; }
        public string? DetaliiProiect { get; set; }
        public byte[] FisierProiect { get; set; }
        public string? FileFormat { get; set; }

        // Contest Information
        public string? ContestCreator { get; set; }
        public string? OrganizatieInstitutie { get; set; }
        public string? LinkSite { get; set; }
        public string? InformatiiCompetitie { get; set; }

        public int UserId { get; set; }
        public bool IsActive { get; set; }
        public DateTime TimeStamp { get; set; }
    }
}