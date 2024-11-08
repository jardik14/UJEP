interface IComponent {
    void execute();
}

class Leaf : IComponent
{
    public void execute()
    {
        System.Console.WriteLine("Leaf executed");
    }
}

class Composite : IComponent
{
    private List<IComponent> children = new List<IComponent>();

    public void add(IComponent component)
    {
        children.Add(component);
    }

    public void remove(IComponent component)
    {
        children.Remove(component);
    }

    public void execute()
    {
        foreach (IComponent component in children)
        {
            component.execute();
        }
    }
}

class Program
{
    static void Main()
    {
        Leaf leaf = new Leaf();
        Composite composite = new Composite();
        composite.add(leaf);
        composite.add(leaf);
        composite.add(leaf);
        composite.execute();
    }
}