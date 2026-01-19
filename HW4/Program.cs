using Microsoft.Extensions.Configuration;

var builder = WebApplication.CreateBuilder(args);

// Add User Secrets for development
if (builder.Environment.IsDevelopment())
{
    builder.Configuration.AddUserSecrets<Program>();
}

// Add services
builder.Services.AddControllers();
builder.Services.AddHttpClient();

var app = builder.Build();

// Configure pipeline
app.UseRouting();
app.MapControllers();

app.Run();

