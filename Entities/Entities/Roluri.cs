using ProjectOnProjects.Common;
using System;
using System.Collections.Generic;

namespace ProjectOnProjects.Entities.Entities;

public partial class Roluri : IEntity
{
    public int IdRol { get; set; }

    public string NumeRol { get; set; } = null!;
}
