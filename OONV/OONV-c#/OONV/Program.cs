using System;

static class NaJmeneNezalezi
{
    public static bool IsWord(this string s)
    {
        foreach (var c in s)
        {
            if (!char.IsLetter(c))
            {
                return false;
            }
        }
        return true;
    }

public static void Main()
    {
        Console.WriteLine("Hello, C#!");

        System.Int32 i1;
        Int32 i2;
        int i3;
        var i4 = 1;
        //int, double, uint, short, long, ulong = UInt64, byte = UInt8, sbyte = Int8
        //char (32-byte unicode)
        //string (UTF-16)
        //bool
        
        string? s = Console.ReadLine();
        if (s == null)
        {
            throw new ArgumentException("s is null!");
        }
        Console.WriteLine(s.IsWord() ? "Word" : "Not a word");
        
    }
}