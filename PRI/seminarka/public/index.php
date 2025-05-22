<?php
session_start();

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// základní DB připojení
require_once __DIR__ . '/../src/db.php';

switch ($uri) {
    case '/':
        if (!isset($_SESSION['user_id'])) {
            header("Location: /login");
            exit;
        }
        require_once __DIR__ . '/../src/dashboard.php';
        break;

    case '/login':
        require_once __DIR__ . '/../src/login.php';
        break;

    case '/register':
        require_once __DIR__ . '/../src/register.php';
        break;

    case '/logout':
        require_once __DIR__ . '/../src/logout.php';
        break;

    case '/add_game':
        require_once __DIR__ . '/../src/add_game.php';
        break;

    default:
        http_response_code(404);
        echo "404 - stránka nenalezena.";
}
