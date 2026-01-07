using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SubjectService = MoneyShop.BusinessLogic.Implementation.Subject.SubjectService;
using System.Security.Claims;

namespace MoneyShop.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class SubjectController : ControllerBase
    {
        private readonly SubjectService _subjectService;

        public SubjectController(SubjectService subjectService)
        {
            _subjectService = subjectService;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                throw new UnauthorizedAccessException("Invalid user");
            }
            return userId;
        }

        /// <summary>
        /// Create or get subject_id for current user based on CNP
        /// </summary>
        [HttpPost("create")]
        public IActionResult CreateSubject([FromBody] SubjectCreateModel model)
        {
            if (model == null || string.IsNullOrEmpty(model.Cnp))
            {
                return BadRequest(new { message = "CNP is required" });
            }

            try
            {
                var userId = GetUserId();
                var result = _subjectService.GetOrCreateSubject(userId, model.Cnp);

                return Ok(new
                {
                    subjectId = result.SubjectId,
                    cnpMasked = result.CnpMasked,
                    isNew = result.IsNew
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Get subject information for current user
        /// </summary>
        [HttpGet("me")]
        public IActionResult GetMySubject()
        {
            try
            {
                var userId = GetUserId();
                var result = _subjectService.GetSubjectByUserId(userId);

                if (result == null)
                {
                    return NotFound(new { message = "Subject not found" });
                }

                return Ok(new
                {
                    subjectId = result.SubjectId,
                    cnpMasked = result.CnpMasked
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Get subject by subject_id (for admin/internal use)
        /// </summary>
        [HttpGet("{subjectId}")]
        [Authorize(Roles = "Admin")]
        public IActionResult GetSubject(string subjectId)
        {
            try
            {
                var result = _subjectService.GetSubjectById(subjectId);

                if (result == null)
                {
                    return NotFound(new { message = "Subject not found" });
                }

                return Ok(new
                {
                    subjectId = result.SubjectId,
                    cnpMasked = result.CnpMasked
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }

    public class SubjectCreateModel
    {
        public string Cnp { get; set; } = null!;
    }
}

