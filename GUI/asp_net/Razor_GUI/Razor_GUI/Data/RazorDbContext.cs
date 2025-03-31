using Microsoft.EntityFrameworkCore;
using Razor_GUI.Models.Entities;

namespace Razor_GUI.Data
{
    public class RazorDbContext : DbContext
    {
        public RazorDbContext(DbContextOptions<RazorDbContext> options) : base(options)
        {
            
        }

        public DbSet<Article> Articles { get; set; }
    }
}
