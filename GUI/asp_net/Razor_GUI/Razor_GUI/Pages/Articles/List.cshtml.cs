using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Identity.Client;
using Razor_GUI.Data;

namespace Razor_GUI.Pages.Articles
{
    public class ListModel : PageModel
    {
        private readonly RazorDbContext dbContext; 

        public List<Models.Entities.Article> Articles { get; set; }

        public ListModel(RazorDbContext dbContext)
        {
            this.dbContext = dbContext;
        }
        public void OnGet()
        {
            Articles = dbContext.Articles.ToList();
        }
    }
}
