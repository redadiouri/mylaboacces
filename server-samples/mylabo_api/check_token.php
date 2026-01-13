<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

$input = json_decode(file_get_contents('php://input'), true);
$token = $input['api_token'] ?? '';

if (empty($token)) {
    echo json_encode(['success' => false, 'message' => 'Token required']);
    exit;
}

try {
    $dbHost = '127.0.0.1';
    $dbName = 'mylaboipi';
    $dbUser = 'root';
    $dbPass = '';

    $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4", $dbUser, $dbPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    // --- NEW: validate token against user_tokens ---
    $stmt = $pdo->prepare("
        SELECT u.id, u.email, u.nom, u.role
        FROM user_tokens t
        JOIN users u ON u.id = t.user_id
        WHERE t.token = ?
        LIMIT 1
    ");
    $stmt->execute([$token]);
    $user = $stmt->fetch();

    if (!$user) {
        echo json_encode(['success' => false, 'message' => 'Invalid token']);
        exit;
    }

    // Optional: update last_used_at
    $stmt = $pdo->prepare("UPDATE user_tokens SET last_used_at = NOW() WHERE token = ?");
    $stmt->execute([$token]);

    // Token valid, return user info
    echo json_encode([
        'success' => true,
        'email' => $user['email'],
        'nom' => $user['nom'],
        'role' => $user['role']
    ]);

} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
}
