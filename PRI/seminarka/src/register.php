<?php
require_once 'db.php';

$error = '';
$success = '';

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $username = trim($_POST["username"] ?? '');
    $password = $_POST["password"] ?? '';

    if (empty($username) || empty($password)) {
        $error = 'Prosím, vyplňte všechny povinné údaje.';
    } elseif (strlen($password) < 8) {
        $error = 'Heslo musí mít alespoň 8 znaků.';
    } else {
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM users WHERE username = :username");
        $stmt->execute([":username" => $username]);
        if ($stmt->fetchColumn() > 0) {
            $error = 'Uživatelské jméno již existuje.';
        } else {
            $passwordHash = password_hash($password, PASSWORD_DEFAULT);
            $stmt = $pdo->prepare("INSERT INTO users (username, password) VALUES (:username, :password)");
            try {
                $stmt->execute([
                    ":username" => $username,
                    ":password" => $passwordHash
                ]);
                $success = 'Registrace úspěšná! Nyní se můžete přihlásit.';
            } catch (PDOException $e) {
                $error = 'Chyba při registraci: ' . htmlspecialchars($e->getMessage());
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrace</title>
    <link rel="stylesheet" href="/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <h1>📝 Registrace</h1>

        <?php if ($error): ?>
            <div class="alert alert-error">
                <span>❌ <?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>
        <?php if ($success): ?>
            <div class="alert alert-success">
                <span>✅ <?= htmlspecialchars($success) ?> <a href="/login" class="alert-link">Přihlásit se</a></span>
            </div>
        <?php endif; ?>

        <form method="POST" class="form-card">
            <div class="form-group">
                <label for="username">Uživatelské jméno:</label>
                <input type="text" name="username" id="username" required aria-describedby="username-help">
                <small id="username-help" class="form-help">Zadejte jedinečné uživatelské jméno.</small>
            </div>
            <div class="form-group">
                <label for="password">Heslo:</label>
                <input type="password" name="password" id="password" required aria-describedby="password-help">
                <small id="password-help" class="form-help">Heslo musí mít alespoň 8 znaků.</small>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn">Registrovat</button>
                <a href="/login"