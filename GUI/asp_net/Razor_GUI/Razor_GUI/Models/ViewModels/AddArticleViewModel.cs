﻿namespace Razor_GUI.Models.ViewModels
{
    public class AddArticleViewModel
    {
        public Guid Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
