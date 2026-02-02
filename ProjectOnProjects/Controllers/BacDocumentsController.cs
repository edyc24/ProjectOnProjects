using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.BacDocumentService;
using MoneyShop.Code.Base;
using MoneyShop.WebApp.Code.Base;

namespace MoneyShop.Controllers
{
    public class BacDocumentsController : BaseController
    {
        private readonly BacDocumentService _service;

        public BacDocumentsController(ControllerDependencies dependencies, BacDocumentService service)
            : base(dependencies)
        {
            _service = service;
        }

        public IActionResult Index()
        {
            var documents = _service.GetAllDocuments();
            return View(documents);
        }
    }
}