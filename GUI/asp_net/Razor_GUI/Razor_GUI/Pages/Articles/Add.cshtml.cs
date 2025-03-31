using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Razor_GUI.Data;
using Razor_GUI.Models.ViewModels;
using Razor_GUI.Models.Entities;

namespace Razor_GUI.Pages.Articles
{
    public class AddModel : PageModel
    {
        private readonly RazorDbContext dbContext;

        public AddModel(RazorDbContext dbContext)
        {
            this.dbContext = dbContext;
        }

        [BindProperty]
        public AddArticleViewModel AddArticleRequest { get; set; }

        public void OnGet()
        {
        }

        public void OnPost() 
        {
            AddArticleRequest.CreatedAt = DateTime.Now;

            var articleEntitiesModel = new Article
            {
                Title = AddArticleRequest.Title,
                Description = AddArticleRequest.Description,
                CreatedAt = AddArticleRequest.CreatedAt
            };

            dbContext.Articles.Add(articleEntitiesModel);
            dbContext.SaveChanges();

            ViewData["Message"] = "Article added successfully!";
        }
    }
}
