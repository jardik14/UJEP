// E-Commerce System
//     Visitor Pattern: Used to calculate discounts or tax on different types of products (e.g., electronics, clothing, groceries).
//     Factory Pattern: To create different types of products dynamically.
//     Decorator Pattern: To add additional features to a product, such as gift wrapping or extended warranty.

public interface IComponent {
    void Operation();
}

public abstract class ExtraStuff : IComponent
{
    private IComponent wrappee;
    public ExtraStuff(IComponent wrappee) {
        this.wrappee = wrappee;
    }
    public virtual void Operation() {
        wrappee.Operation();
    }
}

public class GiftWrapping : ExtraStuff {
    public GiftWrapping(IComponent wrappee) : base(wrappee) {}
    public override void Operation() {
        base.Operation();
        extraOperation();
    }

    private void extraOperation()
    {
        Console.WriteLine("with Gift wrapping"); 
    }

}

public class ExtendedWarranty : ExtraStuff {
    public ExtendedWarranty(IComponent wrappee) : base(wrappee) {}
    public override void Operation() {
        base.Operation();
        extraOperation();
    }

    private void extraOperation()
    {
        Console.WriteLine("with Extended warranty");
    }

}
interface IProduct
{
    void Accept(IVisitor visitor);
}

class Book : IProduct, IComponent
{
    private string name;
    public Book(string name)
    {
        this.name = name;
    }
    
    public string Name
    {
        get { return name; }
    }

    public void Accept(IVisitor visitor)
    {
        visitor.Visit(this);
    }
    
    public void Operation() {
        Console.WriteLine(name);
    }
}

class Clothing : IProduct, IComponent
{
    private string name;
    
    public Clothing(string name)
    {
        this.name = name;
    }
    
    public string Name
    {
        get { return name; }
    }
    
    public void Accept(IVisitor visitor)
    {
        visitor.Visit(this);
    }
    
    public void Operation() {
        Console.WriteLine(name);
    }
}

class Electronics : IProduct, IComponent
{
    private string name;
    public Electronics(string name)
    {
        this.name = name;
    }
    
    public string Name
    {
        get { return name; }
    }
    public void Accept(IVisitor visitor)
    {
        visitor.Visit(this);
    }
    
    public void Operation() {
        Console.WriteLine(name);
    }
}

interface IVisitor
{
    void Visit(Book book);
    void Visit(Clothing clothing);
    void Visit(Electronics electronics);
}

class ChristmasDiscountCalculator : IVisitor
{
    public void Visit(Book book)
    {
        Console.WriteLine("{0} with Christmas discount", book.Name);
    }

    public void Visit(Clothing clothing)
    {
        Console.WriteLine("{0} with Christmas discount", clothing.Name);
    }

    public void Visit(Electronics electronics)
    {
        Console.WriteLine("{0} with Christmas discount", electronics.Name);
    }
}

class EasterDiscountCalculator : IVisitor
{
    public void Visit(Book book)
    {
        Console.WriteLine("{0} with Easter discount", book.Name);
    }

    public void Visit(Clothing clothing)
    {
        Console.WriteLine("{0} with Easter discount", clothing.Name);
    }

    public void Visit(Electronics electronics)
    {
        Console.WriteLine("{0} with Easter discount", electronics.Name);
    }
}

abstract class ProductFactory
{
    public abstract IProduct CreateProduct(string type);
}

class BookFactory : ProductFactory
{
    public override IProduct CreateProduct(string name)
    {
        Console.WriteLine("Creating Book named: {0}", name);
        return new Book(name);
    }
}

class ClothingFactory : ProductFactory
{
    public override IProduct CreateProduct(string name)
    {
        Console.WriteLine("Creating Clothing named: {0}", name);
        return new Clothing(name);
    }
}

class ElectronicsFactory : ProductFactory
{
    public override IProduct CreateProduct(string name)
    {
        Console.WriteLine("Creating Electronics named: {0}", name);
        return new Electronics(name);
    }
}

class Program
{
    static void Main()
    {
        ProductFactory bookFactory = new BookFactory();
        ProductFactory clothingFactory = new ClothingFactory();
        ProductFactory electronicsFactory = new ElectronicsFactory();
        
        IProduct book = bookFactory.CreateProduct("Bible");
        IProduct clothing = clothingFactory.CreateProduct("Svetr");
        IProduct electronics = electronicsFactory.CreateProduct("Laptop");

        IVisitor christmasDiscountCalculator = new ChristmasDiscountCalculator();
        IVisitor easterDiscountCalculator = new EasterDiscountCalculator();

        book.Accept(christmasDiscountCalculator);
        clothing.Accept(christmasDiscountCalculator);
        electronics.Accept(christmasDiscountCalculator);

        book.Accept(easterDiscountCalculator);
        clothing.Accept(easterDiscountCalculator);
        electronics.Accept(easterDiscountCalculator);
        
        IComponent wrapped_book = new GiftWrapping(book as IComponent);
        wrapped_book.Operation();
        
        IComponent clothing_with_warranty = new ExtendedWarranty(clothing as IComponent);
        clothing_with_warranty.Operation();
        
        IComponent wrapped_book_with_warranty = new ExtendedWarranty(wrapped_book);
        wrapped_book_with_warranty.Operation();
        
        
    }
}

