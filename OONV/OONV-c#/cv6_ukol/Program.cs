// Vytvořte dvě instance Analytika a přiřaďte jim singleton CSV soubor.
// Ověřte, že obě instance čtou a zapisují do stejného CSV souboru. Pokud byla cesta k CSV souboru změněna, bude změněna pro oba analytiky.

using cv6_ukol;

static class Program {
    public static void Main()
    {   
        var analyst1 = new Analyst(CsvDatabase.GetInstance("D:/Programko/UJEP/OONV/OONV-c#/cv6_ukol/db.csv"));
        Console.WriteLine(analyst1.db.PathToCsvFile);
        var analyst2 = new Analyst(CsvDatabase.GetInstance("D:/Programko/UJEP/OONV/OONV-c#/cv6_ukol/db_alt.csv"));
        Console.WriteLine(analyst2.db.PathToCsvFile);
        
        analyst1.EraseCsv();
        
        analyst1.WriteToCsv("Ahoj ja jsem Pepa\n");
        analyst2.WriteToCsv("Ahoj ja jsem Franta\n");
        
        Console.WriteLine(analyst1.ReadFromCsv());
        Console.WriteLine(analyst2.ReadFromCsv());
    }
}