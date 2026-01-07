using System;
using System.Collections.Generic;
using MoneyShop.Common;

namespace MoneyShop.Entities.Entities;

public partial class Utilizatori : IEntity
{
    public int IdUtilizator { get; set; }

    public string Nume { get; set; } = null!;

    public string Prenume { get; set; } = null!;

    public string? Username { get; set; } = null!;

    public string? Mail { get; set; }

    public string? Parola { get; set; }

    public string? NumarTelefon { get; set; }
    
    public bool EmailVerified { get; set; } = false;
    
    public bool PhoneVerified { get; set; } = false;
    
    public string? Skills { get; set; }

    public string? Description { get; set; }

    public DateTime? DataIncepere { get; set; }

    public DateTime? DataNastere { get; set; }

    public int IdRol { get; set; }

    public bool? IsDeleted { get; set; }

    public virtual ICollection<Proiecte> Proiectes { get; set; } = new List<Proiecte>();
    public virtual ICollection<Favorites> Favorites { get; set; } = new List<Favorites>();

    public virtual ICollection<SavedProject> SavedProjects { get; set; } = new List<SavedProject>();
    
    // OTP & Session navigation
    public virtual ICollection<OtpChallenge> OtpChallenges { get; set; } = new List<OtpChallenge>();
    public virtual ICollection<Session> Sessions { get; set; } = new List<Session>();
    
    // KYC navigation
    public virtual ICollection<KycSession> KycSessions { get; set; } = new List<KycSession>();
}
