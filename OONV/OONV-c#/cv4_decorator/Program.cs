public interface IComponent {
    void Operation();
}

public abstract class Peripherials : IComponent
{
    private IComponent wrappee;
    public Peripherials(IComponent wrappee) {
        this.wrappee = wrappee;
    }
    public virtual void Operation() {
        wrappee.Operation();
    }
}

public class CoffeeBrewer : IComponent {
    public void Operation() {
        System.Console.WriteLine("Brewing coffee.");
    }
}

public class MilkFoamer : Peripherials {
    public MilkFoamer(IComponent wrappee) : base(wrappee) {}
    public override void Operation() {
        base.Operation();
        extraOperation();
    }

    private void extraOperation()
    {
        System.Console.WriteLine("Adding milk foam");
    }

}

public class SugarDispenser : Peripherials {
    public SugarDispenser(IComponent wrappee) : base(wrappee) {}
    public override void Operation() {
        base.Operation();
        extraOperation();
    }

    private void extraOperation()
    {
        System.Console.WriteLine("Dispensing sugar");
    }
}

class Program
{   
    static void Main()
    {
        IComponent coffeeBrewer = new CoffeeBrewer();
        IComponent milkFoamer = new MilkFoamer(coffeeBrewer);
        IComponent sugarDispenser = new SugarDispenser(milkFoamer);
        sugarDispenser.Operation();
        
        Console.WriteLine("a ted obracene");
        
        IComponent coffeeBrewer2 = new CoffeeBrewer();
        IComponent sugarDispenser2 = new SugarDispenser(coffeeBrewer2);
        IComponent milkFoamer2 = new MilkFoamer(sugarDispenser2);
        
        milkFoamer2.Operation();
    }
}