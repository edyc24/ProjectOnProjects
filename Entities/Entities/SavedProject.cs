using ProjectOnProjects.Common;
using System;
using System.Collections.Generic;

namespace ProjectOnProjects.Entities.Entities;

public partial class SavedProject : IEntity
{
    public int IdSavedProject { get; set; }

    public int IdUtilizator { get; set; }

    public int IdProiect { get; set; }

    public DateTime? DataSalvare { get; set; }

    public virtual Proiecte IdProiectNavigation { get; set; } = null!;

    public virtual Utilizatori IdUtilizatorNavigation { get; set; } = null!;
}
