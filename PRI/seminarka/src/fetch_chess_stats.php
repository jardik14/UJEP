<?php
function fetchChessStats($username) {
    $url = "https://api.chess.com/pub/player/" . urlencode($username) . "/stats";

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_TIMEOUT => 10,
        CURLOPT_USERAGENT => 'MyGameStatsApp/1.0'
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err = curl_error($ch);
    curl_close($ch);

    if ($err || !$response || $httpCode !== 200) {
        return null;
    }

    $data = json_decode($response, true);
    if (!$data) return null;

    $result = [];

    if (isset($data['chess_rapid']['last']['rating'])) {
        $result['Rapid rating'] = $data['chess_rapid']['last']['rating'];
    }
    if (isset($data['chess_blitz']['last']['rating'])) {
        $result['Blitz rating'] = $data['chess_blitz']['last']['rating'];
    }
    if (isset($data['tactics']['highest']['rating'])) {
        $result['Tactics high'] = $data['tactics']['highest']['rating'];
    }
    if (isset($data['tactics']['lowest']['rating'])) {
        $result['Tactics low'] = $data['tactics']['lowest']['rating'];
    }

    $result['chess_username'] = $username;

    return $result;
}
