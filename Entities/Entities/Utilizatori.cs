using System;
using System.Collections.Generic;
using ProjectOnProjects.Common;

namespace ProjectOnProjects.Entities.Entities;

public partial class Utilizatori : IEntity
{
    public int IdUtilizator { get; set; }

    public string Nume { get; set; } = null!;

    public string Prenume { get; set; } = null!;

    public string? Username { get; set; } = null!;

    public string? Mail { get; set; }

    public string? Parola { get; set; }

    public string? NumarTelefon { get; set; }
    
    public string? Skills { get; set; }

    public string? Description { get; set; }

    public DateTime? DataIncepere { get; set; }

    public DateTime? DataNastere { get; set; }

    public int IdRol { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual ICollection<Proiecte> Proiectes { get; set; } = new List<Proiecte>();
    public virtual ICollection<Favorites> Favorites { get; set; } = new List<Favorites>();

    public virtual ICollection<SavedProject> SavedProjects { get; set; } = new List<SavedProject>();
}
