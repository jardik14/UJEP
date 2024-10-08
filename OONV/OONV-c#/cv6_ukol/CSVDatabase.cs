using System.Runtime.CompilerServices;

namespace cv6_ukol;

// Vytvořte třídu CSVDatabáze.
// Třída bude obsahovat jeden atribut: cesta_k_csv_souboru.
public class CsvDatabase
{
    private static CsvDatabase? _instance;
    
    public string PathToCsvFile { get; private set; }
    

    private CsvDatabase(string pathToCsvFile)
    {
        this.PathToCsvFile = pathToCsvFile;
    }

    public static CsvDatabase GetInstance(string pathToCsvFile)
    {
        if (CsvDatabase._instance == null)
        {
            CsvDatabase._instance = new CsvDatabase(pathToCsvFile);
        }
        return _instance;
    }
}