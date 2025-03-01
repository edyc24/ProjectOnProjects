using Microsoft.AspNetCore.Mvc;
using iTextSharp.text;
using iTextSharp.text.pdf;
using System.IO;

namespace ProjectOnProjects.Controllers
{
    public class CVController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        [Route("download-cv")]
        public IActionResult DownloadCV(string name, string email, string phone, string address, string education, string experience, string projects, string projectPeriod, string projectDetails, string personalContribution)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                Document document = new Document();
                PdfWriter writer = PdfWriter.GetInstance(document, ms);
                document.Open();

                // Add title
                var titleFont = FontFactory.GetFont("Arial", 20, Font.BOLD);
                var title = new Paragraph("Curriculum Vitae", titleFont)
                {
                    Alignment = Element.ALIGN_CENTER
                };
                document.Add(title);

                // Add logo
                var logo = Image.GetInstance("C:\\Users\\eduardcr\\source\\repos\\ProjectOnProjects\\ProjectOnProjects\\wwwroot\\images\\logo.png");
                logo.Alignment = Image.ALIGN_RIGHT;
                logo.ScaleToFit(100f, 100f);
                document.Add(logo);

                // Add a line separator
                document.Add(new Paragraph("\n"));

                // Add content with paragraph names
                var sectionFont = FontFactory.GetFont("Arial", 14, Font.BOLD);
                var contentFont = FontFactory.GetFont("Arial", 12, Font.NORMAL);

                document.Add(new Paragraph("Personal Information", sectionFont));
                document.Add(new Paragraph("Name: " + name, contentFont));
                document.Add(new Paragraph("Email: " + email, contentFont));
                document.Add(new Paragraph("Phone: " + phone, contentFont));
                document.Add(new Paragraph("Address: " + address, contentFont));
                document.Add(new Paragraph("\n"));

                document.Add(new Paragraph("Education", sectionFont));
                document.Add(new Paragraph(education, contentFont));
                document.Add(new Paragraph("\n"));

                document.Add(new Paragraph("Experience", sectionFont));
                document.Add(new Paragraph(experience, contentFont));
                document.Add(new Paragraph("\n"));

                document.Add(new Paragraph("Projects", sectionFont));
                document.Add(new Paragraph("Project: " + projects, contentFont));
                document.Add(new Paragraph("Project Period: " + projectPeriod, contentFont));
                document.Add(new Paragraph("Project Details: " + projectDetails, contentFont));
                document.Add(new Paragraph("Personal Contribution: " + personalContribution, contentFont));

                document.Close();
                writer.Close();

                return File(ms.ToArray(), "application/pdf", "CV.pdf");
            }
        }
    }
}
