<?php
/**
 * Soubor pro přidávání her do systému
 * Umožňuje uživatelům přidat hru buď ručně přes formulář nebo importem XML souboru
 */

// Importování potřebných souborů
require_once 'db.php';                    // Připojení k databázi
require_once 'fetch_lol_stats.php';      // Funkce pro získání statistik League of Legends
require_once 'fetch_chess_stats.php';    // Funkce pro získání statistik Chess.com
require_once 'fetch_royale_stats.php';   // Funkce pro získání statistik Clash Royale
require_once 'xml_utils.php';            // Utilities pro práci s XML

// Kontrola přihlášení uživatele - pokud není přihlášen, přesměruj na login
if (!isset($_SESSION["user_id"])) {
    header("Location: /login");
    exit;
}

// Inicializace proměnných pro zprávy
$error = '';    // Chybové zprávy
$success = '';  // Úspěšné zprávy

// =====================================================
// NAČÍTÁNÍ A VALIDACE XML KONFIGURACE HER
// =====================================================

// Cesty k XML souboru s konfigurací her a jeho schématu
$xmlPath = __DIR__ . '/../data/games.xml';
$xsdPath = __DIR__ . '/../data/games.xsd';

// Validace XML souboru proti XSD schématu
if (!validateXml($xmlPath, $xsdPath)) {
    http_response_code(500);
    exit('games.xml is not valid against games.xsd');
}

// Načtení XML konfigurace her
$xml = simplexml_load_file($xmlPath);

// =====================================================
// ZPRACOVÁNÍ RUČNÍHO PŘIDÁNÍ HRY
// =====================================================

// Kontrola, zda byl odeslán formulář pro ruční přidání hry
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'add') {
    
    // Získání základních dat z formuláře
    $gameName = trim($_POST["name"] ?? '');     // Název vybrané hry
    $userId = $_SESSION["user_id"];            // ID přihlášeného uživatele
    $stats = [];                               // Pole pro statistiky hry

    // Základní validace - kontrola, zda byla vybrána hra
    if (empty($gameName)) {
        $error = 'Prosím, vyberte hru.';
    } else {
        
        // =====================================================
        // ZPRACOVÁNÍ SPECIFICKÝCH HER
        // =====================================================
        
        // LEAGUE OF LEGENDS - vyžaduje speciální zpracování přes Riot API
        if ($gameName === "League of Legends") {
            // Získání dat z formuláře
            $riotName = trim($_POST["riot_name"] ?? '');
            $riotTag = trim($_POST["riot_tag"] ?? '');
            $platformRegion = $_POST["platform_region"] ?? '';
            $globalRegion = $_POST["global_region"] ?? '';
            
            // Validace povinných polí
            if (empty($riotName) || empty($riotTag) || empty($platformRegion) || empty($globalRegion)) {
                $error = 'Prosím, vyplňte všechny povinné údaje pro League of Legends.';
            } else {
                // Pokus o získání statistik z Riot API
                $stats = fetchLoLStats($riotName, $riotTag, $platformRegion, $globalRegion);
                
                if (!$stats) {
                    $error = 'Chyba: LoL data nebyla nalezena.';
                } else {
                    // Přidání uživatelských dat ke statistikám
                    $stats["riot_name"] = $riotName;
                    $stats["riot_tag"] = $riotTag;
                    $stats["platform_region"] = $platformRegion;
                    $stats["global_region"] = $globalRegion;
                }
            }
        } 
        // CHESS.COM - vyžaduje pouze uživatelské jméno
        elseif ($gameName === "Chess.com") {
            $chessName = trim($_POST["chess_name"] ?? '');
            
            if (empty($chessName)) {
                $error = 'Prosím, zadejte Chess.com uživatelské jméno.';
            } else {
                // Pokus o získání statistik z Chess.com API
                $stats = fetchChessStats($chessName);
                
                if (!$stats) {
                    $error = 'Chyba: Chess.com data nebyla nalezena.';
                } else {
                    $stats["chess_name"] = $chessName;
                }
            }
        } 
        // CLASH ROYALE - vyžaduje player tag
        elseif ($gameName === "Clash Royale") {
            $royaleTag = trim($_POST["royale_tag"] ?? '');
            
            if (empty($royaleTag)) {
                $error = 'Prosím, zadejte Clash Royale tag.';
            } else {
                // Pokus o získání statistik z Clash Royale API
                $stats = fetchRoyaleStats($royaleTag);
                
                if (!$stats) {
                    $error = 'Chyba: Clash Royale data nebyla nalezena.';
                } else {
                    $stats["royale_tag"] = $royaleTag;
                }
            }
        } 
        // VLASTNÍ HRA - pouze název bez dalších statistik
        elseif ($gameName === "jiná") {
            $customGameName = trim($_POST["custom_game_name"] ?? '');
            $rank = trim($_POST["rank"] ?? '');
            $wins = (int)($_POST["wins"] ?? 0);
            $losses = (int)($_POST["losses"] ?? 0);

            if (empty($customGameName)) {
                $error = 'Prosím, zadejte název vlastní hry.';
            } else {
                $stats = [
                    "custom_game_name" => $customGameName,
                    "rank" => $rank,
                    "wins" => $wins,
                    "losses" => $losses
                ];
            }
        } 
        // OSTATNÍ HRY - obecné pole pro rank, výhry, prohry
        else {
            $rank = trim($_POST["rank"] ?? '');
            $wins = (int)($_POST["wins"] ?? 0);
            $losses = (int)($_POST["losses"] ?? 0);
            
            if (empty($rank)) {
                $error = 'Prosím, zadejte rank pro vlastní hru.';
            } else {
                $stats = [
                    "rank" => $rank,
                    "wins" => $wins,
                    "losses" => $losses
                ];
            }
        }

        // =====================================================
        // ULOŽENÍ HRY DO DATABÁZE
        // =====================================================
        
        // Pokud nejsou chyby a máme statistiky, uložíme hru
        if (empty($error) && !empty($stats)) {
            try {
                // Začátek databázové transakce (implicitní)
                
                // 1. Vložení základního záznamu hry
                $stmt = $pdo->prepare("INSERT INTO games (user_id, name) VALUES (:user_id, :name) RETURNING id");
                $stmt->execute([
                    ":user_id" => $userId,
                    ":name" => $gameName
                ]);
                $gameId = $stmt->fetchColumn(); // Získání ID nově vytvořené hry

                // 2. Vložení všech statistik hry
                $statStmt = $pdo->prepare("INSERT INTO game_stats (game_id, stat_key, stat_value) VALUES (:game_id, :key, :value)");
                
                foreach ($stats as $key => $value) {
                    $statStmt->execute([
                        ":game_id" => $gameId,
                        ":key" => $key,
                        // Převod arrays na JSON pro uložení do databáze
                        ":value" => is_array($value) ? json_encode($value) : $value
                    ]);
                }

                // Úspěšné dokončení - přesměrování na hlavní stránku s úspěšnou zprávou
                $success = 'Hra byla úspěšně přidána!';
                header("Location: /?success=" . urlencode($success));
                exit;
                
            } catch (PDOException $e) {
                // Zachycení chyb databáze
                $error = 'Chyba při ukládání hry: ' . htmlspecialchars($e->getMessage());
            }
        }
    }
}

// =====================================================
// ZPRACOVÁNÍ IMPORTU XML SOUBORU
// =====================================================

// Kontrola, zda byl odeslán formulář pro import XML
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'import') {
    
    // Kontrola, zda byl nahrán soubor bez chyb
    if (isset($_FILES['xml_file']) && $_FILES['xml_file']['error'] === UPLOAD_ERR_OK) {
        
        $xmlFile = $_FILES['xml_file']['tmp_name'];           // Cesta k nahranému souboru
        $xsdPath = __DIR__ . '/../data/game_stats.xsd';      // Schéma pro validaci importovaných dat

        // Povolení zachycování XML chyb
        libxml_use_internal_errors(true);
        $dom = new DOMDocument();

        // Validace nahraného XML souboru proti schématu
        if ($dom->load($xmlFile) && $dom->schemaValidate($xsdPath)) {
            
            // XML je validní, můžeme ho zpracovat
            $xml = simplexml_load_file($xmlFile);
            
            try {
                // Procházení všech her v XML souboru
                foreach ($xml->game as $game) {
                    $gameName = (string)$game->name;    // Název hry
                    $userId = $_SESSION["user_id"];     // ID uživatele
                    $stats = [];                        // Statistiky hry

                    // Načtení všech statistik z XML
                    foreach ($game->stats->stat as $stat) {
                        $key = (string)$stat['key'];      // Klíč statistiky
                        $value = (string)$stat['value'];  // Hodnota statistiky
                        
                        // Pokus o dekódování JSON (pokud je hodnota v JSON formátu)
                        $decoded = json_decode($value, true);
                        $stats[$key] = $decoded !== null && json_last_error() === JSON_ERROR_NONE ? $decoded : $value;
                    }

                    // =====================================================
                    // VALIDACE IMPORTOVANÝCH DAT
                    // =====================================================
                    
                    $isValid = true;
                    
                    // Kontrola požadovaných polí podle typu hry
                    if ($gameName === "League of Legends" && 
                        (empty($stats['riot_name']) || empty($stats['riot_tag']) || 
                         empty($stats['platform_region']) || empty($stats['global_region']))) {
                        $isValid = false;
                    } elseif ($gameName === "Chess.com" && empty($stats['chess_name'])) {
                        $isValid = false;
                    } elseif ($gameName === "jiná" && empty($stats['rank'])) {
                        $isValid = false;
                    }

                    // Uložení pouze validních her
                    if ($isValid) {
                        // Vložení základního záznamu hry
                        $stmt = $pdo->prepare("INSERT INTO games (user_id, name) VALUES (:user_id, :name) RETURNING id");
                        $stmt->execute([
                            ":user_id" => $userId,
                            ":name" => $gameName
                        ]);
                        $gameId = $stmt->fetchColumn();

                        // Vložení statistik
                        $statStmt = $pdo->prepare("INSERT INTO game_stats (game_id, stat_key, stat_value) VALUES (:game_id, :key, :value)");
                        foreach ($stats as $key => $value) {
                            $statStmt->execute([
                                ":game_id" => $gameId,
                                ":key" => $key,
                                ":value" => is_array($value) ? json_encode($value) : $value
                            ]);
                        }
                    }
                }
                
                // Úspěšný import - přesměrování
                $success = 'Statistiky byly úspěšně importovány!';
                header("Location: /?success=" . urlencode($success));
                exit;
                
            } catch (PDOException $e) {
                // Chyba při práci s databází
                $error = 'Chyba při importu statistik: ' . htmlspecialchars($e->getMessage());
            }
        } else {
            // XML soubor není validní
            $error = 'Chyba: XML soubor není validní podle schématu game_stats.xsd.';
            
            // Přidání detailních chyb validace
            foreach (libxml_get_errors() as $err) {
                $error .= '<br>' . htmlspecialchars($err->message);
            }
        }
        
        // Vyčištění XML chyb z paměti
        libxml_clear_errors();
    } else {
        $error = 'Prosím, nahrajte platný XML soubor.';
    }
}

?>

<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Přidat hru</title>
    <link rel="stylesheet" href="/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script>
        /**
         * Funkce pro přepínání zobrazení polí formuláře podle vybrané hry
         * Skryje všechna pole a zobrazí pouze ta, která patří k vybrané hře
         */
        function toggleFields() {
            // Pole obsahující všechna ID divů s poli her
            const fields = [
                <?php if ($xml && $xml->game): ?>
                    <?php $first = true; ?>
                    <?php foreach ($xml->game as $game): ?>
                        <?php if (!$first) echo ','; ?>
                        '<?= htmlspecialchars((string)$game['id']) ?>-fields'
                        <?php $first = false; ?>
                    <?php endforeach; ?>
                <?php endif; ?>
            ];

            // Mapování názvů her na ID jejich polí
            const gameToFields = {
                <?php if ($xml && $xml->game): ?>
                    <?php $first = true; ?>
                    <?php foreach ($xml->game as $game): ?>
                        <?php if (!$first) echo ','; ?>
                        '<?= htmlspecialchars((string)$game->name) ?>': '<?= htmlspecialchars((string)$game['id']) ?>-fields'
                        <?php $first = false; ?>
                    <?php endforeach; ?>
                <?php endif; ?>
            };

            // Získání aktuálně vybrané hry
            const game = document.getElementById('game-select')?.value || '';
            console.log('Selected game:', game);

            // Kontrola, zda je fields array
            if (!Array.isArray(fields)) {
                console.error('Fields is not an array:', fields);
                return;
            }

            // Procházení všech polí a skrytí/zobrazení podle vybrané hry
            fields.forEach(field => {
                const element = document.getElementById(field);
                
                // Kontrola existence elementu
                if (!element) {
                    console.error(`Field ${field} not found in DOM`);
                    return;
                }
                
                // Určení, zda má být pole zobrazeno
                const shouldShow = gameToFields[game] === field;
                
                // Nastavení zobrazení s animací
                element.style.display = shouldShow ? 'block' : 'none';
                element.style.opacity = shouldShow ? '0' : '1';
                
                if (shouldShow) {
                    // Plynulé zobrazení s mírným zpožděním
                    setTimeout(() => {
                        element.style.transition = 'opacity 0.3s ease';
                        element.style.opacity = '1';
                    }, 10);
                }

                // Přepínání required atributu pro inputy a selecty
                const inputs = element.querySelectorAll('input[required], select[required]');
                inputs.forEach(input => {
                    if (shouldShow) {
                        input.setAttribute('required', 'required');
                    } else {
                        input.removeAttribute('required');
                    }
                });

                console.log(`Field ${field} display: ${element.style.display}, opacity: ${element.style.opacity}`);
            });
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>➕ Přidat novou hru</h1>

        <!-- Zobrazení chybových zpráv -->
        <?php if ($error): ?>
            <div class="alert alert-error">
                <span>❌ <?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>

        <!-- =====================================================
             FORMULÁŘ PRO RUČNÍ PŘIDÁNÍ HRY
             ===================================================== -->
        <div class="form-card">
            <h2>Ruční přidání</h2>
            <form method="POST" class="form-inner">
                <!-- Skryté pole pro identifikaci akce -->
                <input type="hidden" name="action" value="add">
                
                <!-- Výběr hry -->
                <div class="form-group">
                    <label for="game-select">Název hry:</label>
                    <select name="name" id="game-select" onchange="toggleFields()" required aria-describedby="game-select-help">
                        <option value="" disabled selected>Vyberte hru</option>
                        
                        <!-- Načtení her z XML konfigurace -->
                        <?php if ($xml && $xml->game): ?>
                            <?php foreach ($xml->game as $game): ?>
                                <option value="<?= htmlspecialchars((string)$game->name) ?>">
                                    <?= htmlspecialchars((string)$game->displayName) ?>
                                </option>
                            <?php endforeach; ?>
                        <?php else: ?>
                            <option value="" disabled>Žádné hry nebyly načteny</option>
                        <?php endif; ?>
                    </select>
                    <small id="game-select-help" class="form-help">Vyberte hru, pro kterou chcete přidat statistiky.</small>
                </div>

                <!-- Dynamické pole pro jednotlivé hry -->
                <?php if ($xml && $xml->game): ?>
                    <?php foreach ($xml->game as $game): ?>
                        <!-- Kontejner pro pole konkrétní hry (skrytý defaultně) -->
                        <div id="<?= htmlspecialchars((string)$game['id']) ?>-fields" class="form-group game-fields" style="display:none;">
                            
                            <!-- Kontrola existence polí pro danou hru -->
                            <?php if ($game->fields->field): ?>
                                <!-- Generování polí podle XML konfigurace -->
                                <?php foreach ($game->fields->field as $field): ?>
                                    <label for="<?= htmlspecialchars((string)$field['id']) ?>">
                                        <?= htmlspecialchars((string)$field['label']) ?>:
                                    </label>
                                    
                                    <!-- Rozhodnutí typu pole (select vs input) -->
                                    <?php if ((string)$field['type'] === 'select'): ?>
                                        <!-- Select pole s options z XML -->
                                        <select 
                                            name="<?= htmlspecialchars((string)$field['id']) ?>" 
                                            id="<?= htmlspecialchars((string)$field['id']) ?>" 
                                            aria-describedby="<?= htmlspecialchars((string)$field['id']) ?>-help"
                                            <?= (string)$field['required'] === 'true' ? 'required' : '' ?>
                                        >
                                            <!-- Načtení všech možností pro select -->
                                            <?php foreach ($field->option as $option): ?>
                                                <option value="<?= htmlspecialchars((string)$option) ?>">
                                                    <?= htmlspecialchars((string)$option) ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    <?php else: ?>
                                        <!-- Input pole (text, number, atd.) -->
                                        <input 
                                            type="<?= htmlspecialchars((string)$field['type']) ?>" 
                                            name="<?= htmlspecialchars((string)$field['id']) ?>" 
                                            id="<?= htmlspecialchars((string)$field['id']) ?>" 
                                            aria-describedby="<?= htmlspecialchars((string)$field['id']) ?>-help"
                                            <?= (string)$field['required'] === 'true' ? 'required' : '' ?>
                                            <?= (string)$field['type'] === 'number' ? 'min="' . htmlspecialchars((string)$field['min']) . '"' : '' ?>
                                        >
                                    <?php endif; ?>
                                    
                                    <!-- Pomocný text pro pole -->
                                    <small id="<?= htmlspecialchars((string)$field['id']) ?>-help" class="form-help">
                                        <?= htmlspecialchars((string)$field['help']) ?>
                                    </small>
                                <?php endforeach; ?>
                            <?php else: ?>
                                <p>Žádné pole nebyly definovány pro tuto hru.</p>
                            <?php endif; ?>
                        </div>
                    <?php endforeach; ?>
                <?php else: ?>
                    <p>Chyba: Nebyly načteny žádné hry z games.xml.</p>
                <?php endif; ?>

                <!-- Tlačítka formuláře -->
                <div class="form-actions">
                    <button type="submit" class="btn">Přidat hru</button>
                    <a href="/" class="btn secondary">Zpět na přehled</a>
                </div>
            </form>
        </div>

        <!-- =====================================================
             FORMULÁŘ PRO IMPORT XML SOUBORU
             ===================================================== -->
        <div class="form-card">
            <h2>Import statistik</h2>
            <form method="POST" enctype="multipart/form-data" class="form-inner">
                <!-- Skryté pole pro identifikaci akce -->
                <input type="hidden" name="action" value="import">
                
                <!-- Pole pro nahrání XML souboru -->
                <div class="form-group">
                    <label for="xml_file">Nahrát XML soubor:</label>
                    <input type="file" name="xml_file" id="xml_file" accept=".xml" required aria-describedby="xml_file-help">
                    <small id="xml_file-help" class="form-help">Vyberte XML soubor obsahující statistiky her.</small>
                </div>
                
                <!-- Tlačítko pro odeslání -->
                <div class="form-actions">
                    <button type="submit" class="btn">Importovat</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        /**
         * Inicializace stránky po načtení DOM
         * Nastaví počáteční stav polí formuláře
         */
        document.addEventListener('DOMContentLoaded', () => {
            toggleFields(); // Zavolání funkce pro nastavení počátečního stavu
        });
    </script>
</body>
</html>