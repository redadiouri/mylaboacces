<?php
/**
 * Endpoint pour récupérer les demandes d'emprunt d'un utilisateur
 * 
 * Paramètres GET:
 *  - user_email: email de l'utilisateur
 * 
 * Réponse JSON:
 *  - success: boolean
 *  - data: array de demandes d'emprunt
 *  - count: nombre de demandes
 *  - message: message en cas d'erreur
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

// Récupérer l'email depuis les paramètres GET
$userEmail = isset($_GET['user_email']) ? trim($_GET['user_email']) : '';

if (empty($userEmail)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Email utilisateur requis'
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

    // Préparer et exécuter la requête
    $stmt = $pdo->prepare("
        SELECT 
            id, 
            equipment_name, 
            user_email, 
            quantity, 
            purpose,
            duration,
            status, 
            submitted_at as created_at
        FROM borrow_requests 
        WHERE user_email = ? 
        ORDER BY submitted_at DESC
    ");
    
    $stmt->execute([$userEmail]);
    $requests = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'data' => $requests,
        'count' => count($requests)
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
?>
