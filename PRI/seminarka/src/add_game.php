<?php
require_once 'db.php';
require_once 'fetch_lol_stats.php';
require_once 'fetch_chess_stats.php';
require_once 'fetch_royale_stats.php';
require_once 'xml_utils.php';

if (!isset($_SESSION["user_id"])) {
    header("Location: /login");
    exit;
}

$error = '';
$success = '';

// Load game forms from XML
$xmlPath = __DIR__ . '/../data/games.xml';
$xsdPath = __DIR__ . '/../data/games.xsd';
if (!validateXml($xmlPath, $xsdPath)) {
    http_response_code(500);
    exit('games.xml is not valid against games.xsd');
}

$xml = simplexml_load_file($xmlPath);

// Handle form submission
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'add') {
    $gameName = trim($_POST["name"] ?? '');
    $userId = $_SESSION["user_id"];
    $stats = [];

    if (empty($gameName)) {
        $error = 'Prosím, vyberte hru.';
    } else {
        if ($gameName === "League of Legends") {
            $riotName = trim($_POST["riot_name"] ?? '');
            $riotTag = trim($_POST["riot_tag"] ?? '');
            $platformRegion = $_POST["platform_region"] ?? '';
            $globalRegion = $_POST["global_region"] ?? '';
            if (empty($riotName) || empty($riotTag) || empty($platformRegion) || empty($globalRegion)) {
                $error = 'Prosím, vyplňte všechny povinné údaje pro League of Legends.';
            } else {
                $stats = fetchLoLStats($riotName, $riotTag, $platformRegion, $globalRegion);
                if (!$stats) {
                    $error = 'Chyba: LoL data nebyla nalezena.';
                } else {
                    $stats["riot_name"] = $riotName;
                    $stats["riot_tag"] = $riotTag;
                    $stats["platform_region"] = $platformRegion;
                    $stats["global_region"] = $globalRegion;
                }
            }
        } elseif ($gameName === "Chess.com") {
            $chessName = trim($_POST["chess_name"] ?? '');
            if (empty($chessName)) {
                $error = 'Prosím, zadejte Chess.com uživatelské jméno.';
            } else {
                $stats = fetchChessStats($chessName);
                if (!$stats) {
                    $error = 'Chyba: Chess.com data nebyla nalezena.';
                } else {
                    $stats["chess_name"] = $chessName;
                }
            }
        } elseif ($gameName === "Clash Royale") {
            $royaleTag = trim($_POST["royale_tag"] ?? '');
            if (empty($royaleTag)) {
                $error = 'Prosím, zadejte Clash Royale tag.';
            } else {
                $stats = fetchRoyaleStats($royaleTag);
                if (!$stats) {
                    $error = 'Chyba: Clash Royale data nebyla nalezena.';
                } else {
                    $stats["royale_tag"] = $royaleTag;
                }
            }
        } elseif ($gameName === "jiná") {
            $customGameName = trim($_POST["custom_game_name"] ?? '');
            if (empty($customGameName)) {
                $error = 'Prosím, zadejte název vlastní hry.';
            } else {
                $stats = [
                    "custom_game_name" => $customGameName
                ];
            }
        } else {
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

        if (empty($error) && !empty($stats)) {
            try {
                $stmt = $pdo->prepare("INSERT INTO games (user_id, name) VALUES (:user_id, :name) RETURNING id");
                $stmt->execute([
                    ":user_id" => $userId,
                    ":name" => $gameName
                ]);
                $gameId = $stmt->fetchColumn();

                $statStmt = $pdo->prepare("INSERT INTO game_stats (game_id, stat_key, stat_value) VALUES (:game_id, :key, :value)");
                foreach ($stats as $key => $value) {
                    $statStmt->execute([
                        ":game_id" => $gameId,
                        ":key" => $key,
                        ":value" => is_array($value) ? json_encode($value) : $value
                    ]);
                }

                $success = 'Hra byla úspěšně přidána!';
                header("Location: /?success=" . urlencode($success));
                exit;
            } catch (PDOException $e) {
                $error = 'Chyba při ukládání hry: ' . htmlspecialchars($e->getMessage());
            }
        }
    }
}

// Handle XML import
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'import') {
    if (isset($_FILES['xml_file']) && $_FILES['xml_file']['error'] === UPLOAD_ERR_OK) {
        $xmlFile = $_FILES['xml_file']['tmp_name'];
        $xsdPath = __DIR__ . '/../data/game_stats.xsd';

        libxml_use_internal_errors(true);
        $dom = new DOMDocument();

        if ($dom->load($xmlFile) && $dom->schemaValidate($xsdPath)) {
            $xml = simplexml_load_file($xmlFile);
            try {
                foreach ($xml->game as $game) {
                    $gameName = (string)$game->name;
                    $userId = $_SESSION["user_id"];
                    $stats = [];
                    foreach ($game->stats->stat as $stat) {
                        $key = (string)$stat['key'];
                        $value = (string)$stat['value'];
                        $decoded = json_decode($value, true);
                        $stats[$key] = $decoded !== null && json_last_error() === JSON_ERROR_NONE ? $decoded : $value;
                    }

                    $isValid = true;
                    if ($gameName === "League of Legends" && (empty($stats['riot_name']) || empty($stats['riot_tag']) || empty($stats['platform_region']) || empty($stats['global_region']))) {
                        $isValid = false;
                    } elseif ($gameName === "Chess.com" && empty($stats['chess_name'])) {
                        $isValid = false;
                    } elseif ($gameName === "jiná" && empty($stats['rank'])) {
                        $isValid = false;
                    }

                    if ($isValid) {
                        $stmt = $pdo->prepare("INSERT INTO games (user_id, name) VALUES (:user_id, :name) RETURNING id");
                        $stmt->execute([
                            ":user_id" => $userId,
                            ":name" => $gameName
                        ]);
                        $gameId = $stmt->fetchColumn();

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
                $success = 'Statistiky byly úspěšně importovány!';
                header("Location: /?success=" . urlencode($success));
                exit;
            } catch (PDOException $e) {
                $error = 'Chyba při importu statistik: ' . htmlspecialchars($e->getMessage());
            }
        } else {
            $error = 'Chyba: XML soubor není validní podle schématu game_stats.xsd.';
            foreach (libxml_get_errors() as $err) {
                $error .= '<br>' . htmlspecialchars($err->message);
            }
        }
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
        // Define toggleFields globally
        function toggleFields() {
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

            const game = document.getElementById('game-select')?.value || '';
            console.log('Selected game:', game);

            if (!Array.isArray(fields)) {
                console.error('Fields is not an array:', fields);
                return;
            }

            fields.forEach(field => {
                const element = document.getElementById(field);
                if (!element) {
                    console.error(`Field ${field} not found in DOM`);
                    return;
                }
                const shouldShow = gameToFields[game] === field;
                element.style.display = shouldShow ? 'block' : 'none';
                element.style.opacity = shouldShow ? '0' : '1';
                if (shouldShow) {
                    setTimeout(() => {
                        element.style.transition = 'opacity 0.3s ease';
                        element.style.opacity = '1';
                    }, 10);
                }

                // Toggle required attribute for inputs and selects within the field
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

        <?php if ($error): ?>
            <div class="alert alert-error">
                <span>❌ <?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>

        <div class="form-card">
            <h2>Ruční přidání</h2>
            <form method="POST" class="form-inner">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label for="game-select">Název hry:</label>
                    <select name="name" id="game-select" onchange="toggleFields()" required aria-describedby="game-select-help">
                        <option value="" disabled selected>Vyberte hru</option>
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

                <?php if ($xml && $xml->game): ?>
                    <?php foreach ($xml->game as $game): ?>
                        <div id="<?= htmlspecialchars((string)$game['id']) ?>-fields" class="form-group game-fields" style="display:none;">
                            <?php if ($game->fields->field): ?>
                                <?php foreach ($game->fields->field as $field): ?>
                                    <label for="<?= htmlspecialchars((string)$field['id']) ?>">
                                        <?= htmlspecialchars((string)$field['label']) ?>:
                                    </label>
                                    <?php if ((string)$field['type'] === 'select'): ?>
                                        <select 
                                            name="<?= htmlspecialchars((string)$field['id']) ?>" 
                                            id="<?= htmlspecialchars((string)$field['id']) ?>" 
                                            aria-describedby="<?= htmlspecialchars((string)$field['id']) ?>-help"
                                            <?= (string)$field['required'] === 'true' ? 'required' : '' ?>
                                        >
                                            <?php foreach ($field->option as $option): ?>
                                                <option value="<?= htmlspecialchars((string)$option) ?>">
                                                    <?= htmlspecialchars((string)$option) ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    <?php else: ?>
                                        <input 
                                            type="<?= htmlspecialchars((string)$field['type']) ?>" 
                                            name="<?= htmlspecialchars((string)$field['id']) ?>" 
                                            id="<?= htmlspecialchars((string)$field['id']) ?>" 
                                            aria-describedby="<?= htmlspecialchars((string)$field['id']) ?>-help"
                                            <?= (string)$field['required'] === 'true' ? 'required' : '' ?>
                                            <?= (string)$field['type'] === 'number' ? 'min="' . htmlspecialchars((string)$field['min']) . '"' : '' ?>
                                        >
                                    <?php endif; ?>
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
                    <p>Chyba: 不byly načteny žádné hry z games.xml.</p>
                <?php endif; ?>

                <div class="form-actions">
                    <button type="submit" class="btn">Přidat hru</button>
                    <a href="/" class="btn secondary">Zpět na přehled</a>
                </div>
            </form>
        </div>

        <div class="form-card">
            <h2>Import statistik</h2>
            <form method="POST" enctype="multipart/form-data" class="form-inner">
                <input type="hidden" name="action" value="import">
                <div class="form-group">
                    <label for="xml_file">Nahrát XML soubor:</label>
                    <input type="file" name="xml_file" id="xml_file" accept=".xml" required aria-describedby="xml_file-help">
                    <small id="xml_file-help" class="form-help">Vyberte XML soubor obsahující statistiky her.</small>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn">Importovat</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Initialize fields on page load
        document.addEventListener('DOMContentLoaded', () => {
            toggleFields(); // Call toggleFields to set initial state
        });
    </script>
</body>
</html>