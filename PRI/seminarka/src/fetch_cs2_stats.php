<?php
function fetchCS2Stats($steamId64) {
    $url = "https://csstats.gg/player/" . $steamId64;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0');
    $html = curl_exec($ch);
    file_put_contents("debug_csstats.html", $html);
    curl_close($ch);

    if (!$html) return null;

    $dom = new DOMDocument();
    libxml_use_internal_errors(true);
    $dom->loadHTML($html);
    libxml_clear_errors();
    $xpath = new DOMXPath($dom);

    // ✅ Získání ranku (číslo ratingu)
    $rankNode = $xpath->query("//div[contains(@class, 'cs2rating')]/span");
    if ($rankNode->length > 0) {
        $rankRaw = trim($rankNode->item(0)->textContent); // např. "15,739"
        $rank = str_replace(',', '', $rankRaw); // => 15739
    } else {
        $rank = null;
    }

    // ✅ Získání počtu výher
    $winsNode = $xpath->query("//div[contains(@class, 'wins')]/span/b");
    $wins = ($winsNode->length > 0) ? intval(trim($winsNode->item(0)->nodeValue)) : 0;

    return [
        'rank' => $rank,
        'wins' => $wins
    ];
}
