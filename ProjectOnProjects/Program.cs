using MoneyShop.BusinessLogic;
using MoneyShop.DataAccess;
using MoneyShop.WebApp.Code;
using MoneyShop.BusinessLogic.Base;
using MoneyShop.DataAccess.EntityFramework;
using Microsoft.EntityFrameworkCore;
using MoneyShop.WebApp.Code.ExtensionMethods;
using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

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

builder.Services.AddAuthentication("MoneyShopCookies")
    .AddCookie("MoneyShopCookies", options =>
    {
        options.AccessDeniedPath = new PathString("/Home/Index");
        options.LoginPath = new PathString("/Account/Login");
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

builder.Services.AddScoped<UnitOfWork>();
builder.Services.AddSignalR();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();
app.UseSession();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();