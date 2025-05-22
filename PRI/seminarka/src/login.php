<?php
require_once 'db.php';

$error = '';

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $username = trim($_POST["username"] ?? '');
    $password = $_POST["password"] ?? '';

    if (empty($username) || empty($password)) {
        $error = 'Prosím, vyplňte všechny povinné údaje.';
    } else {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE username = :username");
        $stmt->execute([":username" => $username]);
        $user = $stmt->fetch();

        if ($user && password_verify($password, $user['password'])) {
            $_SESSION["user_id"] = $user["id"];
            $_SESSION["username"] = $user["username"];
            header("Location: /");
            exit;
        } else {
            $error = 'Neplatné přihlašovací údaje.';
        }
    }
}
?>

<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Přihlášení</title>
    <link rel="stylesheet" href="/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <h1>🔒 Přihlášení</h1>

        <?php if ($error): ?>
            <div class="alert alert-error">
                <span>❌ <?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>

        <form method="POST" class="form-card">
            <div class="form-group">
                <label for="username">Uživatelské jméno:</label>
                <input type="text" name="username" id="username" required aria-describedby="username-help">
                <small id="username-help" class="form-help">Zadejte vaše uživatelské jméno.</small>
            </div>
            <div class="form-group">
                <label for="password">Heslo:</label>
                <input type="password" name="password" id="password" required aria-describedby="password-help">
                <small id="password-help" class="form-help">Zadejte vaše heslo.</small>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn">Přihlásit se</button>
                <a href="/register" class="btn secondary">Registrovat se</a>
            </div>
        </form>
    </div>
</body>
</html>