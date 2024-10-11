class House {
    private int walls;
    private int doors;
    private int windows;
    private int rooms;
    
    public House() {
        this.walls = 0;
        this.doors = 0;
        this.windows = 0;
        this.rooms = 0;
    }
    
    public void SetWalls(int walls) {
        this.walls = walls;
    }
    
    public void SetDoors(int doors) {
        this.doors = doors;
    }
    
    public void SetWindows(int windows) {
        this.windows = windows;
    }
    
    public void SetRooms(int rooms) {
        this.rooms = rooms;
    }
    
    public string GetHouse() {
        return $"House has {walls} walls, {doors} doors, {windows} windows and {rooms} rooms.";
    }
}


interface IBuilder {
    void Reset();
    void BuildPartA();
    void BuildPartB();
    void BuildPartC();
}

class UsteckejBuilder : IBuilder {
    private House house;
    
    public UsteckejBuilder() {
        this.Reset();
    }
    
    public void Reset() {
        house = new House();
    }
    
    public void BuildPartA() {
        System.Console.WriteLine("Building part A po Ustecku");
        this.house.SetWalls(5);
    }
    public void BuildPartB() {
        System.Console.WriteLine("Building part B po Ustecku");
        this.house.SetDoors(2);
    }
    public void BuildPartC() {
        System.Console.WriteLine("Building part C po Ustecku");
        this.house.SetWindows(3);
    }
    public void DejSiPiko() {
        System.Console.WriteLine("Piko mňam");
    }
    
    public House GetHouse() {
        return this.house;
    }
}

class PlzenskejBuilder : IBuilder {
    private House house;
    
    public PlzenskejBuilder() {
        this.Reset();
    }
    
    public void Reset() {
        house = new House();
    }
    public void BuildPartA() {
        System.Console.WriteLine("Building part A po Plzensku");
        this.house.SetWalls(4);
    }
    public void BuildPartB() {
        System.Console.WriteLine("Building part B po Plzensku");
        this.house.SetDoors(3);
    }
    public void BuildPartC() {
        System.Console.WriteLine("Building part C po Plzensku");
        this.house.SetWindows(4);
        this.house.SetRooms(2);
    }
    public void DejSiPivo() {
        System.Console.WriteLine("Pivo mňam");
    }
    
    public House GetHouse() {
        return this.house;
    }
}

class StavbyVedouci {
    private IBuilder builder;
    public StavbyVedouci(IBuilder builder) {
        this.builder = builder;
    }
    public void ChangeBuilder(IBuilder builder) {
        this.builder = builder;
    }

    public void Construct()
    {
        builder.Reset();
        builder.BuildPartA();
        builder.BuildPartB();
        builder.BuildPartC();
    }
}


static class Program {
    public static void Main()
    {   
        var usteckejBuilder = new UsteckejBuilder();
        var plzenskejBuilder = new PlzenskejBuilder();
        
        var stavbyVedouci = new StavbyVedouci(usteckejBuilder);
        stavbyVedouci.Construct();
        House h = usteckejBuilder.GetHouse();
        Console.WriteLine(h.GetHouse());
        
        
        stavbyVedouci.ChangeBuilder(plzenskejBuilder);
        stavbyVedouci.Construct();
        plzenskejBuilder.DejSiPivo();
        House h2 = plzenskejBuilder.GetHouse();
        Console.WriteLine(h2.GetHouse());
        
    }
}