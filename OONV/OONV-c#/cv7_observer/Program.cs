interface ISubscriber
{
    void Update(string spell_name, int damage);
}

class Hero : ISubscriber
{
    public string Name { get; set; }
    public int Health { get; set; }

    public Hero(string name, int health)
    {
        Name = name;
        Health = health;
    }
    
    public void ShowHealth()
    {
        Console.WriteLine($"{Name} has {Health} HP");
    }

    public void Update(string spell_name, int damage)
    {
        Console.WriteLine($"{Name} received spell: {spell_name} with damage: {damage}");
        Health -= damage;
    }
}

class Boss
{
    private List<ISubscriber> _subscribers = new List<ISubscriber>();

    public void Subscribe(ISubscriber subscriber)
    {
        _subscribers.Add(subscriber);
    }

    public void Unsubscribe(ISubscriber subscriber)
    {
        _subscribers.Remove(subscriber);
    }

    public void CastSpell(string spell_name, int damage)
    {
        foreach (var subscriber in _subscribers)
        {
            subscriber.Update(spell_name, damage);
        }
    }
}

class Program
{
    static void Main()
    {
        var boss = new Boss();
        var tank = new Hero("Tank", 55);
        var mage = new Hero("Mage", 22);

        boss.Subscribe(tank);
        boss.Subscribe(mage);
        
        boss.CastSpell("Fireball", 10);

        boss.Unsubscribe(mage);
        
    }
}