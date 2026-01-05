<?php
header('Content-Type: application/json');
// Dev helper: allow requests from any origin (only for local dev)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
  echo json_encode(['success' => false, 'message' => 'Invalid JSON']);
  exit;
}

$email = trim($input['email'] ?? '');
$nom = trim($input['nom'] ?? '');
$role = $input['role'] ?? 'utilisateur';
$password = $input['password'] ?? '';

if (empty($email) || empty($password)) {
  echo json_encode(['success' => false, 'message' => 'Email and password required']);
  exit;
}

try {
  // Update these credentials to match your Laragon/MySQL setup
  $dbHost = '127.0.0.1';
  $dbName = 'mylaboipi';
  $dbUser = 'root';
  $dbPass = '';

  $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4", $dbUser, $dbPass, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
  ]);

  // Check if user exists
  $stmt = $pdo->prepare('SELECT id, email FROM users WHERE email = ? LIMIT 1');
  $stmt->execute([$email]);
  $user = $stmt->fetch();

  if ($user) {
    // For the original app, the register endpoint was used as "create if missing".
    echo json_encode(['success' => false, 'message' => 'Utilisateur déjà inscrit']);
    exit;
  }

  $password_hash = password_hash($password, PASSWORD_DEFAULT);

  $stmt = $pdo->prepare('INSERT INTO users (email, nom, password_hash, role) VALUES (?, ?, ?, ?)');
  $stmt->execute([$email, $nom, $password_hash, $role]);

  echo json_encode(['success' => true, 'message' => 'Inscription réussie']);
} catch (Exception $e) {
  echo json_encode(['success' => false, 'message' => 'Erreur serveur: ' . $e->getMessage()]);
}
