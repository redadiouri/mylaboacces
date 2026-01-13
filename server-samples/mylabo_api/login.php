<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    echo json_encode(['success' => false, 'message' => 'Invalid JSON']);
    exit;
}

$identifier = trim($input['identifier'] ?? ''); // email or nom
$password = $input['password'] ?? '';

if (empty($identifier) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'Identifier and password required']);
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

    // Fetch user
    $stmt = $pdo->prepare('SELECT id, email, nom, password_hash, role FROM users WHERE email = ? OR nom = ? LIMIT 1');
    $stmt->execute([$identifier, $identifier]);
    $user = $stmt->fetch();

    if (!$user) {
        echo json_encode(['success' => false, 'message' => 'Utilisateur non trouvé']);
        exit;
    }

    if (!password_verify($password, $user['password_hash'])) {
        echo json_encode(['success' => false, 'message' => 'Mot de passe incorrect']);
        exit;
    }

    // --- NEW: Generate a token and store in user_tokens ---
    $token = bin2hex(random_bytes(32)); // 64-character secure token

    $stmt = $pdo->prepare("
        INSERT INTO user_tokens (user_id, token, user_agent, ip_address)
        VALUES (?, ?, ?, ?)
    ");
    $stmt->execute([
        $user['id'],
        $token,
        $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
        $_SERVER['REMOTE_ADDR'] ?? 'unknown'
    ]);

    // Successful login response
    echo json_encode([
        'success' => true,
        'message' => 'Connexion réussie',
        'email' => $user['email'],
        'role' => $user['role'],
        'nom' => $user['nom'],
        'api_token' => $token
    ]);

} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur serveur: ' . $e->getMessage()]);
}
