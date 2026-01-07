namespace MoneyShop.Models
{
    public class BacDocumentModel
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string SubjectType { get; set; }
        public byte[] Content { get; set; }
    }
} 