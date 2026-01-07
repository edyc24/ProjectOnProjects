using MoneyShop.Common;
using MoneyShop.DataAccess.EntityFramework;
using MoneyShop.Entities.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MoneyShop.DataAccess
{
    public class UnitOfWork
    {
        private readonly MoneyShopContext Context;

        public UnitOfWork(MoneyShopContext context)
        {
            this.Context = context;
        }

        private IRepository<Utilizatori>? users;
        public IRepository<Utilizatori> Users => users ?? (users = new BaseRepository<Utilizatori>(Context));

        private IRepository<Proiecte>? projects;
        public IRepository<Proiecte> Projects => projects ?? (projects = new BaseRepository<Proiecte>(Context));

        private IRepository<BacDocument>? bacDocuments;
        public IRepository<BacDocument> BacDocuments => bacDocuments ?? (bacDocuments = new BaseRepository<BacDocument>(Context));

        private IRepository<Roluri>? roles;
        public IRepository<Roluri> Roles => roles ?? (roles = new BaseRepository<Roluri>(Context));

        private IRepository<Favorites>? favorites;
        public IRepository<Favorites> Favorites => favorites ?? (favorites = new BaseRepository<Favorites>(Context));

        // MoneyShop Repositories
        private IRepository<Application>? applications;
        public IRepository<Application> Applications => applications ?? (applications = new BaseRepository<Application>(Context));

        private IRepository<Document>? documents;
        public IRepository<Document> Documents => documents ?? (documents = new BaseRepository<Document>(Context));

        private IRepository<Bank>? banks;
        public IRepository<Bank> Banks => banks ?? (banks = new BaseRepository<Bank>(Context));

        private IRepository<ApplicationBank>? applicationBanks;
        public IRepository<ApplicationBank> ApplicationBanks => applicationBanks ?? (applicationBanks = new BaseRepository<ApplicationBank>(Context));

        private IRepository<Agreement>? agreements;
        public IRepository<Agreement> Agreements => agreements ?? (agreements = new BaseRepository<Agreement>(Context));

        private IRepository<Lead>? leads;
        public IRepository<Lead> Leads => leads ?? (leads = new BaseRepository<Lead>(Context));

        // OTP & Session Repositories
        private IRepository<OtpChallenge>? otpChallenges;
        public IRepository<OtpChallenge> OtpChallenges => otpChallenges ?? (otpChallenges = new BaseRepository<OtpChallenge>(Context));

        private IRepository<Session>? sessions;
        public IRepository<Session> Sessions => sessions ?? (sessions = new BaseRepository<Session>(Context));

        // Consent & Mandate Repositories
        private IRepository<LegalDoc>? legalDocs;
        public IRepository<LegalDoc> LegalDocs => legalDocs ?? (legalDocs = new BaseRepository<LegalDoc>(Context));

        private IRepository<Consent>? consents;
        public IRepository<Consent> Consents => consents ?? (consents = new BaseRepository<Consent>(Context));

        private IRepository<Mandate>? mandates;
        public IRepository<Mandate> Mandates => mandates ?? (mandates = new BaseRepository<Mandate>(Context));

        // Subject Map Repository (CNP Pseudonymization)
        private IRepository<SubjectMap>? subjectMaps;
        public IRepository<SubjectMap> SubjectMaps => subjectMaps ?? (subjectMaps = new BaseRepository<SubjectMap>(Context));

        // KYC Repositories
        private IRepository<KycSession>? kycSessions;
        public IRepository<KycSession> KycSessions => kycSessions ?? (kycSessions = new BaseRepository<KycSession>(Context));

        private IRepository<KycFile>? kycFiles;
        public IRepository<KycFile> KycFiles => kycFiles ?? (kycFiles = new BaseRepository<KycFile>(Context));

        // Broker Directory Repository
        private IRepository<BrokerDirectory>? brokerDirectories;
        public IRepository<BrokerDirectory> BrokerDirectories => brokerDirectories ?? (brokerDirectories = new BaseRepository<BrokerDirectory>(Context));

        // User Financial Data Repository
        private IRepository<UserFinancialData>? userFinancialData;
        public IRepository<UserFinancialData> UserFinancialData => userFinancialData ?? (userFinancialData = new BaseRepository<UserFinancialData>(Context));

        public void SaveChanges()
        {
            Context.SaveChanges();
        }
    }
}
