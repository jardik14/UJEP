class Singleton
{
    private static Singleton? _instance;

    private Singleton()
    {
    }

    public static Singleton GetInstance()
    {
        if (Singleton._instance == null)
        {
            Console.WriteLine("Creating new instance");
            Singleton._instance = new Singleton();
        }
        else
        {
            Console.WriteLine("Returning instance");
        }
        return _instance;
    }
}
static class Program {
    public static void Main()
    {
        var s1 = Singleton.GetInstance();
        var s2 = Singleton.GetInstance();
        var s3 = Singleton.GetInstance();
        
    }
}