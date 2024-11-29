interface IVisitor
{
    void visit(Banka banka);
    void visit(Domacnost domacnost);
    void visit(Tovarna tovarna);
}

class PojistovakSenior : IVisitor
{
    public void visit(Banka banka)
    {
        Console.WriteLine("Nabizim pojisteni proti loupěži");
    }
    
    public void visit(Domacnost domacnost)
    {
        Console.WriteLine("Nabizim pojisteni domacnosti");
    }
    
    public void visit(Tovarna tovarna)
    {
        Console.WriteLine("Nabizim pojisteni když zaměstnance rozmáčkne hydraulický lis");
    }
}

class PojistovakJunior : IVisitor
{
    public void visit(Banka banka)
    {
        Console.WriteLine("Nabizim pojisteni proti loupeží,ale špatný protože to neumim");
    }
    
    public void visit(Domacnost domacnost)
    {
        Console.WriteLine("Nabizim pojisteni domacnosti,ale špatný protože to neumim");
    }
    
    public void visit(Tovarna tovarna)
    {
        Console.WriteLine("Nabizim pojisteni když zaměstnance rozmáčkne hydraulický lis,ale špatný protože to neumim");
    }
}

interface IElement
{
    void accept(IVisitor visitor);
}

class Banka : IElement
{
    public void accept(IVisitor visitor)
    {
        visitor.visit(this);
    }
}

class Domacnost : IElement
{
    public void accept(IVisitor visitor)
    {
        visitor.visit(this);
    }
}

class Tovarna : IElement
{
    public void accept(IVisitor visitor)
    {
        visitor.visit(this);
    }
}

class Program
{
    static void Main()
    {
        var pojistovakSenior = new PojistovakSenior();
        var pojistovakJunior = new PojistovakJunior();
        
        var banka = new Banka();
        var domacnost = new Domacnost();
        var tovarna = new Tovarna();
        
        banka.accept(pojistovakSenior);
        domacnost.accept(pojistovakSenior);
        tovarna.accept(pojistovakSenior);
        
        banka.accept(pojistovakJunior);
        domacnost.accept(pojistovakJunior);
        tovarna.accept(pojistovakJunior);
    }
}