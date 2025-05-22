<?php
require_once __DIR__ . '/../vendor/autoload.php';

$dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->safeLoad();

$rlApiKey = $_ENV['RAPID_API_KEY'];
$host = 'rocket-league1.p.rapidapi.com';

function fetchRocketLeagueStats($playerName) {
    global $rlApiKey, $host;

    $url = "https://rocket-league1.p.rapidapi.com/ranks/" . urlencode($playerName);

    $curl = curl_init();

    curl_setopt_array($curl, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            "X-RapidAPI-Key: $rlApiKey",
            "X-RapidAPI-Host: $host"
        ]
    ]);

    $response = curl_exec($curl);
    $err = curl_error($curl);
    curl_close($curl);

    if ($err || !$response) return null;

    $data = json_decode($response, true);
    return $data;
}
