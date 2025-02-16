using ProjectOnProjects.Common.Exceptions;
using FluentValidation.Results;

namespace ProjectOnProjects.Common.Extensions;

public static class ValidationExtensions
{
    public static void ThenThrow(this ValidationResult result, object model)
    {
        if (!result.IsValid) throw new ValidationErrorException(result, model);
    }
}