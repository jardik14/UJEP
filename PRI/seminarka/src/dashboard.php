<?php
require_once 'db.php';
require_once 'fetch_lol_stats.php';
require_once 'fetch_chess_stats.php';
require_once 'fetch_royale_stats.php';

if (!isset($_SESSION["user_id"])) {
    header("Location: /login");
    exit;
}

$userId = $_SESSION["user_id"];
$error = '';
$success = $_GET['success'] ?? '';

// Handle game deletion
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'delete') {
    $gameId = $_POST['game_id'] ?? 0;
    try {
        $stmt = $pdo->prepare("DELETE FROM game_stats WHERE game_id = :game_id");
        $stmt->execute([":game_id" => $gameId]);
        $stmt = $pdo->prepare("DELETE FROM games WHERE id = :game_id AND user_id = :user_id");
        $stmt->execute([":game_id" => $gameId, ":user_id" => $userId]);
        $success = 'Hra byla úspěšně odstraněna.';
        header("Location: /?success=" . urlencode($success));
        exit;
    } catch (PDOException $e) {
        $error = 'Chyba při odstraňování hry: ' . htmlspecialchars($e->getMessage());
    }
}

// Handle stats update
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'update') {
    try {
        $stmt = $pdo->prepare("SELECT * FROM games WHERE user_id = :user_id");
        $stmt->execute([":user_id" => $userId]);
        $games = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($games as $game) {
            $gameId = $game['id'];
            $gameName = $game['name'];
            $stats = [];

            // Fetch existing stats to get usernames/regions
            $statStmt = $pdo->prepare("SELECT stat_key, stat_value FROM game_stats WHERE game_id = :game_id");
            $statStmt->execute([":game_id" => $gameId]);
            $existingStats = $statStmt->fetchAll(PDO::FETCH_ASSOC);
            $statMap = [];
            foreach ($existingStats as $stat) {
                $value = json_decode($stat["stat_value"], true);
                $statMap[$stat["stat_key"]] = $value !== null && json_last_error() === JSON_ERROR_NONE ? $value : $stat["stat_value"];
            }

            if ($gameName === "League of Legends") {
                $riotName = $statMap['riot_name'] ?? '';
                $riotTag = $statMap['riot_tag'] ?? '';
                $platformRegion = $statMap['platform_region'] ?? '';
                $globalRegion = $statMap['global_region'] ?? '';
                if ($riotName && $riotTag && $platformRegion && $globalRegion) {
                    $stats = fetchLoLStats($riotName, $riotTag, $platformRegion, $globalRegion);
                    if ($stats) {
                        $stats["riot_name"] = $riotName;
                        $stats["riot_tag"] = $riotTag;
                        $stats["platform_region"] = $platformRegion;
                        $stats["global_region"] = $globalRegion;
                    }
                }
            } elseif ($gameName === "Chess.com") {
                $chessName = $statMap['chess_name'] ?? '';
                if ($chessName) {
                    $stats = fetchChessStats($chessName);
                    if ($stats) {
                        $stats["chess_name"] = $chessName;
                    }
                }
            } elseif ($gameName === "Clash Royale") {
                $royaleTag = $statMap['royale_tag'] ?? '';
                if ($royaleTag) {
                    $stats = fetchRoyaleStats($royaleTag);
                    if ($stats) {
                        $stats["royale_tag"] = $royaleTag;
                    }
                }
            } elseif ($gameName === "jiná") {
                // Handle other games (manual entry)
                $stats = $statMap; // Keep existing stats for manual games
            } else {
                // Skip manual games
                continue;
            }

            if (!empty($stats)) {
                // Clear existing stats
                $pdo->prepare("DELETE FROM game_stats WHERE game_id = :game_id")->execute([":game_id" => $gameId]);
                // Insert new stats
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
        $success = 'Statistiky byly úspěšně aktualizovány.';
        header("Location: /?success=" . urlencode($success));
        exit;
    } catch (PDOException $e) {
        $error = 'Chyba při aktualizaci statistik: ' . htmlspecialchars($e->getMessage());
    }
}

// Handle stats export
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['action']) && $_POST['action'] === 'export') {
    try {
        $stmt = $pdo->prepare("SELECT * FROM games WHERE user_id = :user_id");
        $stmt->execute([":user_id" => $userId]);
        $games = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $xml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><games></games>');
        foreach ($games as $game) {
            $gameNode = $xml->addChild('game');
            $gameNode->addChild('name', htmlspecialchars($game['name']));
            $statsNode = $gameNode->addChild('stats');
            $statStmt = $pdo->prepare("SELECT stat_key, stat_value FROM game_stats WHERE game_id = :game_id");
            $statStmt->execute([":game_id" => $game['id']]);
            $stats = $statStmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($stats as $stat) {
                $statNode = $statsNode->addChild('stat');
                $statNode->addAttribute('key', htmlspecialchars($stat['stat_key']));
                $statNode->addAttribute('value', htmlspecialchars($stat['stat_value']));
            }
        }

        header('Content-Type: application/xml');
        header('Content-Disposition: attachment; filename="game_stats.xml"');
        echo $xml->asXML();
        exit;
    } catch (PDOException $e) {
        $error = 'Chyba při exportu statistik: ' . htmlspecialchars($e->getMessage());
    }
}

// Fetch games
$stmt = $pdo->prepare("SELECT * FROM games WHERE user_id = :user_id");
$stmt->execute([":user_id" => $userId]);
$games = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Game icons
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
        // Define togglePanel globally
        function togglePanel(index) {
            const panel = document.getElementById('panel-' + index);
            const button = panel.previousElementSibling;
            const isOpen = panel.style.display === 'block';
            
            panel.style.display = isOpen ? 'none' : 'block';
            button.setAttribute('aria-expanded', !isOpen);
            button.classList.toggle('active', !isOpen);
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>🎮 Můj herní přehled</h1>

        <?php if ($error): ?>
            <div class="alert alert-error">
                <span>❌ <?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>
        <?php if ($success): ?>
            <div class="alert alert-success">
                <span>✅ <?= htmlspecialchars($success) ?></span>
            </div>
        <?php endif; ?>

        <?php if (empty($games)): ?>
            <div class="no-games">
                <p>❗ Zatím nemáš přidané žádné hry.</p>
                <a href="/add_game" class="btn">Přidat první hru</a>
            </div>
        <?php else: ?>
            <?php foreach ($games as $index => $game): ?>
                <div class="accordion-item <?= str_replace('.', '-', strtolower($game['name'])) ?>">
                    <button 
                        class="accordion-button" 
                        onclick="togglePanel(<?= $index ?>)"
                        aria-expanded="false"
                        aria-controls="panel-<?= $index ?>"
                    >
                        <span>
                            <?= isset($gameIcons[$game["name"]]) ? $gameIcons[$game["name"]] . ' ' : '' ?>
                            <?= htmlspecialchars($game["name"]) ?>
                        </span>
                        <span class="accordion-icon"></span>
                    </button>
                    <div class="accordion-panel" id="panel-<?= $index ?>" role="region">
                        <?php
                        $statStmt = $pdo->prepare("SELECT stat_key, stat_value FROM game_stats WHERE game_id = :game_id");
                        $statStmt->execute([":game_id" => $game["id"]]);
                        $stats = $statStmt->fetchAll(PDO::FETCH_ASSOC);

                        $statMap = [];
                        foreach ($stats as $stat) {
                            $value = json_decode($stat["stat_value"], true);
                            $statMap[$stat["stat_key"]] = $value !== null && json_last_error() === JSON_ERROR_NONE
                                ? $value
                                : $stat["stat_value"];
                        }
                        ?>        
                            <ul>
                                <?php foreach ($statMap as $key => $value): ?>
                                    <li>
                                        <strong><?= htmlspecialchars($key) ?>:</strong>
                                        <?php
                                        if (is_array($value)) {
                                            echo "<ul>";
                                            foreach ($value as $k => $v) {
                                                echo "<li><em>" . htmlspecialchars($k) . ":</em> " . htmlspecialchars((string)$v) . "</li>";
                                            }
                                            echo "</ul>";
                                        } else {
                                            echo htmlspecialchars((string)$value);
                                        }
                                        ?>
                                    </li>
                                <?php endforeach; ?>
                            </ul>
                        <div class="game-actions">
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

        <div class="actions">
            <a href="/add_game" class="btn">➕ Přidat další hru</a>
            <?php if (!empty($games)): ?>
                <form method="POST" style="display: inline;">
                    <input type="hidden" name="action" value="update">
                    <button type="submit" class="btn">🔄 Aktualizovat statistiky</button>
                </form>
                <form method="POST" style="display: inline;">
                    <input type="hidden" name="action" value="export">
                    <button type="submit" class="btn">📤 Exportovat statistiky</button>
                </form>
            <?php endif; ?>
            <a href="/logout" class="btn secondary">🚪 Odhlásit se</a>
        </div>
    </div>

    <script>
        // Initialize accordion panels on page load
        document.addEventListener('DOMContentLoaded', () => {
            document.querySelectorAll('.accordion-panel').forEach(panel => {
                panel.style.display = 'none';
            });
        });
    </script>
</body>
</html>