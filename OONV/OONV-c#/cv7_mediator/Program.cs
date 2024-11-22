interface IMediator
{
    void Notify(Object sender, string message, int damage = 0, IDamageable? reciever = null);
}

class DamageMediator : IMediator
{
    public void Notify(Object sender, string message, int damage, IDamageable? reciever = null)
    {
        if (reciever != null)
        {
            Console.WriteLine($"Received message: {message} from {sender} to {reciever} with damage: {damage}");
            reciever.ReceiveDamage(damage);
        }
        else if (damage == 0)
        {
            Console.WriteLine($"Received message: {message} from {sender}");
        }
        else
        {
            Console.WriteLine($"Received message: {message} from {sender} with damage: {damage}");
        }
    }
}

class Trap
{
    private IMediator _mediator;

    public Trap(IMediator mediator)
    {
        _mediator = mediator;
    }

    public void Trigger(IDamageable prey)
    {
        _mediator.Notify(this, "Trap triggered", 10, prey);
    }
}

interface IDamageable
{  
    void ReceiveDamage(int damage);
}

class Hero : IDamageable
{
    private IMediator _mediator;

    public string Name { get; set; }
    public int Health { get; set; }

    public Hero(string name, int health, IMediator mediator)
    {
        Name = name;
        Health = health;
        _mediator = mediator;
    }

    public void ShowHealth()
    {
        Console.WriteLine($"{Name} has {Health} HP");
    }

    public void ReceiveDamage(int damage)
    {
        _mediator.Notify(this, "Received damage", damage);
        Health -= damage;
    }
}

class Wolf : IDamageable
{
    protected IMediator _mediator;

    public string Name { get; set; }
    public int Health { get; set; }

    public Wolf(string name, int health, IMediator mediator)
    {
        Name = name;
        Health = health;
        _mediator = mediator;
    }

    public void ShowHealth()
    {
        Console.WriteLine($"{Name} has {Health} HP");
    }
    
    public void Bite(IDamageable? prey)
    {
        _mediator.Notify(this, "Bite", 5, prey);
    }

    public void ReceiveDamage(int damage)
    {
        _mediator.Notify(this, "Received damage", damage);
        Health -= damage;
    }
}

class Program
{
    static void Main()
    {
        var mediator = new DamageMediator();
        var hero = new Hero("Hero", 100, mediator);
        var wolf = new Wolf("Wolf", 50, mediator);
        var trap = new Trap(mediator);

        hero.ShowHealth();
        wolf.ShowHealth();

        trap.Trigger(hero);
        trap.Trigger(wolf);
        wolf.Bite(hero);

        hero.ShowHealth();
        wolf.ShowHealth();
    }
}
