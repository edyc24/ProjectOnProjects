using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using MoneyShop.Entities;
using MoneyShop.Entities.Entities;

namespace MoneyShop.DataAccess.EntityFramework;

public partial class MoneyShopContext : DbContext
{
    public MoneyShopContext()
    {
    }

    public MoneyShopContext(DbContextOptions<MoneyShopContext> options)
        : base(options)
    {
    }

    public virtual DbSet<BacDocument> BacDocuments { get; set; }

    public virtual DbSet<Proiecte> Proiectes { get; set; }

    public virtual DbSet<Roluri> Roluris { get; set; }

    public virtual DbSet<SavedProject> SavedProjects { get; set; }

    public virtual DbSet<Utilizatori> Utilizatoris { get; set; }

    public virtual DbSet<Favorites> Favorites { get; set; }

    // MoneyShop Entities
    public virtual DbSet<Application> Applications { get; set; }
    public virtual DbSet<Document> Documents { get; set; }
    public virtual DbSet<Bank> Banks { get; set; }
    public virtual DbSet<ApplicationBank> ApplicationBanks { get; set; }
    public virtual DbSet<Agreement> Agreements { get; set; }
    public virtual DbSet<Lead> Leads { get; set; }
    
    // OTP & Session Entities
    public virtual DbSet<OtpChallenge> OtpChallenges { get; set; }
    public virtual DbSet<Session> Sessions { get; set; }
    
    // Consent & Mandate Entities
    public virtual DbSet<LegalDoc> LegalDocs { get; set; }
    public virtual DbSet<Consent> Consents { get; set; }
    public virtual DbSet<Mandate> Mandates { get; set; }
    
    // Subject Map Entity (CNP Pseudonymization)
    public virtual DbSet<SubjectMap> SubjectMaps { get; set; }
    
    // KYC Entities
    public virtual DbSet<KycSession> KycSessions { get; set; }
    public virtual DbSet<KycFile> KycFiles { get; set; }
    
    // Broker Directory Entity
    public virtual DbSet<BrokerDirectory> BrokerDirectories { get; set; }
    
    // User Financial Data Entity
    public virtual DbSet<UserFinancialData> UserFinancialData { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // Connection string is configured in Program.cs via appsettings.json
        // This method is only used if DbContext is created without options
        if (!optionsBuilder.IsConfigured)
        {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
            // Fallback connection string (should not be used in production)
            // Use appsettings.json instead
            optionsBuilder.UseSqlServer("Server=localhost;Database=moneyshop;Integrated Security=True;TrustServerCertificate=True;MultipleActiveResultSets=True;");
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<BacDocument>(entity =>
        {
            entity.HasKey(e => e.IdDocument).HasName("PK__BacDocum__BEAAD0BAD56E4F0E");

            entity.Property(e => e.DataAdaugare)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.NumeDocument).HasMaxLength(255);
            entity.Property(e => e.TipMaterie).HasMaxLength(50);
        });

        modelBuilder.Entity<Proiecte>(entity =>
        {
            entity.HasKey(e => e.IdProject).HasName("PK__Proiecte__187B9AAFDE323DC0");

            entity.ToTable("Proiecte");

            entity.Property(e => e.Deadline).HasColumnType("datetime");
            entity.Property(e => e.StartDate).HasColumnType("datetime");
            entity.Property(e => e.ProjectName).HasMaxLength(255);

            
        });

        modelBuilder.Entity<Roluri>(entity =>
        {
            entity.HasKey(e => e.IdRol).HasName("PK__Roluri__2A49584C65FE7A4A");

            entity.ToTable("Roluri");

            entity.Property(e => e.NumeRol).HasMaxLength(50);
        });

        modelBuilder.Entity<SavedProject>(entity =>
        {
            entity.HasKey(e => e.IdSavedProject).HasName("PK__SavedPro__E5878A3ADC55E572");

            entity.Property(e => e.DataSalvare)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.IdProiectNavigation).WithMany(p => p.SavedProjects)
                .HasForeignKey(d => d.IdProiect)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__SavedProj__IdPro__46E78A0C");

            entity.HasOne(d => d.IdUtilizatorNavigation).WithMany(p => p.SavedProjects)
                .HasForeignKey(d => d.IdUtilizator)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__SavedProj__IdUti__45F365D3");
        });

        modelBuilder.Entity<Utilizatori>(entity =>
        {
            entity.HasKey(e => e.IdUtilizator).HasName("PK__Utilizat__99101D6D31235E34");

            entity.ToTable("Utilizatori");

            entity.HasIndex(e => e.Username, "UQ__Utilizat__536C85E4B4BA6916").IsUnique();

            entity.Property(e => e.DataIncepere).HasColumnType("datetime");
            entity.Property(e => e.DataNastere).HasColumnType("datetime");
            entity.Property(e => e.IsDeleted).HasDefaultValueSql("((0))");
            entity.Property(e => e.Mail).HasMaxLength(255);
            entity.Property(e => e.NumarTelefon).HasMaxLength(20);
            entity.Property(e => e.Nume).HasMaxLength(255);
            entity.Property(e => e.Parola).HasMaxLength(255);
            entity.Property(e => e.Prenume).HasMaxLength(255);
            entity.Property(e => e.Username).HasMaxLength(255);
        });

        modelBuilder.Entity<Favorites>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.HasOne(d => d.User)
                .WithMany(p => p.Favorites)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.Project)
                .WithMany(p => p.Favorites)
                .HasForeignKey(d => d.ProjectId)
                .OnDelete(DeleteBehavior.ClientSetNull);
        });

        // MoneyShop Entities Configuration
        modelBuilder.Entity<Application>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.ToTable("Applications");

            entity.Property(e => e.Status).HasMaxLength(50).HasDefaultValue("INREGISTRAT");
            entity.Property(e => e.TypeCredit).HasMaxLength(50);
            entity.Property(e => e.TipOperatiune).HasMaxLength(50);
            entity.Property(e => e.RecommendedLevel).HasMaxLength(50);
            entity.Property(e => e.SalariuNet).HasColumnType("decimal(18,2)");
            entity.Property(e => e.SumaBonuriMasa).HasColumnType("decimal(18,2)");
            entity.Property(e => e.SoldTotal).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Scoring).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Dti).HasColumnType("decimal(18,2)");
            entity.Property(e => e.SumaAprobata).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Comision).HasColumnType("decimal(18,2)");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");
            entity.Property(e => e.UpdatedAt).HasColumnType("datetime");
            entity.Property(e => e.DataDisbursare).HasColumnType("datetime");

            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Document>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.ToTable("Documents");

            entity.Property(e => e.DocType).HasMaxLength(100);
            entity.Property(e => e.AzureBlobPath).HasMaxLength(500);
            entity.Property(e => e.FileName).HasMaxLength(255);
            entity.Property(e => e.MimeType).HasMaxLength(100);
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Application)
                .WithMany(p => p.Documents)
                .HasForeignKey(d => d.ApplicationId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Bank>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.ToTable("Banks");

            entity.Property(e => e.Name).HasMaxLength(255);
            entity.Property(e => e.CommissionPercent).HasColumnType("decimal(5,2)");
        });

        modelBuilder.Entity<ApplicationBank>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.ToTable("ApplicationBanks");

            entity.Property(e => e.CommissionPercent).HasColumnType("decimal(5,2)");

            entity.HasOne(d => d.Application)
                .WithMany(p => p.ApplicationBanks)
                .HasForeignKey(d => d.ApplicationId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(d => d.Bank)
                .WithMany(p => p.ApplicationBanks)
                .HasForeignKey(d => d.BankId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Agreement>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.ToTable("Agreements");

            entity.Property(e => e.AgreementType).HasMaxLength(100);
            entity.Property(e => e.PdfBlobPath).HasMaxLength(500);
            entity.Property(e => e.Version).HasMaxLength(20).HasDefaultValue("1.0");
            entity.Property(e => e.SignatureImagePath).HasMaxLength(500);
            entity.Property(e => e.SignedAt).HasColumnType("datetime");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Application)
                .WithMany(p => p.Agreements)
                .HasForeignKey(d => d.ApplicationId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Lead>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.ToTable("Leads");

            entity.Property(e => e.Name).HasMaxLength(255);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.Judet).HasMaxLength(100);
            entity.Property(e => e.TypeCredit).HasMaxLength(50);
            entity.Property(e => e.IpAddress).HasMaxLength(50);
            entity.Property(e => e.CreatedAt).HasColumnType("datetime");
        });

        // OTP & Session Configuration
        modelBuilder.Entity<OtpChallenge>(entity =>
        {
            entity.HasKey(e => e.OtpId);
            entity.ToTable("OtpChallenges");

            entity.Property(e => e.Phone).HasMaxLength(30).IsRequired();
            entity.Property(e => e.Email).HasMaxLength(320);
            entity.Property(e => e.Purpose).HasMaxLength(30).IsRequired();
            entity.Property(e => e.OtpHash).IsRequired();
            entity.Property(e => e.Ip).HasMaxLength(64);
            entity.Property(e => e.CreatedAt).HasColumnType("datetime2");
            entity.Property(e => e.ExpiresAt).HasColumnType("datetime2");
            entity.Property(e => e.UsedAt).HasColumnType("datetime2");

            entity.HasIndex(e => new { e.Phone, e.Purpose, e.CreatedAt });
            entity.HasIndex(e => e.ExpiresAt);

            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        modelBuilder.Entity<Session>(entity =>
        {
            entity.HasKey(e => e.SessionId);
            entity.ToTable("Sessions");

            entity.Property(e => e.SourceChannel).HasMaxLength(20).IsRequired();
            entity.Property(e => e.Ip).HasMaxLength(64);
            entity.Property(e => e.UserAgent).HasMaxLength(1000);
            entity.Property(e => e.CreatedAt).HasColumnType("datetime2");
            entity.Property(e => e.ExpiresAt).HasColumnType("datetime2");
            entity.Property(e => e.RevokedAt).HasColumnType("datetime2");

            entity.HasIndex(e => new { e.UserId, e.CreatedAt });
            entity.HasIndex(e => e.ExpiresAt);

            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Consent & Mandate Configuration
        modelBuilder.Entity<LegalDoc>(entity =>
        {
            entity.HasKey(e => e.DocId);
            entity.ToTable("LegalDocs");

            entity.Property(e => e.DocType).HasMaxLength(30).IsRequired();
            entity.Property(e => e.Version).HasMaxLength(20).IsRequired();
            entity.Property(e => e.ContentHash).IsRequired();

            entity.HasIndex(e => new { e.DocType, e.Version }).IsUnique();
            entity.HasIndex(e => new { e.DocType, e.IsActive });
        });

        modelBuilder.Entity<Consent>(entity =>
        {
            entity.HasKey(e => e.ConsentId);
            entity.ToTable("Consents");

            entity.Property(e => e.ConsentType).HasMaxLength(60).IsRequired();
            entity.Property(e => e.Status).HasMaxLength(20).HasDefaultValue("granted");
            entity.Property(e => e.ConsentTextSnapshot).IsRequired();
            entity.Property(e => e.SourceChannel).HasMaxLength(20).IsRequired();
            entity.Property(e => e.Ip).HasMaxLength(64);
            entity.Property(e => e.UserAgent).HasMaxLength(1000);

            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(d => d.Doc)
                .WithMany(p => p.Consents)
                .HasForeignKey(d => d.DocId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(d => d.Session)
                .WithMany()
                .HasForeignKey(d => d.SessionId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasIndex(e => new { e.UserId, e.ConsentType, e.GrantedAt });
        });

        modelBuilder.Entity<Mandate>(entity =>
        {
            entity.HasKey(e => e.MandateId);
            entity.ToTable("Mandates");

            entity.Property(e => e.MandateType).HasMaxLength(30).IsRequired();
            entity.Property(e => e.Scope).HasMaxLength(100).HasDefaultValue("credit_eligibility_only");
            entity.Property(e => e.Status).HasMaxLength(20).IsRequired();
            entity.Property(e => e.RevokedReason).HasMaxLength(200);
            entity.Property(e => e.ConsentEventId).HasMaxLength(64);

            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => new { e.UserId, e.Status, e.GrantedAt });
            entity.HasIndex(e => e.ExpiresAt);
        });

        // Subject Map Configuration
        modelBuilder.Entity<SubjectMap>(entity =>
        {
            entity.HasKey(e => e.SubjectId);
            entity.ToTable("SubjectMaps");

            entity.Property(e => e.SubjectId).HasMaxLength(19).IsRequired(); // "MS-" + 16 chars
            entity.Property(e => e.CnpHash).IsRequired();
            entity.Property(e => e.CnpLast4).HasMaxLength(4);
            entity.Property(e => e.CreatedAt).HasColumnType("datetime2");

            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => e.CnpHash).IsUnique();
            entity.HasIndex(e => e.UserId).IsUnique();
        });

        // KYC Configuration
        modelBuilder.Entity<KycSession>(entity =>
        {
            entity.HasKey(e => e.KycId);
            entity.ToTable("KycSessions");

            entity.Property(e => e.KycType).HasMaxLength(30).IsRequired();
            entity.Property(e => e.Status).HasMaxLength(20).IsRequired();
            entity.Property(e => e.ProviderTransactionId).HasMaxLength(200);
            entity.Property(e => e.RejectionReason).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasColumnType("datetime2");
            entity.Property(e => e.VerifiedAt).HasColumnType("datetime2");
            entity.Property(e => e.ExpiresAt).HasColumnType("datetime2");
            
            // KYC Form Data
            entity.Property(e => e.Cnp).HasMaxLength(500); // Hashed CNP
            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.County).HasMaxLength(100);
            entity.Property(e => e.PostalCode).HasMaxLength(10);

            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => e.ExpiresAt);
            entity.HasIndex(e => new { e.UserId, e.CreatedAt });
        });

        modelBuilder.Entity<KycFile>(entity =>
        {
            entity.HasKey(e => e.FileId);
            entity.ToTable("KycFiles");

            entity.Property(e => e.FileType).HasMaxLength(30).IsRequired();
            entity.Property(e => e.BlobPath).HasMaxLength(1000); // Made nullable, deprecated
            entity.Property(e => e.FileName).HasMaxLength(255).IsRequired();
            entity.Property(e => e.MimeType).HasMaxLength(100).IsRequired();
            entity.Property(e => e.FileContentBase64).HasColumnType("nvarchar(max)"); // Store base64 as nvarchar(max)
            entity.Property(e => e.CreatedAt).HasColumnType("datetime2");
            entity.Property(e => e.ExpiresAt).HasColumnType("datetime2");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime2");

            entity.HasOne(d => d.KycSession)
                .WithMany(p => p.KycFiles)
                .HasForeignKey(d => d.KycId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => e.ExpiresAt);
            entity.HasIndex(e => e.KycId);
        });

        // Broker Directory Configuration
        modelBuilder.Entity<BrokerDirectory>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.ToTable("BrokerDirectories");

            entity.Property(e => e.ExcelFileName).HasMaxLength(255).IsRequired();
            entity.Property(e => e.BlobPath).HasMaxLength(1000).IsRequired();
            entity.Property(e => e.Notes).HasMaxLength(500);
            entity.Property(e => e.UploadedAt).HasColumnType("datetime2");

            entity.HasOne(d => d.UploadedByUser)
                .WithMany()
                .HasForeignKey(d => d.UploadedByUserId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(e => e.UploadedAt);
        });

        // User Financial Data Configuration
        modelBuilder.Entity<UserFinancialData>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.ToTable("UserFinancialData");

            entity.Property(e => e.SalariuNet).HasColumnType("decimal(18,2)");
            entity.Property(e => e.SumaBonuriMasa).HasColumnType("decimal(18,2)");
            entity.Property(e => e.VenitTotal).HasColumnType("decimal(18,2)");
            entity.Property(e => e.SoldTotal).HasColumnType("decimal(18,2)");
            entity.Property(e => e.RataTotalaLunara).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Dti).HasColumnType("decimal(5,4)");
            entity.Property(e => e.ScoringLevel).HasMaxLength(50);
            entity.Property(e => e.RecommendedLevel).HasMaxLength(50);
            entity.Property(e => e.LastUpdated).HasColumnType("datetime2");
            entity.Property(e => e.CreatedAt).HasColumnType("datetime2");

            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => e.UserId);
            entity.HasIndex(e => e.LastUpdated);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
