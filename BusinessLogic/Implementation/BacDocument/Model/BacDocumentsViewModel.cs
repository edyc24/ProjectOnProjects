using System.Collections.Generic;

namespace MoneyShop.BusinessLogic.Implementation.BacDocumentService.Models
{
    public class BacDocumentsViewModel
    {
        public List<string> RomanianDocuments { get; set; } = new List<string>();
        public List<string> MathDocuments { get; set; } = new List<string>();
        public List<string> PhysicsInfoDocuments { get; set; } = new List<string>();
    }
}