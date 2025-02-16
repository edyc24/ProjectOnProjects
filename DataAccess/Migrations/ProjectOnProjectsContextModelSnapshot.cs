﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using ProjectOnProjects.DataAccess.EntityFramework;

#nullable disable

namespace ProjectOnProjects.DataAccess.Migrations
{
    [DbContext(typeof(ProjectOnProjectsContext))]
    partial class ProjectOnProjectsContextModelSnapshot : ModelSnapshot
    {
        protected override void BuildModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "7.0.13")
                .HasAnnotation("Relational:MaxIdentifierLength", 128);

            SqlServerModelBuilderExtensions.UseIdentityColumns(modelBuilder);

            modelBuilder.Entity("ProjectOnProjects.Entities.Entities.BacDocument", b =>
                {
                    b.Property<int>("IdDocument")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("IdDocument"));

                    b.Property<byte[]>("Continut")
                        .IsRequired()
                        .HasColumnType("varbinary(max)");

                    b.Property<DateTime?>("DataAdaugare")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime")
                        .HasDefaultValueSql("(getdate())");

                    b.Property<string>("NumeDocument")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("TipMaterie")
                        .IsRequired()
                        .HasMaxLength(50)
                        .HasColumnType("nvarchar(50)");

                    b.HasKey("IdDocument")
                        .HasName("PK__BacDocum__BEAAD0BAD56E4F0E");

                    b.ToTable("BacDocuments");
                });

            modelBuilder.Entity("ProjectOnProjects.Entities.Entities.Proiecte", b =>
                {
                    b.Property<int>("IdProject")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("IdProject"));

                    b.Property<string>("ContestCreator")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("ContestRules")
                        .HasColumnType("nvarchar(max)");

                    b.Property<DateTime>("Deadline")
                        .HasColumnType("datetime");

                    b.Property<string>("FileFormat")
                        .HasColumnType("nvarchar(max)");

                    b.Property<bool>("IsActive")
                        .HasColumnType("bit");

                    b.Property<string>("Organization")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("ProjectDetails")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("ProjectFile")
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("ProjectName")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<DateTime>("StartDate")
                        .HasColumnType("datetime");

                    b.Property<DateTime>("TimeStamp")
                        .HasColumnType("datetime2");

                    b.Property<int>("UserId")
                        .HasColumnType("int");

                    b.Property<int?>("UtilizatoriIdUtilizator")
                        .HasColumnType("int");

                    b.Property<string>("WebsiteLink")
                        .HasColumnType("nvarchar(max)");

                    b.HasKey("IdProject")
                        .HasName("PK__Proiecte__187B9AAFDE323DC0");

                    b.HasIndex("UtilizatoriIdUtilizator");

                    b.ToTable("Proiecte", (string)null);
                });

            modelBuilder.Entity("ProjectOnProjects.Entities.Entities.Roluri", b =>
                {
                    b.Property<int>("IdRol")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("IdRol"));

                    b.Property<string>("NumeRol")
                        .IsRequired()
                        .HasMaxLength(50)
                        .HasColumnType("nvarchar(50)");

                    b.HasKey("IdRol")
                        .HasName("PK__Roluri__2A49584C65FE7A4A");

                    b.ToTable("Roluri", (string)null);
                });

            modelBuilder.Entity("ProjectOnProjects.Entities.Entities.SavedProject", b =>
                {
                    b.Property<int>("IdSavedProject")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("IdSavedProject"));

                    b.Property<DateTime?>("DataSalvare")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("datetime")
                        .HasDefaultValueSql("(getdate())");

                    b.Property<int>("IdProiect")
                        .HasColumnType("int");

                    b.Property<int>("IdUtilizator")
                        .HasColumnType("int");

                    b.HasKey("IdSavedProject")
                        .HasName("PK__SavedPro__E5878A3ADC55E572");

                    b.HasIndex("IdProiect");

                    b.HasIndex("IdUtilizator");

                    b.ToTable("SavedProjects");
                });

            modelBuilder.Entity("ProjectOnProjects.Entities.Entities.Utilizatori", b =>
                {
                    b.Property<int>("IdUtilizator")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("int");

                    SqlServerPropertyBuilderExtensions.UseIdentityColumn(b.Property<int>("IdUtilizator"));

                    b.Property<DateTime?>("DataIncepere")
                        .HasColumnType("datetime");

                    b.Property<DateTime?>("DataNastere")
                        .HasColumnType("datetime");

                    b.Property<int>("IdRol")
                        .HasColumnType("int");

                    b.Property<bool?>("IsDeleted")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("bit")
                        .HasDefaultValueSql("((0))");

                    b.Property<string>("Mail")
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("NumarTelefon")
                        .HasMaxLength(20)
                        .HasColumnType("nvarchar(20)");

                    b.Property<string>("Nume")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("Parola")
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("Prenume")
                        .IsRequired()
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.Property<string>("Username")
                        .HasMaxLength(255)
                        .HasColumnType("nvarchar(255)");

                    b.HasKey("IdUtilizator")
                        .HasName("PK__Utilizat__99101D6D31235E34");

                    b.HasIndex(new[] { "Username" }, "UQ__Utilizat__536C85E4B4BA6916")
                        .IsUnique()
                        .HasFilter("[Username] IS NOT NULL");

                    b.ToTable("Utilizatori", (string)null);
                });

            modelBuilder.Entity("ProjectOnProjects.Entities.Entities.Proiecte", b =>
                {
                    b.HasOne("ProjectOnProjects.Entities.Entities.Utilizatori", null)
                        .WithMany("Proiectes")
                        .HasForeignKey("UtilizatoriIdUtilizator");
                });

            modelBuilder.Entity("ProjectOnProjects.Entities.Entities.SavedProject", b =>
                {
                    b.HasOne("ProjectOnProjects.Entities.Entities.Proiecte", "IdProiectNavigation")
                        .WithMany("SavedProjects")
                        .HasForeignKey("IdProiect")
                        .IsRequired()
                        .HasConstraintName("FK__SavedProj__IdPro__46E78A0C");

                    b.HasOne("ProjectOnProjects.Entities.Entities.Utilizatori", "IdUtilizatorNavigation")
                        .WithMany("SavedProjects")
                        .HasForeignKey("IdUtilizator")
                        .IsRequired()
                        .HasConstraintName("FK__SavedProj__IdUti__45F365D3");

                    b.Navigation("IdProiectNavigation");

                    b.Navigation("IdUtilizatorNavigation");
                });

            modelBuilder.Entity("ProjectOnProjects.Entities.Entities.Proiecte", b =>
                {
                    b.Navigation("SavedProjects");
                });

            modelBuilder.Entity("ProjectOnProjects.Entities.Entities.Utilizatori", b =>
                {
                    b.Navigation("Proiectes");

                    b.Navigation("SavedProjects");
                });
#pragma warning restore 612, 618
        }
    }
}
