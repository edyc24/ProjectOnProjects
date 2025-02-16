using Microsoft.AspNetCore.Mvc;
using ProjectOnProjects.BusinessLogic.Implementation.BacDocumentService;
using ProjectOnProjects.Code.Base;
using ProjectOnProjects.WebApp.Code.Base;

namespace ProjectOnProjects.Controllers
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