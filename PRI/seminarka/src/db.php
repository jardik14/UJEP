<?php
$host = 'db';
$db = 'gamerank';
$user = 'user';
$pass = 'password';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$db", $user, $pass);
} catch (PDOException $e) {
    die("Database connection failed: " . $e->getMessage());
}
?>
