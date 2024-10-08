namespace cv6_ukol;

// Vytvořte třídu Analytik, která umí zapsat a číst z CSV souboru (metody).
//V konstruktoru přiřaďte instancím třídy Analytik CSV soubor, do kterého bude zapisovat nebo z něj bude číst.
public class Analyst
{   
    public CsvDatabase db;

    public Analyst(CsvDatabase db)
    {
        this.db = db;
    }
    
    public void WriteToCsv(string text)
    {
        using (StreamWriter sw = File.AppendText(this.db.PathToCsvFile)){
            sw.Write(text);
        }
    }
    
    public string ReadFromCsv()
    {
        string text = "";
        using (StreamReader sr = File.OpenText(this.db.PathToCsvFile)){
            text = sr.ReadToEnd();
        }
        return text;
    }
    
    public void EraseCsv()
    {   
        File.WriteAllText(this.db.PathToCsvFile, "");
    }

}