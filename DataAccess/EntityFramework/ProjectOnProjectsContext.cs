using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using ProjectOnProjects.Entities;
using ProjectOnProjects.Entities.Entities;

namespace ProjectOnProjects.DataAccess.EntityFramework;

public partial class ProjectOnProjectsContext : DbContext
{
    public ProjectOnProjectsContext()
    {
    }

    public ProjectOnProjectsContext(DbContextOptions<ProjectOnProjectsContext> options)
        : base(options)
    {
    }

    public virtual DbSet<BacDocument> BacDocuments { get; set; }

    public virtual DbSet<Proiecte> Proiectes { get; set; }

    public virtual DbSet<Roluri> Roluris { get; set; }

    public virtual DbSet<SavedProject> SavedProjects { get; set; }

    public virtual DbSet<Utilizatori> Utilizatoris { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=P1-EDUARDCR;Database=ProjectOnProjects;Trusted_Connection=True;TrustServerCertificate=True");

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

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
