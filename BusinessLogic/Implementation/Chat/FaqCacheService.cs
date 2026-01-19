using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess;
using MoneyShop.Entities.Entities;

namespace MoneyShop.BusinessLogic.Implementation.Chat
{
    public class FaqCacheService : BaseService
    {
        private readonly ILogger<FaqCacheService> _logger;
        private const double MinSimilarityThreshold = 0.55;

        public FaqCacheService(
            ServiceDependencies dependencies,
            ILogger<FaqCacheService> _logger)
            : base(dependencies)
        {
            this._logger = _logger;
        }

        public async Task<(bool Hit, FaqItem? Item, double? Score)> MatchFaqAsync(string userMessage)
        {
            if (string.IsNullOrWhiteSpace(userMessage) || userMessage.Length < 8)
                return (false, null, null);

            var normalizedMessage = NormalizeRoNoDiacritics(userMessage);

            var faqItems = await UnitOfWork.Context.Set<FaqItem>()
                .Where(f => f.Enabled)
                .ToListAsync();

            // 1) Exact match pe question / aliases
            foreach (var item in faqItems)
            {
                var normalizedQuestion = NormalizeRoNoDiacritics(item.Question);
                if (normalizedMessage == normalizedQuestion)
                    return (true, item, 1.0);

                var aliases = ParseJsonArray(item.AliasesJson);
                foreach (var alias in aliases)
                {
                    if (normalizedMessage == NormalizeRoNoDiacritics(alias))
                        return (true, item, 1.0);
                }
            }

            // 2) Fuzzy match (Jaccard similarity) + priority bonus
            FaqItem? bestItem = null;
            double bestScore = 0;

            foreach (var item in faqItems)
            {
                var candidates = new List<string> { item.Question };
                candidates.AddRange(ParseJsonArray(item.AliasesJson));

                double localBest = 0;
                foreach (var candidate in candidates)
                {
                    var similarity = JaccardSimilarity(normalizedMessage, NormalizeRoNoDiacritics(candidate));
                    if (similarity > localBest)
                        localBest = similarity;
                }

                // Priority bonus (max 0.08)
                var priorityBonus = Math.Min(0.08, item.Priority * 0.005);
                var boostedScore = localBest + priorityBonus;

                if (boostedScore > bestScore)
                {
                    bestScore = boostedScore;
                    bestItem = item;
                }
            }

            if (bestItem != null && bestScore >= MinSimilarityThreshold)
                return (true, bestItem, bestScore);

            return (false, null, null);
        }

        private static string NormalizeRoNoDiacritics(string text)
        {
            if (string.IsNullOrEmpty(text))
                return string.Empty;

            var result = Regex.Replace(
                text
                    .ToLowerInvariant()
                    .Replace("ă", "a")
                    .Replace("â", "a")
                    .Replace("î", "i")
                    .Replace("ș", "s")
                    .Replace("ț", "t")
                    .Replace("ş", "s")
                    .Replace("ţ", "t"),
                @"[^a-z0-9\s]", " ");
            
            // Normalize multiple spaces
            return Regex.Replace(result, @"\s+", " ").Trim();
        }

        private static double JaccardSimilarity(string a, string b)
        {
            var setA = new HashSet<string>(a.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries));
            var setB = new HashSet<string>(b.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries));

            if (setA.Count == 0 || setB.Count == 0)
                return 0;

            var intersection = setA.Intersect(setB).Count();
            var union = setA.Union(setB).Count();

            return union > 0 ? (double)intersection / union : 0;
        }

        private static List<string> ParseJsonArray(string? json)
        {
            if (string.IsNullOrWhiteSpace(json))
                return new List<string>();

            try
            {
                var array = JsonSerializer.Deserialize<string[]>(json);
                return array?.ToList() ?? new List<string>();
            }
            catch
            {
                return new List<string>();
            }
        }
    }
}

