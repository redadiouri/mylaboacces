<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
  echo json_encode(['success' => false, 'message' => 'Invalid JSON']);
  exit;
}

$user_email = trim($input['user_email'] ?? '');
$equipment_name = trim($input['equipment_name'] ?? '');
$quantity = (int)($input['quantity'] ?? 1);
$description = trim($input['description'] ?? '');

try {
  $dbHost = '127.0.0.1';
  $dbName = 'mylaboipi';
  $dbUser = 'root';
  $dbPass = '';

  $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4", $dbUser, $dbPass, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
  ]);

  // Try to find user id by email (optional)
  $userId = null;
  if (!empty($user_email)) {
    $s = $pdo->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
    $s->execute([$user_email]);
    $row = $s->fetch();
    if ($row) $userId = $row['id'];
  }

  $stmt = $pdo->prepare('INSERT INTO reports (user_id, equipment_name, quantity, description) VALUES (?, ?, ?, ?)');
  $stmt->execute([$userId, $equipment_name, $quantity, $description]);

  echo json_encode(['success' => true, 'message' => 'Signalement enregistré']);
} catch (Exception $e) {
  echo json_encode(['success' => false, 'message' => 'Erreur serveur: ' . $e->getMessage()]);
}
