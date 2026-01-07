
using Microsoft.AspNetCore.Http;

namespace MoneyShop.Common;

public class PdfConverter
{
    public async Task<byte[]> ConvertPdfAsync(IFormFile pdfFile)
    {
        if (pdfFile == null || pdfFile.Length == 0) return null;

        using (var memoryStream = new MemoryStream())
        {
            await pdfFile.CopyToAsync(memoryStream);
            return memoryStream.ToArray();
        }
    }
}