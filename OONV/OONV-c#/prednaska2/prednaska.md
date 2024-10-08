# Polymorfismus
## Statický polymorfismus 
= řeší se v době překladu
### Přetypování
sin(a) číselný typ -> double
- implicitní přetypování: metoda pro implicitní přetypování
    - Digit -> int 
      - int(Digit): přetypovací konstruktor
      - instanční metoda digit.toInt()
      - u digit lze definovat přetypovací operátor
### Přetěžování
= metody se stejným názvem, ale jinými parametry
- `double sin(double x)`, `double sin(int x)`
```C#
class Zlomek {
    //public Zlomek() {}
    //public Zlomek(int citatel) {}
    public Zlomek(int citatel=0, int jmenovatel=1) {
        this.citatel = citatel;
        this.jmenovatel = jmenovatel;
    }
    public Zlomek(double x, int jm_cislice=100) {}
    public Zlomek(object x) {}
}
```
### Generické typy
= třídy a metody parametrizované pomocí typů
#### `List<T>`
- `List` = generický typ
- `T` = typový parametr
- `Tuple<T1, T2, T3>`
- specializace (dosazení typových parametrů): `List<int>`, `List<string>`

#### Java generika

`ArrayList<int>` = `ArrayList<object>` + dodatečná typová informace

#### C++ generika (šablony)
- chytrá substituce
- Turingovsky kompletní

#### C# generika
- specializace za překladu

## Překlad C#
1. vlastní překlad: překlad před během, překlad do bytecodu
2. překlad po spuštění: překlad do strojového kódu (JIT, AOT)
3. běh programu (runtime)



## Dynamický polymorfismus
= řeší se v době běhu programu

### Dědičnost
```C#
abstract class Zvire {
    public abstract string Hlas();
    public virtual string Jmeno() {}
}

class Pes : Zvire {
    public override string Hlas() {
        return "Haf";
    }
    public override string Jmeno() {
        return "Pes";
    }
}
```
#### Bázová
- `abstract` = nemá smysl vytvářet instanci této třídy
- `virtual` = může být přepsána v potomcích (definovaná)
- `sealed` = nelze předefinovat v potomcích

#### Odvozená
- `override` = přepisuje metodu z předka
- `new` = skrývá metodu z předka (zastínění)

```C#
Zvire z = new Pes();
z.Hlas(); // volá se metoda Pes.Hlas()
z.Jmeno(); // volá se metoda Zvire.Jmeno()
(Pes)z.Jmeno(); // volá se metoda Pes.Jmeno()
```

- dědičnost je jednoduchá: můžeme dědit pouze z jedné třídy -> relace dedičnosti je strom

### Rozhraní (interface)
```C#
interface IFlyable {
    void TakeOff();
    void Land();
    int Altitude { get; }
}

class Dragon : IFlyable, Zvire, IEnergySource {
    public void TakeOff() {...}
    public void Land() {...}
    public int Altitude { get; }
}
```

### Duck polymorfismus
`dynamic i = 2;`

`object i = i;`

`var i = 2;`