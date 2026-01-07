using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using MoneyShop.Entities.Entities;
using System.Text.Json;

namespace MoneyShop.BusinessLogic.Implementation.Simulator
{
    public class ScoringService : BaseService
    {
        public ScoringService(ServiceDependencies dependencies)
            : base(dependencies)
        {
        }

        public ScoringResult CalculateScoring(ScoringRequest request)
        {
            // Calculează venitul total (inclusiv bonuri de masă)
            decimal venitTotal = request.SalariuNet;
            if (request.BonuriMasa == true && request.SumaBonuriMasa.HasValue)
            {
                venitTotal += request.SumaBonuriMasa.Value;
            }

            // Calculează rata estimativă nouă (15% din venit)
            decimal rataEstimativaNoua = venitTotal * 0.15m;

            // Calculează rata totală existentă (din sold_total, aproximativ 5% pe an)
            decimal rataExistenta = request.SoldTotal.HasValue ? request.SoldTotal.Value * 0.05m / 12 : 0;

            // Adaugă ratele din carduri de credit și descoperit
            if (!string.IsNullOrEmpty(request.CardCredit))
            {
                var cardCredit = JsonSerializer.Deserialize<List<CardCreditData>>(request.CardCredit);
                if (cardCredit != null)
                {
                    foreach (var card in cardCredit)
                    {
                        // Presupunem că plata minimă este 5% din limită
                        rataExistenta += card.Limita * 0.05m;
                    }
                }
            }

            if (!string.IsNullOrEmpty(request.Overdraft))
            {
                var overdraft = JsonSerializer.Deserialize<List<OverdraftData>>(request.Overdraft);
                if (overdraft != null)
                {
                    foreach (var od in overdraft)
                    {
                        // Presupunem că plata minimă este 3% din limită
                        rataExistenta += od.Limita * 0.03m;
                    }
                }
            }

            // Adaugă venitul codebitorilor
            if (!string.IsNullOrEmpty(request.Codebitori))
            {
                var codebitori = JsonSerializer.Deserialize<List<CodebitorData>>(request.Codebitori);
                if (codebitori != null)
                {
                    foreach (var codebitor in codebitori)
                    {
                        venitTotal += codebitor.Venit;
                    }
                }
            }

            // Calculează DTI
            decimal dti = (rataExistenta + rataEstimativaNoua) / venitTotal;

            // Aplică penalizări
            if (request.Intarzieri == true && request.IntarzieriNumar.HasValue)
            {
                if (request.IntarzieriNumar.Value >= 7)
                {
                    return new ScoringResult
                    {
                        Dti = dti,
                        ScoringLevel = "foarte_scazut",
                        RecommendedLevel = "0%",
                        Reasoning = new List<string> { "Prea multe întârzieri (7+)" }
                    };
                }
                else if (request.IntarzieriNumar.Value >= 3)
                {
                    dti += 0.10m;
                }
                else if (request.IntarzieriNumar.Value >= 1)
                {
                    dti += 0.05m;
                }
            }

            // Penalizare IFN
            if (request.NrIfn.HasValue && request.NrIfn.Value > 0)
            {
                dti += request.NrIfn.Value * 0.02m;
            }

            // Verifică poprire
            if (request.Poprire == true)
            {
                return new ScoringResult
                {
                    Dti = dti,
                    ScoringLevel = "foarte_scazut",
                    RecommendedLevel = "0%",
                    Reasoning = new List<string> { "Poprire în ultimii 5 ani" }
                };
            }

            // Determină nivelul recomandat
            string recommendedLevel = "40%";
            string scoringLevel;

            if (dti <= 0.30m)
            {
                scoringLevel = "foarte_mare";
            }
            else if (dti <= 0.40m)
            {
                scoringLevel = "mare";
                // Poate primi 50% dacă nu are întârzieri și vechime > 12 luni
                if (request.Intarzieri == false && request.VechimeLuni.HasValue && request.VechimeLuni.Value > 12)
                {
                    recommendedLevel = "50%";
                }
            }
            else if (dti <= 0.50m)
            {
                scoringLevel = "bun";
                recommendedLevel = "50%";
                // Poate primi 55% dacă are istoric excelent
                if (request.Intarzieri == false && 
                    request.VechimeLuni.HasValue && request.VechimeLuni.Value > 12 &&
                    (!request.NrIfn.HasValue || request.NrIfn.Value == 0) &&
                    (!request.NrCrediteBanci.HasValue || request.NrCrediteBanci.Value <= 1))
                {
                    recommendedLevel = "55%";
                }
            }
            else if (dti <= 0.55m)
            {
                scoringLevel = "conditii_speciale";
                recommendedLevel = "55%";
            }
            else
            {
                scoringLevel = "foarte_scazut";
                recommendedLevel = "0%";
            }

            var reasoning = new List<string>();
            if (request.VechimeLuni.HasValue && request.VechimeLuni.Value > 12)
                reasoning.Add("Vechime bună la locul de muncă");
            if (request.Intarzieri == false)
                reasoning.Add("Fără întârzieri");
            if (request.SoldTotal.HasValue && request.SoldTotal.Value < venitTotal * 6)
                reasoning.Add("Sold credite moderat");
            if (dti > 0.55m)
                reasoning.Add("DTI prea mare");

            return new ScoringResult
            {
                Dti = dti,
                ScoringLevel = scoringLevel,
                RecommendedLevel = recommendedLevel,
                Reasoning = reasoning
            };
        }
    }

    public class ScoringRequest
    {
        public decimal SalariuNet { get; set; }
        public bool? BonuriMasa { get; set; }
        public decimal? SumaBonuriMasa { get; set; }
        public int? VechimeLuni { get; set; }
        public int? NrCrediteBanci { get; set; }
        public int? NrIfn { get; set; }
        public bool? Poprire { get; set; }
        public decimal? SoldTotal { get; set; }
        public bool? Intarzieri { get; set; }
        public int? IntarzieriNumar { get; set; }
        public string? CardCredit { get; set; } // JSON
        public string? Overdraft { get; set; } // JSON
        public string? Codebitori { get; set; } // JSON
    }

    public class ScoringResult
    {
        public decimal Dti { get; set; }
        public string ScoringLevel { get; set; } = null!;
        public string RecommendedLevel { get; set; } = null!;
        public List<string> Reasoning { get; set; } = new List<string>();
    }

    public class CardCreditData
    {
        public string Banca { get; set; } = null!;
        public decimal Limita { get; set; }
    }

    public class OverdraftData
    {
        public string Banca { get; set; } = null!;
        public decimal Limita { get; set; }
    }

    public class CodebitorData
    {
        public string Nume { get; set; } = null!;
        public decimal Venit { get; set; }
        public string Relatie { get; set; } = null!;
        public int NrCredite { get; set; }
        public int Ifn { get; set; }
    }
}

