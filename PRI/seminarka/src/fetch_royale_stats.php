<?php
require_once __DIR__ . '/../vendor/autoload.php';

$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/../');
$dotenv->safeLoad();

$royaleToken = $_ENV['ROYALE_TOKEN'] ?? '';

function fetchRoyaleStats($playerTag) {
    global $royaleToken;

    // Ensure player tag starts with '#' and is URL-encoded
    $playerTag = ltrim($playerTag, '#');
    $url = "https://api.clashroyale.com/v1/players/%23" . urlencode($playerTag);


    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_TIMEOUT => 10,
        CURLOPT_USERAGENT => 'MyGameStatsApp/1.0',
        CURLOPT_HTTPHEADER => [
            "Authorization: Bearer $royaleToken"
        ]
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err = curl_error($ch);
    curl_close($ch);

    if ($err || !$response || $httpCode !== 200) {
        error_log("Clash Royale API error: HTTP $httpCode, Error: $err");
        return null;
    }

    $data = json_decode($response, true);
    if (!$data || json_last_error() !== JSON_ERROR_NONE) {
        error_log("Clash Royale API: Invalid JSON response");
        return null;
    }

    $result = [];

    // Extract relevant stats
    if (isset($data['name'])) {
        $result['player_name'] = $data['name'];
    }
    if (isset($data['tag'])) {
        $result['player_tag'] = $data['tag'];
    }
    if (isset($data['trophies'])) {
        $result['trophies'] = $data['trophies'];
    }
    if (isset($data['bestTrophies'])) {
        $result['best_trophies'] = $data['bestTrophies'];
    }
    if (isset($data['level'])) {
        $result['level'] = $data['level'];
    }
    if (isset($data['wins'])) {
        $result['wins'] = $data['wins'];
    }
    if (isset($data['losses'])) {
        $result['losses'] = $data['losses'];
    }
    if (isset($data['clan']['name'])) {
        $result['clan_name'] = $data['clan']['name'];
    }

    $result['royale_tag'] = '#' . $playerTag;

    return $result;
}
?>