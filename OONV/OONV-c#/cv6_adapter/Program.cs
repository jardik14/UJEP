using AngleSharp;
using AngleSharp.Dom;
using System.IO;
using System.Text;

class Client
{
    public void ProcessData(string data)
    {
        if (data.Contains("<table>"))
        {
            var adapter = new HTMLTableToCSVAdapter(data);
            var csvData = adapter.ConvertToCSV();
            var csvService = new CSVService();
            csvService.ProcessCSV(csvData);
        }
        else
        {
            var csvService = new CSVService();
            csvService.ProcessCSV(data);
        }
    }
    
}

//Service working with csv 
public class CSVService
{
    public void ProcessCSV(string csvData)
    {
        Console.WriteLine("Processing CSV data:");
        Console.WriteLine(csvData);
    }
}



public class HTMLTableToCSVAdapter
{
    private readonly string _htmlTable;

    public HTMLTableToCSVAdapter(string htmlTable)
    {
        _htmlTable = htmlTable;
    }

    public string ConvertToCSV()
    {
        var csvBuilder = new StringBuilder();

        var config = Configuration.Default;
        var context = BrowsingContext.New(config);
        var document = context.OpenAsync(req => req.Content(_htmlTable)).Result;

        var rows = document.QuerySelectorAll("tr");

        foreach (var row in rows)
        {
            var cells = row.QuerySelectorAll("th, td");
            for (int i = 0; i < cells.Length; i++)
            {
                csvBuilder.Append(cells[i].TextContent.Trim());
                if (i < cells.Length - 1)
                    csvBuilder.Append(",");
            }
            csvBuilder.AppendLine();
        }

        return csvBuilder.ToString();
    }
}

public class Program
{
    public static void Main(string[] args)
    {
        // Sample HTML table
        string htmlTable = @"
            <table>
                <tr><th>Name</th><th>Age</th></tr>
                <tr><td>John Doe</td><td>30</td></tr>
                <tr><td>Jane Smith</td><td>25</td></tr>
            </table>";
        
        var client = new Client();
        client.ProcessData(htmlTable);
        
        string csvData = "Name,Age\nJohn Doe,30\nJane Smith,25";
        client.ProcessData(csvData);
    }
}

