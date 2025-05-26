<?php
/**
 * Dashboard - Hlavní přehledová stránka uživatelských her
 * Zobrazuje všechny přidané hry uživatele s možnostmi správy
 * Umožňuje: prohlížení statistik, aktualizaci, export, mazání her
 */

// Importování potřebných souborů pro databázi a API
require_once 'db.php';                    // Připojení k databázi
require_once 'fetch_lol_stats.php';      // API pro League of Legends statistiky
require_once 'fetch_chess_stats.php';    // API pro Chess.com statistiky  
require_once 'fetch_royale_stats.php';   // API pro Clash Royale statistiky

// =====================================================
// KONTROLA PŘIHLÁŠENÍ UŽIVATELE
// =====================================================

// Pokud uživatel není přihlášen, přesměruj na přihlašovací stránku
if (!isset($_SESSION["user_id"])) {
    header("Location: /login");
    exit;
}

// Inicializace základních proměnných
$userId = $_SESSION["user_id"];          // ID přihlášeného uživatele
$error = '';                             // Proměnná pro chybové zprávy
$success = $_GET['success'] ?? '';       // Úspěšné zprávy z URL parametrů

// =====================================================
// ZPRACOVÁNÍ MAZÁNÍ HRY
// =====================================================

// Kontrola, zda byl odeslán formulář pro smazání hry
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'delete') {
    $gameId = $_POST['game_id'] ?? 0;    // ID hry k smazání
    
    try {
        /* 
         * Mazání probíhá ve dvou krocích kvůli cizím klíčům:
         * 1. Nejdříve smaž všechny statistiky hry
         * 2. Poté smaž samotnou hru
         */
        
        // Krok 1: Smazání všech statistik dané hry
        $stmt = $pdo->prepare("DELETE FROM game_stats WHERE game_id = :game_id");
        $stmt->execute([":game_id" => $gameId]);
        
        // Krok 2: Smazání samotné hry (s kontrolou vlastnictví uživatelem)
        $stmt = $pdo->prepare("DELETE FROM games WHERE id = :game_id AND user_id = :user_id");
        $stmt->execute([":game_id" => $gameId, ":user_id" => $userId]);
        
        // Úspěšné smazání - přesměrování s úspěšnou zprávou
        $success = 'Hra byla úspěšně odstraněna.';
        header("Location: /?success=" . urlencode($success));
        exit;
        
    } catch (PDOException $e) {
        // Zachycení chyb databáze při mazání
        $error = 'Chyba při odstraňování hry: ' . htmlspecialchars($e->getMessage());
    }
}

// =====================================================
// ZPRACOVÁNÍ AKTUALIZACE STATISTIK
// =====================================================

// Kontrola, zda byl odeslán formulář pro aktualizaci statistik
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'update') {
    try {
        // Získání všech her daného uživatele
        $stmt = $pdo->prepare("SELECT * FROM games WHERE user_id = :user_id");
        $stmt->execute([":user_id" => $userId]);
        $games = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Procházení každé hry pro aktualizaci statistik
        foreach ($games as $game) {
            $gameId = $game['id'];        // ID hry
            $gameName = $game['name'];    // Název hry
            $stats = [];                  // Nové statistiky z API

            // =====================================================
            // ZÍSKÁNÍ EXISTUJÍCÍCH ÚDAJŮ PRO API VOLÁNÍ
            // =====================================================
            
            // Načtení současných statistik pro získání uživatelských jmen/tagů
            $statStmt = $pdo->prepare("SELECT stat_key, stat_value FROM game_stats WHERE game_id = :game_id");
            $statStmt->execute([":game_id" => $gameId]);
            $existingStats = $statStmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Převod statistik do asociativního pole pro snadný přístup
            $statMap = [];
            foreach ($existingStats as $stat) {
                // Pokus o dekódování JSON hodnot
                $value = json_decode($stat["stat_value"], true);
                $statMap[$stat["stat_key"]] = $value !== null && json_last_error() === JSON_ERROR_NONE 
                    ? $value 
                    : $stat["stat_value"];
            }

            // =====================================================
            // AKTUALIZACE PODLE TYPU HRY
            // =====================================================
            
            // LEAGUE OF LEGENDS - aktualizace přes Riot API
            if ($gameName === "League of Legends") {
                // Získání uložených přihlašovacích údajů
                $riotName = $statMap['riot_name'] ?? '';
                $riotTag = $statMap['riot_tag'] ?? '';
                $platformRegion = $statMap['platform_region'] ?? '';
                $globalRegion = $statMap['global_region'] ?? '';
                
                // Kontrola, že máme všechny potřebné údaje
                if ($riotName && $riotTag && $platformRegion && $globalRegion) {
                    // Volání API pro získání aktuálních statistik
                    $stats = fetchLoLStats($riotName, $riotTag, $platformRegion, $globalRegion);
                    
                    if ($stats) {
                        // Přidání uživatelských údajů k novým statistikám
                        $stats["riot_name"] = $riotName;
                        $stats["riot_tag"] = $riotTag;
                        $stats["platform_region"] = $platformRegion;
                        $stats["global_region"] = $globalRegion;
                    }
                }
            } 
            // CHESS.COM - aktualizace přes Chess.com API
            elseif ($gameName === "Chess.com") {
                $chessName = $statMap['chess_name'] ?? '';
                
                if ($chessName) {
                    $stats = fetchChessStats($chessName);
                    if ($stats) {
                        $stats["chess_name"] = $chessName;
                    }
                }
            } 
            // CLASH ROYALE - aktualizace přes Clash Royale API
            elseif ($gameName === "Clash Royale") {
                $royaleTag = $statMap['royale_tag'] ?? '';
                
                if ($royaleTag) {
                    $stats = fetchRoyaleStats($royaleTag);
                    if ($stats) {
                        $stats["royale_tag"] = $royaleTag;
                    }
                }
            } 
            // VLASTNÍ HRA - zachování existujících manuálních údajů
            elseif ($gameName === "jiná") {
                $stats = $statMap; // Ponech stávající statistiky pro manuální hry
            } 
            // OSTATNÍ HRY - přeskoč (manuální hry bez API)
            else {
                continue;
            }

            // =====================================================
            // ULOŽENÍ AKTUALIZOVANÝCH STATISTIK
            // =====================================================
            
            // Pokud máme nové statistiky, uložíme je
            if (!empty($stats)) {
                // Smazání starých statistik
                $pdo->prepare("DELETE FROM game_stats WHERE game_id = :game_id")->execute([":game_id" => $gameId]);
                
                // Vložení nových statistik
                $statStmt = $pdo->prepare("INSERT INTO game_stats (game_id, stat_key, stat_value) VALUES (:game_id, :key, :value)");
                foreach ($stats as $key => $value) {
                    $statStmt->execute([
                        ":game_id" => $gameId,
                        ":key" => $key,
                        // Převod arrays na JSON pro databázi
                        ":value" => is_array($value) ? json_encode($value) : $value
                    ]);
                }
            }
        }
        
        // Úspěšná aktualizace - přesměrování s potvrzením
        $success = 'Statistiky byly úspěšně aktualizovány.';
        header("Location: /?success=" . urlencode($success));
        exit;
        
    } catch (PDOException $e) {
        // Zachycení chyb při aktualizaci
        $error = 'Chyba při aktualizaci statistik: ' . htmlspecialchars($e->getMessage());
    }
}

// =====================================================
// ZPRACOVÁNÍ EXPORTU STATISTIK
// =====================================================

// Kontrola, zda byl odeslán formulář pro export statistik
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'export') {
    try {
        // Získání všech her uživatele pro export
        $stmt = $pdo->prepare("SELECT * FROM games WHERE user_id = :user_id");
        $stmt->execute([":user_id" => $userId]);
        $games = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Vytvoření XML struktury pro export
        $xml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><games></games>');
        
        // Procházení každé hry a přidání do XML
        foreach ($games as $game) {
            $gameNode = $xml->addChild('game');
            $gameNode->addChild('name', htmlspecialchars($game['name']));
            $statsNode = $gameNode->addChild('stats');
            
            // Získání všech statistik pro danou hru
            $statStmt = $pdo->prepare("SELECT stat_key, stat_value FROM game_stats WHERE game_id = :game_id");
            $statStmt->execute([":game_id" => $game['id']]);
            $stats = $statStmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Přidání každé statistiky jako XML element
            foreach ($stats as $stat) {
                $statNode = $statsNode->addChild('stat');
                $statNode->addAttribute('key', htmlspecialchars($stat['stat_key']));
                $statNode->addAttribute('value', htmlspecialchars($stat['stat_value']));
            }
        }

        // Nastavení HTTP hlaviček pro stažení XML souboru
        header('Content-Type: application/xml');
        header('Content-Disposition: attachment; filename="game_stats.xml"');
        echo $xml->asXML();
        exit;
        
    } catch (PDOException $e) {
        // Zachycení chyb při exportu
        $error = 'Chyba při exportu statistik: ' . htmlspecialchars($e->getMessage());
    }
}

// =====================================================
// NAČÍTÁNÍ DAT PRO ZOBRAZENÍ
// =====================================================

// Získání všech her aktuálního uživatele pro zobrazení
$stmt = $pdo->prepare("SELECT * FROM games WHERE user_id = :user_id");
$stmt->execute([":user_id" => $userId]);
$games = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Definice ikon pro různé typy her (pro lepší UX)
$gameIcons = [
    'League of Legends' => '⚔️',
    'Chess.com' => '♟️',
    'Clash Royale' => '👑',
    'jiná' => '🎲'
];
?>

<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Herní přehled</title>
    <link rel="stylesheet" href="/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script>
        /**
         * Funkce pro přepínání zobrazení accordion panelů
         * Umožňuje rozbalení/sbalení detailů jednotlivých her
         * 
         * @param {number} index - Index hry v seznamu
         */
        function togglePanel(index) {
            const panel = document.getElementById('panel-' + index);     // Panel s detaily hry
            const button = panel.previousElementSibling;                // Tlačítko pro rozbalení
            const isOpen = panel.style.display === 'block';            // Kontrola současného stavu
            
            // Přepnutí zobrazení panelu
            panel.style.display = isOpen ? 'none' : 'block';
            
            // Aktualizace ARIA atributů pro accessibility
            button.setAttribute('aria-expanded', !isOpen);
            
            // Přidání/odebrání CSS třídy pro styling
            button.classList.toggle('active', !isOpen);
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>🎮 Můj herní přehled</h1>

        <!-- =====================================================
             ZOBRAZENÍ ZPRÁV (CHYBY A ÚSPĚCHY)
             ===================================================== -->
        
        <!-- Zobrazení chybových zpráv -->
        <?php if ($error): ?>
            <div class="alert alert-error">
                <span>❌ <?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>
        
        <!-- Zobrazení úspěšných zpráv -->
        <?php if ($success): ?>
            <div class="alert alert-success">
                <span>✅ <?= htmlspecialchars($success) ?></span>
            </div>
        <?php endif; ?>

        <!-- =====================================================
             SEZNAM HER NEBO PRÁZDNÝ STAV
             ===================================================== -->

        <!-- Pokud uživatel nemá žádné hry -->
        <?php if (empty($games)): ?>
            <div class="no-games">
                <p>❗ Zatím nemáš přidané žádné hry.</p>
                <a href="/add_game" class="btn">Přidat první hru</a>
            </div>
        <?php else: ?>
            
            <!-- Procházení všech her uživatele -->
            <?php foreach ($games as $index => $game): ?>
                <!-- Accordion kontejner pro jednotlivou hru -->
                <div class="accordion-item <?= str_replace('.', '-', strtolower($game['name'])) ?>">
                    
                    <!-- Tlačítko pro rozbalení/sbalení detailů hry -->
                    <button 
                        class="accordion-button" 
                        onclick="togglePanel(<?= $index ?>)"
                        aria-expanded="false"
                        aria-controls="panel-<?= $index ?>"
                    >
                        <span>
                            <!-- Zobrazení ikony hry (pokud existuje) a názvu -->
                            <?= isset($gameIcons[$game["name"]]) ? $gameIcons[$game["name"]] . ' ' : '' ?>
                            <?= htmlspecialchars($game["name"]) ?>
                        </span>
                        <!-- Šipka pro indikaci stavu (CSS styling) -->
                        <span class="accordion-icon"></span>
                    </button>
                    
                    <!-- Panel s detaily hry (skrytý defaultně) -->
                    <div class="accordion-panel" id="panel-<?= $index ?>" role="region">
                        <?php
                        // =====================================================
                        // NAČÍTÁNÍ A ZPRACOVÁNÍ STATISTIK HRY
                        // =====================================================
                        
                        // Získání všech statistik pro aktuální hru
                        $statStmt = $pdo->prepare("SELECT stat_key, stat_value FROM game_stats WHERE game_id = :game_id");
                        $statStmt->execute([":game_id" => $game["id"]]);
                        $stats = $statStmt->fetchAll(PDO::FETCH_ASSOC);

                        // Převod statistik do asociativního pole s dekódováním JSON
                        $statMap = [];
                        foreach ($stats as $stat) {
                            // Pokus o dekódování JSON hodnot (některé statistiky jsou uloženy jako JSON)
                            $value = json_decode($stat["stat_value"], true);
                            $statMap[$stat["stat_key"]] = $value !== null && json_last_error() === JSON_ERROR_NONE
                                ? $value  // Použij dekódovanou hodnotu
                                : $stat["stat_value"];  // Použij původní string hodnotu
                        }
                        ?>        
                        
                        <!-- Zobrazení všech statistik v seznamu -->
                        <ul>
                            <?php foreach ($statMap as $key => $value): ?>
                                <li>
                                    <strong><?= htmlspecialchars($key) ?>:</strong>
                                    <?php
                                    // Kontrola, zda je hodnota array (vnořené statistiky)
                                    if (is_array($value)) {
                                        // Zobrazení vnořeného seznamu pro array hodnoty
                                        echo "<ul>";
                                        foreach ($value as $k => $v) {
                                            echo "<li><em>" . htmlspecialchars($k) . ":</em> " . htmlspecialchars((string)$v) . "</li>";
                                        }
                                        echo "</ul>";
                                    } else {
                                        // Zobrazení jednoduché hodnoty
                                        echo htmlspecialchars((string)$value);
                                    }
                                    ?>
                                </li>
                            <?php endforeach; ?>
                        </ul>
                        
                        <!-- Akce pro správu hry -->
                        <div class="game-actions">
                            <!-- Formulář pro smazání hry s potvrzením -->
                            <form method="POST" onsubmit="return confirm('Opravdu chcete odstranit tuto hru?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="game_id" value="<?= $game['id'] ?>">
                                <button type="submit" class="btn btn-danger">🗑️ Odstranit</button>
                            </form>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        <?php endif; ?>

        <!-- =====================================================
             HLAVNÍ AKCE A NAVIGACE
             ===================================================== -->
        
        <div class="actions">
            <!-- Tlačítko pro přidání nové hry -->
            <a href="/add_game" class="btn">➕ Přidat další hru</a>
            
            <!-- Akce dostupné pouze pokud má uživatel nějaké hry -->
            <?php if (!empty($games)): ?>
                <!-- Formulář pro aktualizaci všech statistik -->
                <form method="POST" style="display: inline;">
                    <input type="hidden" name="action" value="update">
                    <button type="submit" class="btn">🔄 Aktualizovat statistiky</button>
                </form>
                
                <!-- Formulář pro export statistik do XML -->
                <form method="POST" style="display: inline;">
                    <input type="hidden" name="action" value="export">
                    <button type="submit" class="btn">📤 Exportovat statistiky</button>
                </form>
            <?php endif; ?>
            
            <!-- Tlačítko pro odhlášení -->
            <a href="/logout" class="btn secondary">🚪 Odhlásit se</a>
        </div>
    </div>

    <script>
        /**
         * Inicializace stránky po načtení DOM
         * Nastavuje všechny accordion panely jako skryté
         */
        document.addEventListener('DOMContentLoaded', () => {
            // Skrytí všech accordion panelů při načtení stránky
            document.querySelectorAll('.accordion-panel').forEach(panel => {
                panel.style.display = 'none';
            });
        });
    </script>
</body>
</html>