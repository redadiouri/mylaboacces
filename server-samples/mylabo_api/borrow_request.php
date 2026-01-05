<?php
/**
 * Endpoint pour traiter les demandes d'emprunt de matériel
 * 
 * Paramètres POST (JSON):
 *  - user_email: email de l'utilisateur
 *  - equipment_name: nom du matériel à emprunter
 *  - quantity: quantité à emprunter
 *  - purpose: objectif/projet (facultatif)
 *  - duration: durée estimée (facultatif)
 * 
 * Réponse JSON:
 *  - success: boolean
 *  - message: string
 *  - request_id: int (si succès)
 */

// Headers CORS pour permettre les requêtes depuis Flutter Web
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

// Répondre aux requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Récupérer les données JSON du body
$input = json_decode(file_get_contents('php://input'), true);

// Valider les paramètres
$errors = [];

if (empty($input['user_email'])) {
    $errors[] = "L'email utilisateur est requis";
}

if (empty($input['equipment_name'])) {
    $errors[] = "Le nom du matériel est requis";
}

if (empty($input['quantity']) || !is_numeric($input['quantity']) || $input['quantity'] < 1) {
    $errors[] = "La quantité doit être un nombre positif";
}

$purpose = $input['purpose'] ?? '';
$duration = $input['duration'] ?? '';

if (!empty($errors)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => implode(', ', $errors)
    ]);
    exit;
}

try {
    // Configuration de la base de données
    $host = 'localhost';
    $dbname = 'mylaboipi';
    $username = 'root';
    $password = '';

    // Connexion PDO
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $user_email = htmlspecialchars($input['user_email']);
    $equipment_name = htmlspecialchars($input['equipment_name']);
    $quantity = (int)$input['quantity'];
    $purpose = htmlspecialchars($purpose);
    $duration = htmlspecialchars($duration);

    // Vérifier que l'utilisateur existe
    $checkUser = $pdo->prepare("SELECT email FROM users WHERE email = ?");
    $checkUser->execute([$user_email]);
    if ($checkUser->rowCount() === 0) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => "Utilisateur non trouvé. Veuillez vous connecter avec un compte valide."
        ]);
        exit;
    }

    // Insérer la demande en base de données
    $stmt = $pdo->prepare("
        INSERT INTO borrow_requests (user_email, equipment_name, quantity, purpose, duration, status)
        VALUES (?, ?, ?, ?, ?, 'En attente')
    ");
    
    $stmt->execute([$user_email, $equipment_name, $quantity, $purpose, $duration]);
    $request_id = $pdo->lastInsertId();

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => "Demande d'emprunt de {$quantity} {$equipment_name} soumise avec succès. ID demande: {$request_id}",
        'request_id' => $request_id,
        'data' => [
            'id' => (int)$request_id,
            'user_email' => $user_email,
            'equipment_name' => $equipment_name,
            'quantity' => $quantity,
            'status' => 'En attente'
        ]
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur base de données: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur serveur: ' . $e->getMessage()
    ]);
}
