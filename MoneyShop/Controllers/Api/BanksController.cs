using Microsoft.AspNetCore.Mvc;
using MoneyShop.BusinessLogic.Implementation.Bank;
using BankEntity = MoneyShop.Entities.Entities.Bank;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class BanksController : ControllerBase
    {
        private readonly BankService _bankService;

        public BanksController(BankService bankService)
        {
            _bankService = bankService;
        }

        /// <summary>
        /// Get all active banks
        /// </summary>
        [HttpGet]
        public IActionResult GetBanks()
        {
            var banks = _bankService.GetAllBanks();
            return Ok(banks);
        }

        /// <summary>
        /// Get bank by ID
        /// </summary>
        [HttpGet("{id}")]
        public IActionResult GetBank(int id)
        {
            var bank = _bankService.GetBankById(id);
            if (bank == null)
                return NotFound(new { message = "Bank not found" });

            return Ok(bank);
        }
    }
}

