using ProjectOnProjects.Common;
using System;
using System.Collections.Generic;

namespace ProjectOnProjects.Entities.Entities;

public partial class Proiecte : IEntity
{
    public int IdProject { get; set; }
    public string ProjectName { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime Deadline { get; set; }
    public string? ProjectDetails { get; set; }
    public string? ProjectFile { get; set; }
    public string? FileFormat { get; set; }

    // Contest Information
    public string? ContestCreator { get; set; }
    public string? Organization { get; set; }
    public string? WebsiteLink { get; set; }
    public string? ContestRules { get; set; }

    public int UserId { get; set; }
    public bool IsActive { get; set; }
    public DateTime TimeStamp { get; set; }

    public virtual ICollection<SavedProject> SavedProjects { get; set; } = new List<SavedProject>();
    public virtual ICollection<Favorites> Favorites { get; set; } = new List<Favorites>();
}
