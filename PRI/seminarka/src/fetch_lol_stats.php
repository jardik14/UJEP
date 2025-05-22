<?php
require_once __DIR__ . '/../vendor/autoload.php';

$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/../');
$dotenv->safeLoad();

$riotApiKey = $_ENV['RIOT_API_KEY'];


function fetchLoLStats($riotName, $tagline, $platformRegion = 'eun1', $globalRegion = 'europe') {
    global $riotApiKey;

    // 1. Get account info from Riot ID (name + tag)
    $riotIdUrl = "https://$globalRegion.api.riotgames.com/riot/account/v1/accounts/by-riot-id/" . urlencode($riotName) . "/" . urlencode($tagline) . "?api_key=$riotApiKey";
    $riotResponse = file_get_contents($riotIdUrl);
    if ($riotResponse === false) return null;

    $riotData = json_decode($riotResponse, true);
    if (!isset($riotData["puuid"])) return null;

    $puuid = $riotData["puuid"];

    // 2. Get ranked stats by PUUID
    $rankedUrl = "https://$platformRegion.api.riotgames.com/lol/league/v4/entries/by-puuid/$puuid?api_key=$riotApiKey";
    $rankedResponse = file_get_contents($rankedUrl);
    if ($rankedResponse === false) return null;

    $rankedData = json_decode($rankedResponse, true);

    foreach ($rankedData as $entry) {
        if ($entry["queueType"] === "RANKED_SOLO_5x5") {
            return [
                "tier" => $entry["tier"],   // e.g. EMERALD
                "rank" => $entry["rank"],   // e.g. I
                "wins" => $entry["wins"],
                "losses" => $entry["losses"]
            ];
        }
    }

    return null; // If no ranked solo data found
}
