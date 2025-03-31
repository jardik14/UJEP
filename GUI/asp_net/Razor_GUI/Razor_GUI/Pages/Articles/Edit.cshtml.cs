using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Razor_GUI.Data;
using Razor_GUI.Models.ViewModels;

namespace Razor_GUI.Pages.Articles
{
    public class EditModel : PageModel
    {

        public EditArticleViewModel EditArticleViewModel { get; set; }
        private readonly RazorDbContext dbContext;
        public EditModel()
        {
            this.dbContext = dbContext;
        }

        public void OnGet(Guid id)
        {
            var article = dbContext.Articles.Find(id);
            if (article != null)
            {
                EditArticleViewModel = new EditArticleViewModel
                {
                    Id = article.Id,
                    Title = article.Title,
                    Description = article.Description,
                    CreatedAt = article.CreatedAt,
                };
            }
        }

        public void OnPostEdit() 
        { 
            if (EditArticleViewModel != null)
            {
                var theArticle = dbContext.Articles.Find(EditArticleViewModel.Id);
                if (theArticle != null)
                {
                    theArticle.Title = EditArticleViewModel.Title;
                    theArticle.Description = EditArticleViewModel.Description;

                    dbContext.SaveChanges();

                    ViewData["Message"] = "Article updated successfully";
                }
                
            }
        }

        public IActionResult OnPostDelete()
        {
            var article = dbContext.Articles.Find(EditArticleViewModel.Id);
            if (article != null)
            {
                dbContext.Articles.Remove(article);
                dbContext.SaveChanges();
                return RedirectToPage("/Articles/List");
            }
            return Page();
        }
    }
}
