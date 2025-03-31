
# Projekt pro předmět GUI zaměřený na .NET Blazor
<details>
<summary>Založení projektu pomocí CMD</summary>

```bash
    dotnet new blazor -n [název_projektu] -f net8.0
```

</details>

<details>
    <summary>Založení pomocí Visual studia</summary>

* Výběr templatu
![Výber šablony](docs/images/vscreate.png)

* Tvorba projektu
![Popis projektu](docs/images/vscreatetwo.png)

* Technická specifika projektu
![Specifika projektu](docs/images/vscreatethree.png)
</details>


# Blazor TODO Aplikace

Tato aplikace je jednoduchý **TODO seznam** vytvořený v Blazor Server. Umožňuje uživateli přidávat, upravovat, mazat a přesouvat úkoly mezi seznamy.

## Požadavky
 - .NET 8 SDK
 - IDE nebo textový editor (doporučujeme VSCode)

### Instalace pro různé operační systémy

<details>

<summary>Windows</summary>
    
 - Stažení: https://dotnet.microsoft.com/en-us/download/dotnet/8.0
 - Instalátor se postará o konfiguraci prostředí.
 - Ověřit instalaci:
```powershell
dotnet --version
```
</details>

<details>
<summary>Linux</summary>

 - Ubuntu/Debian
```bash
sudo apt update && sudo apt install -y dotnet-sdk-8.0
```
 - Arch Linux
```bash
sudo pacman -S dotnet-sdk
```
 - Void Linux
```bash
sudo xbps-install -S dotnet-sdk
```
 - Fedora
```bash
sudo dnf install dotnet-sdk-8.0
```
 - openSUSE
```bash
sudo zypper install dotnet-sdk-8.0
```
 - Ověření instalace
```bash
dotnet --version
```
</details>

<details>
<summary>MacOS</summary>

 - Instalace .NET 8 SDK
```bash
brew install dotnet-sdk
```
 - Ověření instalace
```bash
dotnet --version
```
</details>



## Jak spustit projekt
1. Naklonuj repozitář:
```bash
git clone https://github.com/ValdemarPospisil/Blazor.git
cd Blazor/
```
2. Spusť Blazor Server aplikaci:
```bash
dotnet watch run
```
3. Otevři v prohlížeči *http://localhost:5257*

---

## Funkcionalita
- Přidání nového úkolu
- Přidání nového seznamu úkolů
- Úprava úkolu (název, popis, termín)
- Odstranění úkolu
- Přesouvání úkolů mezi seznamy
- Dynamické rozhraní s [Blazor Bootstrap](https://demos.blazorbootstrap.com/buttons)

---

## Struktura projektu

```plaintext
/Blazor
│── /Components       # UI komponenty a stránky aplikace
│   ├── /Layout       # Rozvržení aplikace
│   │   ├── MainLayout.razor
│   │   ├── NavMenu.razor
│   ├── /Pages        # Stránky aplikace
│   │   ├── Home.razor        # Hlavní stránka
│   │   ├── Todo.razor        # Stránka s Todo aplikací
│   ├── /Shared       # Sdílené komponenty
│   │   ├── TaskItem.razor        # Komponenta pro jednotlivý úkol
│   │   ├── TaskList.razor        # Komponenta pro seznam úkolů
│   │   ├── AddTaskForm.razor     # Komponenta pro přidání úkolu
│   │   ├── TaskItemDetails.razor # Sidebar s detaily úkolu
│   ├── _Imports.razor  # Globální importy Razor komponent
│   ├── App.razor       # Root aplikace
│   ├── Routes.razor    # Definice routování
│── /Data              # Ukládání a správa dat
│   ├── tasks.json     # JSON soubor s uloženými úkoly
│── /Models            # Datové modely
│   ├── TaskListModel.cs  # Model pro seznam úkolů 
│   ├── TaskModel.cs      # Model pro jednotlivý úkol
│── /Services          # Aplikační logika a služby
│   ├── TaskService.cs # Správa úkolů (přidávání, mazání, přesouvání)
│── /wwwroot           # Statické soubory (CSS, obrázky)
│   ├── styles.css     # Vlastní styly aplikace
│── appsettings.Development.json  # Nastavení pro vývoj
│── appsettings.json               # Konfigurace aplikace
│── BlazorDemo.csproj    # Projektový soubor
│── Program.cs           # Hlavní vstupní bod aplikace
│── Blazor.sln           # Solution soubor

```

---

## Sekvenční diagram

```mermaid
sequenceDiagram
    participant User as Uživatel
    participant AddForm as AddForm.razor
    participant TaskList as TaskList.razor
    participant TaskService as TaskService.cs

    User->>TaskList: Klikne na tlačítko "+ Přidat úkol"
    TaskList->>User: Zobrazí AddForm komponentu
    User->>AddForm: Napíše název úkolu a klikne na "Přidat úkol"
    
    alt Název úkolu není prázdný
        AddForm->>TaskList: OnTaskAdded.InvokeAsync(newTaskText) (EventCallback)
        Note right of AddForm: Vyvolání události pro TaskList
        
        TaskList->>TaskService: AddTask(taskListModel.Name, newTaskText)
        Note right of TaskService: Vytvoření instance TaskModel
        TaskService-->>TaskList: Vrátí aktualizovaný seznam úkolů
        
        TaskList->>TaskList: HideAddTaskListInput()
        Note right of TaskList: Skrytí formuláře pro přidání úkolu
        
        TaskList-->>User: Zobrazí aktualizovaný seznam úkolů
    else Název úkolu je prázdný
        AddForm-->>User: Zobrazí chybovou hlášku "Název úkolu nesmí být prázdný."
    end
```

---



## Přidání funkce pro přesouvání úkolů mezi seznamy

V této části doplníme funkcionalitu umožňující přesouvání úkolů mezi seznamy v naší Blazor aplikaci.

### 1. Přidání metody `MoveTask` do `TaskService.cs`
Nejprve vytvoříme metodu, která se postará o přesun úkolu mezi seznamy.

**Soubor:** `TaskService.cs`

```csharp
public void MoveTask(TaskModel task, string targetTaskListName)
{
    var sourceTaskList = taskLists.FirstOrDefault(tl => tl.Name == task.TaskListName);

    if (sourceTaskList != null)
    {
        var targetTaskList = taskLists.FirstOrDefault(tl => tl.Name == targetTaskListName);
        if (targetTaskList != null)
        {
            sourceTaskList.Tasks.Remove(task);
            targetTaskList.Tasks.Add(task);
            task.TaskListName = targetTaskListName;
        }
    }
}
```
 - `FirstOrDefault()` → Vyhledává první prvek v seznamu, který splňuje podmínku. Pokud žádný nenajde, vrátí `null`.
 - **Najdeme původní seznam** (`sourceTaskList`), ve kterém se úkol momentálně nachází.
 - **Najdeme cílový seznam** (`targetTaskList`), do kterého chceme úkol přesunout.
 - Pokud oba seznamy existují:
     - **Odstraníme úkol** ze starého seznamu: `sourceTaskList.Tasks.Remove(task);`
     - **Přidáme úkol** do nového seznamu: `targetTaskList.Tasks.Add(task);`
     - **Aktualizujeme název seznamu** v úkolu (`task.TaskListName = targetTaskListName;`)


### 2. Volání MoveTask v Todo.razor
Nyní vytvoříme metodu, která bude volat `MoveTask` z `TaskService`.

 **Soubor**: `Todo.razor`

```csharp
private void HandleMoveTask((TaskModel task, string targetTaskList) moveTask)
{
    TaskService.MoveTask(moveTask.task, moveTask.targetTaskList);
}
```
- Tato metoda bude sloužit jako handler pro přesun úkolu.


### 3. Přidání podpory pro přesun úkolů do `TaskList.razor`
V TaskList.razor potřebujeme předat metodu HandleMoveTask dětem (TaskItemDetails), aby mohly úkol přesunout.

**Soubor**: `TaskList.razor`

```razor
<TaskItemDetails Task="selectedTask" OnClose="CloseDetails" 
                 OnMoveTask="OnMoveTask" OnRemove="RemoveTask" TaskLists="TaskLists" />

@code {
    [Parameter]
    public EventCallback<(TaskModel task, string targetTaskListName)> OnMoveTask { get; set; }
}
```
 - Přidali jsme nový `[Parameter]` `OnMoveTask`, což je event, který umožní TaskItemDetails zavolat metodu v rodiči (TaskList).

### 4. Implementace přesunu v `TaskItemDetails.razor`
V `TaskItemDetails.razor` musíme přidat UI pro výběr cílového seznamu a tlačítko pro přesun.

**Soubor**: `TaskItemDetails.razor`

```razor
<div class="task-actions mt-4">
    <div class="mb-3">
        <label class="form-label fw-bold">Move to List</label>
        <div class="d-flex gap-2">
            <select @bind="selectedTaskListName" class="form-select">
                @foreach (var taskList in TaskLists)
                {
                    <option value="@taskList.Name">@taskList.Name</option>
                }
            </select>
            <Button @onclick="MoveTask" Color="ButtonColor.Primary" Size="ButtonSize.Small">
                <i class="bi bi-arrow-right-square me-1"></i> Move
            </Button>
        </div>
    </div>
</div>

@code {
    [Parameter] public TaskModel Task { get; set; }
    [Parameter] public List<TaskListModel> TaskLists { get; set; }
    [Parameter] public EventCallback<(TaskModel task, string targetTaskListName)> OnMoveTask { get; set; }

    private string selectedTaskListName;

    protected override void OnParametersSet()
    {
        if (Task != null)
        {
            selectedTaskListName = Task.TaskListName;
        }
    }

    private async Task MoveTask()
    {
        await OnMoveTask.InvokeAsync((Task, selectedTaskListName));
        await OnClose.InvokeAsync();
    }
}
```
 - Dropdown menu (`<select>`) obsahuje seznam existujících TaskListů, kam lze úkol přesunout.
 - Proměnná `selectedTaskListName` uchovává vybraný cíl přesunu.
 - Metoda `MoveTask()`:
     - Volá `OnMoveTask.InvokeAsync()` → předává informace rodiči (`TaskList`).
     - Po úspěšném přesunu zavolá `OnClose.InvokeAsync()`, aby se zavřelo okno detailu úkolu.
 - Použití `OnParametersSet()` → Když se změní `[Parameter] Task`, nastavíme `selectedTaskListName` na aktuální seznam, kde se úkol nachází.


---

# Cvičení 1: Poznámkový blok

### Zadání:
Vytvoř novou Blazor stránku, která umožní uživateli:
1. **Přidat** novou poznámku.
2. **Zobrazit** vytvořené poznámky.
3. **Smazat** existující poznámku.
4. **Upravit** existující poznámku.


<details>
  <summary>💡 Nápověda</summary>

- Použij **`@bind`** k obousměrnému svázání vstupu.
- Ulož poznámky do **`List<string>`** a vykresli je pomocí **`@foreach`**.
- Vše jde udělat v jedný razor stránce
</details>

<details>
    <summary>Část řešení</summary>
    
```razor
@page "/notepad"
<PageTitle>Notepad</PageTitle>
<h3>Notepad</h3>

<div class="mb-3">
    <TextAreaInput/>
    <Button>Add</Button>
</div>

<div class="mb-3"></div>
<ul class="list-group">
    @foreach (var note in Notes)
    {
        <li class="list-group-item d-flex justify-content-between align-items-center">
            @if (note.IsEditing)
            {
                <TextInput/>
                <Button>Save</Button>
            }
            else
            {
                <div class="note-text">
                    @note.Text
                </div>
                <div>
                    <Button>✏️</Button>
                    <Button>🗑️</Button>
                </div>
            }
        </li>
    }
</ul>

@code {
    private List<Note> Notes = new();
    private string newNoteText = "";
 
    private void AddNote()
    {
        ...
    }

    private void RemoveNote(Note note)
    {
        ...
    }

    private void EditNote(Note note)
    {
        ...
    }

    private void SaveEdit(Note note)
    {
        ...
    }

    private class Note
    {
        ...
    }
}

<style>
    .note-text {
        max-height: 100px; 
        overflow: auto;
        white-space: pre-wrap;
        word-wrap: break-word;
    }
</style>
```
</details>

---
# Cvičení 2: Stopky
### Zadání:
Vytoř Blazor stránku, která umožní:
1. **Spustit/Zastavit** stopky
2. **Resetovat čas** ve stopkách
3. **Zaznamenávat a zobrazovat** mezičasy
4. Možnost **smazat** jednotlivý mezičas nebo všechny najednou

<details>
  <summary>💡 Nápověda</summary>
    
- Použij komponentu `System.Timers.Timer` pro aktualizaci času.
- Stopky mohou používat `TimeSpan` pro uchování naměřeného času.
- Pro zobrazení mezičasů lze použít `List<string>`.
</details>


<details>
    <summary>Část řešení</summary>

```razor
@page "/stopwatch"
@rendermode InteractiveServer

<PageTitle>StopWatch</PageTitle>

<h3 style="text-align: center;">⏱ Stopwatch</h3>

<div class="stopwatch">
    <p>Time: ...</p>

    <button>
        @(isRunning ? "⏸ Pause" : "▶ Start")
    </button>
    <button>⏹ Reset</button>
    <button>📍 Add Lap</button>
    <button>Clear Laps</button>

    @if (laps.Count > 0)
    {
        <h4>Laps:</h4>
        <ul>
            @foreach (var lap in laps)
            {
                <li>
                    @lap
                    <button @onclick="() => RemoveLap(lap)">🗑</button>
                </li>
            }
        </ul>
    }
</div>


@code {
    private bool isRunning = false;
    private TimeSpan elapsed = TimeSpan.Zero;
    private System.Timers.Timer timer;
    private DateTime startTime;
    private List<string> laps = new();

    private string formattedTime => elapsed.ToString(@"hh\:mm\:ss\.ff");

    protected override void OnInitialized()
    {
        ...
    }

    private void ToggleTimer()
    {
        ...
    }

    private void OnTimerElapsed(object? sender, System.Timers.ElapsedEventArgs e)
    {
        ...
    }

    private void Reset()
    {
        ...
    }

    private void AddLap()
    {
        ...
    }

    private void RemoveLap(string lap)
    {
        ...
    }

    private void ClearLaps()
    {
        ...
    }

    public void Dispose()
    {
        ...
    }
}


<style>
    .stopwatch {
        max-width: 500px;
        margin: 20px auto;
        padding: 20px;
        background: #f5f5f5;
        border-radius: 10px;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
        font-family: Arial, sans-serif;
    }

    .stopwatch p {
        font-size: 2em;
        text-align: center;
        margin: 10px 0;
    }

    .stopwatch button {
        margin: 5px;
        padding: 8px 12px;
        font-size: 1em;
        border: none;
        border-radius: 5px;
        background-color: #007bff;
        color: white;
        cursor: pointer;
    }

    .stopwatch button:disabled {
        background-color: #aaa;
        cursor: not-allowed;
    }

    .stopwatch ul {
        list-style-type: none;
        padding: 0;
    }

    .stopwatch li {
        margin: 5px 0;
        padding: 5px;
        background-color: #eee;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-radius: 5px;
    }

    .stopwatch li button {
        background-color: #dc3545;
        padding: 4px 8px;
        font-size: 0.9em;
    }
</style>

```
</details>

---
# Cvičení 3: Kolotoč obrázků
### Zadání:
Vytvoř Blazor stránku, která umožní:
1. **Automaticky mění obrázky** každé 3 sekundy
2. **Umožňuje manuální přepínání** mezi obrázky tlačítky
3. **Načítá obrázky** z dané složky (`wwwroot/images/gallery`)
4. **Podporuje nekonečné přepínání** – přechod z posledního obrázku na první a naopak.


<details>
  <summary>💡 Nápověda</summary>
    
- Použij `System.Timers.Timer` pro automatické přepínání.
- Cesty k obrázkům uprav na relativní (`/images/gallery/image.jpg`)
- `StateHasChanged()` způsobí překreslení komponenty při změně obrázku.
- Pro zamezení memory leaků zruš timer v `Dispose()`.
</details>


<details>
  <summary>Část řešení</summary>

**1. Vytvoř komponentu (`ImageCarousel.razor`)**

```razor
@inject IWebHostEnvironment env  

<div class="carousel">  
    <button class="prev" @onclick="Previous">❮</button>  
    <img src="@images[activeIndex]" class="carousel-image" />  
    <button class="next" @onclick="Next">❯</button>  
</div>  
```
**2. Logika komponenty (`@code blok`)**

```razor
@code {  
    [Parameter]  
    public string WorkFolder { get; set; } = "images/gallery";  

    private int activeIndex = 0;  
    private List<string> images = new();  
    private System.Timers.Timer? timer;  

    protected override void OnInitialized()  
    {  
        string fullPath = Path.Combine(env.WebRootPath, WorkFolder.Replace("/", Path.DirectorySeparatorChar.ToString()));  
        if (Directory.Exists(fullPath))  
        {  
            images = Directory.GetFiles(fullPath, "*.jpg").Select(img =>  
                Path.Combine("/", WorkFolder, Path.GetFileName(img))).ToList();  
        }  

        timer = new System.Timers.Timer(3000);  
        timer.Elapsed += (sender, e) => InvokeAsync(Next);  
        timer.AutoReset = true;  
        timer.Start();  
    }  

    private void Next()  
    {  
        ...;
    }  

    private void Previous()  
    {  
        ...;
    }  

    private void RestartTimer()  
    {
        ...;
    }  

    public void Dispose() => timer?.Dispose();  
}  
```

**3. Styly pro vizuální úpravu (`<style>`)**
```css
<style>  
    .carousel {  
        position: relative;  
        width: 800px;  
        height: 400px;  
        margin: auto;  
        overflow: hidden;  
    }  

    .carousel-image {  
        width: 100%;  
        height: 100%;  
        object-fit: cover;  
        border-radius: 10px;  
    }  

    .prev,  
    .next {  
        position: absolute;  
        top: 50%;  
        transform: translateY(-50%);  
        background: rgba(0, 0, 0, 0.5);  
        color: white;  
        border: none;  
        padding: 10px;  
        cursor: pointer;  
        font-size: 20px;  
    }  

    .prev {  
        left: 10px;  
    }  

    .next {  
        right: 10px;  
    }  
</style>  
```
</details>

---

# Cvičení 4: Galerie obrázků
### Zadání:
Vytvoř Blazor stránku, která umožní:
1. **Načíst** obrázky
2. **Vykreslit** obrázky
3. **Prohlédnout konkrétní obrázek**
4. **Klávesové ovládání** prohlížení obrázků
4. **Subúkol**: mansory rozložení pomocí blazoru a čistého css


<details>
  <summary>💡 Nápověda</summary>

- Obrázky načítej pomocí **Service** a vykresluj pomocí cyklu v **HTML** značkách
- Pro otevření obrázku vytvoř overlay přes existující galerii
- pro klávesové ovládání budeš potřebovat registrovat vstupy z klávesnice pomocí **`KeyboardEventArgs`**
</details>

<details>
  <summary>Část řešení</summary>

**1. Vytvoříme si razor stránku, kde budeme naší galerii volat**
```razor
@page "/gallery"

<h3>Galerie</h3>

<ImageGrid />
```

2. **Vytvoříme komponentu `ImageGrid.razor`**

    - název je volitelný, ale potřeba upravit i v předešlém kroku

    <details>
        <summary>Kód</summary>

    ```csharp
    @code {
        private List<string> images = new List<string>();
        private int selectedIndex = -1;
        private ElementReference overlayElement;
        private string? path;


        protected override async Task OnInitializedAsync()
        {
            ...;
        }

        private async Task OpenImage(int index)
        {
            ...;
        }

        private async Task FocusOverlay()
        {
            ...;
        }

        private void CloseImage()
        {
            ...;
        }

        private void PreviousImage()
        {
            ...;
        }

        private void NextImage()
        {
            ...;
        }

        private async Task HandleKeyDown(KeyboardEventArgs e)
        {
            ...;
        }
    }
    ```
    </details>

    ### Kód je zde trochu delší, ale pojďme si ho rozklíčovat:

    **`OnInitializedAsync`**
    - Spouští se automaticky při inicializaci komponenty.

    **`OpenImage`**
    - Otevře náhled konkrétního obrázku.

    **`FocusOverlay`**
    - Zaostří overlay prvek kvůli ovládání klávesnicí.

    **`CloseImage`**
    - Zavře náhled obrázku (overlay).

    **`PreviousImage`**
    - Posune výběr na předchozí obrázek.

    **`NextImage`**
    - Posune výběr na další obrázek.

    **`HandleKeyDown`**
    - Zpracovává stisknuté klávesy při aktivním overlay.

3. **Dále v naší komponentě udělejme strukturu stránky**

    <details>
        <summary>Kód</summary>


    ```csharp
    @if (images.Count == 0)
    {
        <p>Žádné obrázky nejsou k dispozici.</p>
    }
    else
    {
        <div class="gallery">
            @foreach (var img in images.Select((path, index) => new { path, index })) 
            {
                <div class="gallery-item">
                    <img src="@img.path" @onclick="() => OpenImage(img.index)" />
                </div>
            }
        </div>
    }

    @if (selectedIndex != -1)
    {
        <div class="gal-overlay" tabindex="0" @onkeydown="HandleKeyDown" @ref="overlayElement">
            <button class="gal-nav-btn left" @onclick="PreviousImage">&#9665;</button>

            <img src="@images[selectedIndex]" @onclick="CloseImage" />

            <button class="gal-nav-btn right" @onclick="NextImage">&#9655;</button>
        </div>
    }
    ``` 
    </details>

4. **Dále v naší komponentě udělejme vzhled stránky:**


    <details>
        <summary>Kód</summary>

    ```css
    <style>
        .gallery {
            column-count: 5;
            column-gap: 1rem;
            padding: 1rem;
        }
        @@media (max-width: 1200px) {
            .gallery {
                column-count: 4;
            }
        }

        @@media (max-width: 992px) {
            .gallery {
                column-count: 3;
            }
        }

        @@media (max-width: 768px) {
            .gallery {
                column-count: 2;
            }
        
        }

        .gallery-item {
            break-inside: avoid;
            margin-bottom: 1rem;
            background-color: #f8f8f8;
            border-radius: 0.5rem;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .gallery-item img {
            width: 100%;
            display: block;
        }

        .gallery img {
            transition: transform 0.2s;
        }

        .gallery img:hover {
            transform: scale(1.05);
        }

        .gal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .gal-overlay img {
            max-width: 80%;
            max-height: 80%;
            border-radius: 10px;
        }

        .gal-nav-btn {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            background: rgba(255, 255, 255, 0.5);
            border: none;
            font-size: 24px;
            cursor: pointer;
            padding: 10px;
            border-radius: 50%;
        }

        .gal-nav-btn.left {
            left: 20px;
        }

        .gal-nav-btn.right {
            right: 20px;
        }
    </style>
    ```
    </details>
