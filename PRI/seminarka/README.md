
# HryStat – semestrální projekt (full‑stack webová aplikace)

*Autor: … (doplňte své jméno a učo)*  
*Datum: 2025-05-26*

---

## 1  Představení projektu
HryStat je jednoduchá „full‑stack“ aplikace pro správu videoher a statistik
odehraných hodin. Slouží jako demonstrace práce s PHP, PostgreSQL, XML/XSD/XSL,
JavaScriptem a Dockerem podle zadání semestrálního projektu.

---

## 2  Architektura

```
docker‑compose
├─ web (Apache + PHP 8.2)
│  ├─ public/
│  │  ├─ index.php          – dashboard
│  │  ├─ add_game.php       – formulář na přidání hry
│  │  ├─ auth/…             – login & register
│  │  └─ assets/            – style.css, main.js
│  ├─ xml/
│  │  ├─ games.xml          – zdrojová data
│  │  ├─ games.xsd          – XSD schéma pro validaci
│  │  └─ games.xsl          – XSLT pro převod XML → HTML
│  └─ sql/init.sql          – seed databáze
└─ db  (PostgreSQL 16)
```

Klient (prohlížeč) načítá HTML stránky generované serverem nebo
transformované z XML pomocí XSLT procesoru integrováného v prohlížeči.
JavaScript se stará o drobné DOM animace a validaci formulářů na klientu.

---

## 3  Instalace a spuštění

### 3.1  Požadavky
- Docker 20+
- Docker Compose v2

### 3.2  První start

```bash
git clone https://…/hrystat.git
cd hrystat
cp .env.example .env            # úprava přístupových hesel
docker compose up --build
```

Web rozhraní poběží na <http://localhost:8080>, databáze naslouchá na `localhost:5432`.

---

## 4  Databázový model

Tabulky:

| Tabulka | Popis                                                 |
|---------|-------------------------------------------------------|
| `users` | registrace uživatelů, hashovaná hesla (`bcrypt`)      |
| `games` | seznam her (`title`, `genre`, `platform`, `released`) |
| `game_stats` | relace Uživatel ↔ Hra, počet odehraných hodin    |

Plné DDL najdete v `sources/sql/init.sql`.

---

## 5  XML ↔ server ↔ klient workflow

1. **Server** sestaví `games.xml` (nebo jej načte z disku).
2. Pomocí `DOMDocument::schemaValidate('games.xsd')` ověří strukturální
   správnost.
3. Pokud klient zažádá o „export“, server vrací XML s PI:
   ```xml
   <?xml-stylesheet type="text/xsl" href="games.xsl"?>
   ```
4. Prohlížeč následně *sám* aplikuje `games.xsl` a zobrazí uživateli
   tabulku her bez nutnosti dalšího HTML.

---

## 6  Struktura repozitáře (výběr)

| Cesta | Účel |
|-------|------|
| `public/index.php` | výpis her, agregované statistiky |
| `public/add_game.php` | HTML + PHP formulář (POST) |
| `public/assets/style.css` | strohé, responsivní CSS (CSS custom properties) |
| `public/assets/main.js` | drobná DOM logika – accordion, validace |
| `xml/games.xml` | primární XML dataset |
| `xml/games.xsd` | schéma pro `games.xml` |
| `xml/games.xsl` | XSLT šablona |
| `sql/init.sql` | vytvoření tabulek + seed dat |

---

## 7  Zabezpečení

- Prepared statements (`PDO`) chrání před SQL‑injection  
- Hesla v tabulce `users` jsou uložena funkcí `password_hash()` (*bcrypt*)  
- **.env** soubor není commitován; do repozitáře patří pouze `.env.example`  
- Docker network izoluje databázi (přístup jen z kontejneru `web`)

---

## 8  Mapování požadavků ↔ implementace

| Požadavek zadání | Implementace v projektu |
|------------------|-------------------------|
| *Full‑stack, od DB po UI* | Docker image `web` (PHP 8.2 + Apache) ↔ Postgres 16 ↔ HTML5/CSS/JS |
| **4+ stránky** | `index`, `add_game`, `login`, `register`, `logout` |
| **Formulář** | `add_game.php` (přidání hry) + `register.php`, `login.php` |
| **Databáze** | Postgres, tabulky `users`, `games`, `game_stats` |
| **XML úložiště / přenos** | `xml/games.xml` + serverový export `export_games.php` |
| **XSD validace** | `games.xsd` + `DOMDocument::schemaValidate()` (viz `lib/XmlService.php`) |
| **XSL transformace** | `games.xsl` pro převod seznamu her na HTML |
| **PHP DOM/simpleXML** | načítání a úpravy `games.xml` (`lib/XmlService.php`) |
| **JS manipulace DOM** | `public/assets/main.js` (accordion) |
| **AJAX (volitelně)** | není nutné; data načítána klasicky, projekt vyhovuje |
| **KISS / DRY / YAGNI** | modulární `lib/` (DB.php, Auth.php, XmlService.php) |
| **Style** | čisté vanilla CSS bez frameworku; tmavý/světlý motiv automaticky |
| **Validace na straně klienta** | HTML attrib. `required`, `pattern`; JS validace dílčí |

---

## 9  Příkazy pro vývoj

```bash
# spuštění testovacího PHP serveru mimo docker
php -S 127.0.0.1:8000 -t public

# přístup do DB v kontejneru
docker compose exec db psql -U postgres hrystat

# spuštění unit testů (PHPUnit)
docker compose exec web vendor/bin/phpunit
```

---

## 10  Známé limity a další rozvoj

- **REST API** zatím chybí; lze snadno doplnit do `api/` pro JS‐based SPA.  
- **OAuth** místo lokální registrace.  
- **AJAX** refresh dashboardu bez reloadu.

---

## 11  Licence

Tento projekt je vydán pod licencí MIT.
