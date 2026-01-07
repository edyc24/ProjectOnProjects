using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MoneyShop.DataAccess.EntityFramework;
using MoneyShop.Entities.Entities;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class TestConnectionController : ControllerBase
    {
        private readonly MoneyShopContext _context;
        private readonly ILogger<TestConnectionController> _logger;
        private readonly IConfiguration _configuration;

        public TestConnectionController(
            MoneyShopContext context, 
            ILogger<TestConnectionController> logger,
            IConfiguration configuration)
        {
            _context = context;
            _logger = logger;
            _configuration = configuration;
        }

        /// <summary>
        /// Test database connection
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> TestConnection()
        {
            try
            {
                var connectionString = _configuration.GetConnectionString("DefaultConnection");
                var connectionStringPreview = connectionString?.Length > 50 
                    ? connectionString.Substring(0, 50) + "..." 
                    : connectionString;

                // Try to connect to database
                var canConnect = await _context.Database.CanConnectAsync();
                
                if (!canConnect)
                {
                    return BadRequest(new
                    {
                        success = false,
                        message = "Cannot connect to database",
                        connectionStringPreview = connectionStringPreview
                    });
                }

                // Try to query database
                var databaseName = _context.Database.GetDbConnection().Database;
                var serverName = _context.Database.GetDbConnection().DataSource;
                
                // Try a simple query
                var roleCount = await _context.Set<Roluri>().CountAsync();
                var userCount = await _context.Set<Utilizatori>().CountAsync();
                
                return Ok(new
                {
                    success = true,
                    message = "Database connection successful",
                    databaseName = databaseName,
                    serverName = serverName,
                    roleCount = roleCount,
                    userCount = userCount,
                    connectionStringPreview = connectionStringPreview
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error testing database connection");
                return StatusCode(500, new
                {
                    success = false,
                    message = "Error testing database connection",
                    error = ex.Message,
                    innerException = ex.InnerException?.Message,
                    stackTrace = ex.StackTrace?.Split('\n').Take(5)
                });
            }
        }
    }
}

