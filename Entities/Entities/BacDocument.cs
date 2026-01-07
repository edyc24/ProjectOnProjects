using MoneyShop.Common;
using System;
using System.Collections.Generic;

namespace MoneyShop.Entities.Entities;

public partial class BacDocument : IEntity
{
    public int IdDocument { get; set; }

    public string NumeDocument { get; set; } = null!;

    public string TipMaterie { get; set; } = null!;

    public byte[] Continut { get; set; } = null!;

    public DateTime? DataAdaugare { get; set; }
}
