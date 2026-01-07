using MoneyShop.BusinessLogic;
using MoneyShop.DataAccess;
using MoneyShop.WebApp.Code;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess.EntityFramework;
using Microsoft.EntityFrameworkCore;
using MoneyShop.WebApp.Code.ExtensionMethods;
using MoneyShop.WebApp.Code.Middleware;
using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Http.Features;
using System.Collections.Generic;
using Microsoft.ApplicationInsights.AspNetCore;
using Microsoft.ApplicationInsights.Extensibility;

var builder = WebApplication.CreateBuilder(args);

// Configure Kestrel to listen on all network interfaces for development
if (builder.Environment.IsDevelopment())
{
    // Get local IP from configuration or use localhost only
    var localIp1 = builder.Configuration["LocalIP"]; // Can be set in appsettings.Development.json
    
    var urls = new List<string>
    {
        "https://localhost:7093",
        "http://localhost:5259"
    };
    
    // Add network IP if configured
    if (!string.IsNullOrEmpty(localIp1))
    {
        urls.Add($"https://{localIp1}:7093");
        urls.Add($"http://{localIp1}:5259");
    }
    
    builder.WebHost.UseUrls(urls.ToArray());
    
    // Configure Kestrel server limits for large file uploads
    builder.WebHost.ConfigureKestrel(options =>
    {
        options.Limits.MaxRequestBodySize = 20_000_000; // 20MB max request body size
    });
}

// Add services to the container.
// Note: We keep AddControllersWithViews for Swagger UI, but React Native is the main frontend
builder.Services.AddControllersWithViews();

// Configure form options for large file uploads (base64 images can be very long)
builder.Services.Configure<FormOptions>(options =>
{
    options.ValueLengthLimit = int.MaxValue; // No limit on individual form values
    options.KeyLengthLimit = int.MaxValue; // No limit on form keys
    options.MultipartBodyLengthLimit = 20_000_000; // 20MB total multipart body limit
    options.MultipartBoundaryLengthLimit = int.MaxValue; // No limit on boundary length
    options.MultipartHeadersLengthLimit = int.MaxValue; // No limit on headers length
    options.MultipartHeadersCountLimit = int.MaxValue; // No limit on header count
    options.BufferBodyLengthLimit = 20_000_000; // 20MB buffer limit
    options.BufferBody = true; // Enable buffering
    options.MemoryBufferThreshold = int.MaxValue; // No memory buffer threshold
});

// Add CORS for React Native (web, iOS, Android)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactNative", policy =>
    {
        var origins = new List<string>
        {
            "http://localhost:8081",  // Expo web
            "http://localhost:8082",  // Expo web alternative
            "http://localhost:19006",  // Expo default
            "http://localhost:19000",  // Expo alternative
            "exp://localhost:8081",    // Expo dev client
            "http://127.0.0.1:8081",
            "http://127.0.0.1:8082",
            "http://127.0.0.1:19006"
        };
        
        // Add network IP origins if configured
        var localIp = builder.Configuration["LocalIP"];
        if (!string.IsNullOrEmpty(localIp))
        {
            origins.AddRange(new[]
            {
                $"http://{localIp}:8081",
                $"http://{localIp}:8082",
                $"http://{localIp}:19006",
                $"exp://{localIp}:8081",
                $"http://{localIp}:5259"  // Backend HTTP endpoint
            });
        }
        
        policy.WithOrigins(origins.ToArray())
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
});

// Add API Controllers with JSON options
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Configure JSON serialization to use camelCase
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
    });

// Add Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "MoneyShop API",
        Version = "v1",
        Description = "API for MoneyShop Fintech Platform",
        Contact = new OpenApiContact
        {
            Name = "MoneyShop Support",
            Email = "support@moneyshop.ro"
        }
    });

    // Add JWT Authentication to Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token in the text input below.",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<MoneyShopContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddDistributedMemoryCache();

builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromSeconds(1800);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

builder.Services.AddMoneyShopCurrentUser();
builder.Services.AddPresentation();
builder.Services.AddMoneyShopBusinessLogic();

// JWT Configuration
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"] ?? "MoneyShop_SecretKey_Minimum_32_Characters_Long_For_Security_2024";
var issuer = jwtSettings["Issuer"] ?? "MoneyShop";
var audience = jwtSettings["Audience"] ?? "MoneyShopUsers";

builder.Services.AddAuthentication(options =>
{
    // Use JWT Bearer as default for API, Cookie for MVC
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultSignInScheme = "MoneyShopCookies";
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = issuer,
        ValidAudience = audience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
        ClockSkew = TimeSpan.Zero
    };
    // Don't redirect to login for API requests - return 401 instead
    options.Events = new Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerEvents
    {
        OnChallenge = context =>
        {
            // If this is an API request, don't redirect
            if (context.Request.Path.StartsWithSegments("/api"))
            {
                context.HandleResponse();
                context.Response.StatusCode = 401;
                context.Response.ContentType = "application/json";
                var result = System.Text.Json.JsonSerializer.Serialize(new { message = "Unauthorized" });
                return context.Response.WriteAsync(result);
            }
            return Task.CompletedTask;
        }
    };
})
.AddCookie("MoneyShopCookies", options =>
{
    options.AccessDeniedPath = new PathString("/Home/Index");
    options.LoginPath = new PathString("/Account/Login"); // Using real Account controller
    options.ExpireTimeSpan = TimeSpan.FromDays(30);
    options.SlidingExpiration = true;
});

builder.Services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();

builder.Services.AddControllersWithViews(options =>
{
    options.Filters.Add(typeof(GlobalExceptionFilterAttribute));
});

builder.Services.AddAutoMapper(options =>
{
    options.AddMaps(typeof(Program), typeof(BaseService));
});

// Add Application Insights
var appInsightsConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"];
if (!string.IsNullOrEmpty(appInsightsConnectionString))
{
    builder.Services.AddApplicationInsightsTelemetry(options =>
    {
        options.ConnectionString = appInsightsConnectionString;
    });
    
    // Enable request telemetry
    builder.Services.ConfigureTelemetryModule<Microsoft.ApplicationInsights.Extensibility.Implementation.Tracing.DiagnosticsTelemetryModule>(
        (module, o) => { });
    
    Console.WriteLine("✓ Application Insights configured");
}
else
{
    Console.WriteLine("⚠ Application Insights connection string not found - telemetry disabled");
}

builder.Services.AddScoped<UnitOfWork>();
builder.Services.AddSignalR();

var app = builder.Build();

// Log environment for debugging
Console.WriteLine($"🔧 Environment: {app.Environment.EnvironmentName}");
Console.WriteLine($"🔧 IsDevelopment: {app.Environment.IsDevelopment()}");

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseRouting();

// Enable CORS BEFORE HTTPS redirection to handle preflight requests correctly
app.UseCors("AllowReactNative");

// Custom middleware to handle HTTPS redirection with exceptions
app.Use(async (context, next) =>
{
    // Skip HTTPS redirection for:
    // 1. API endpoints
    // 2. OPTIONS requests (CORS preflight)
    // 3. Requests from local IP (192.168.x.x)
    var shouldSkipHttpsRedirect = context.Request.Path.StartsWithSegments("/api") ||
                                  context.Request.Method == "OPTIONS" ||
                                  context.Request.Host.Host.StartsWith("192.168.");

    if (shouldSkipHttpsRedirect)
    {
        // Skip HTTPS redirection - go directly to next middleware
        await next();
    }
    else
    {
        // Apply HTTPS redirection for other requests
        if (context.Request.Scheme == "http" && 
            (context.Request.Host.Host == "localhost" || context.Request.Host.Host == "127.0.0.1"))
        {
            var httpsUrl = $"https://{context.Request.Host}{context.Request.PathBase}{context.Request.Path}{context.Request.QueryString}";
            context.Response.Redirect(httpsUrl, permanent: false);
            return;
        }
        await next();
    }
});

app.UseStaticFiles();

app.UseSession();

app.UseAuthentication();

// Middleware to prevent redirect to login for API requests
// This must be placed AFTER UseAuthentication but BEFORE UseAuthorization
app.Use(async (context, next) =>
{
    // Store original path for later check
    var originalPath = context.Request.Path;
    
    await next();
    
    // If this is an API request and we got a redirect (302), convert it to 401 JSON
    if (originalPath.StartsWithSegments("/api") && 
        context.Response.StatusCode == 302)
    {
        context.Response.Clear();
        context.Response.StatusCode = 401;
        context.Response.ContentType = "application/json";
        var result = System.Text.Json.JsonSerializer.Serialize(new { message = "Unauthorized" });
        await context.Response.WriteAsync(result);
    }
});

// Auto-login mock user in Development (bypass authentication)
// DISABLED - Now using real database authentication
// if (app.Environment.IsDevelopment())
// {
//     app.UseAutoLoginMockUser();
// }

// Enable Swagger in Development
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "MoneyShop API v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseAuthorization();

// Map API Controllers
app.MapControllers();

// Map MVC Controllers
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// Log the URLs the app is listening on
Console.WriteLine($"🌐 Application URLs:");
Console.WriteLine($"   HTTPS: https://localhost:7093");
Console.WriteLine($"   HTTP: http://localhost:5259");
var localIp2 = builder.Configuration["LocalIP"];
if (!string.IsNullOrEmpty(localIp2))
{
    Console.WriteLine($"   HTTPS (Network): https://{localIp2}:7093");
    Console.WriteLine($"   HTTP (Network): http://{localIp2}:5259");
}
Console.WriteLine($"💡 To enable network access, set 'LocalIP' in appsettings.Development.json");

app.Run();