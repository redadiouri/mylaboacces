<?php
/**
 * Endpoint pour récupérer TOUTES les demandes d'emprunt (pour l'admin)
 * 
 * Réponse JSON:
 *  - success: boolean
 *  - data: array de toutes les demandes d'emprunt
 *  - count: nombre total de demandes
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

try {
    // Configuration de la base de données
    $host = 'localhost';
    $dbname = 'mylaboipi';
    $username = 'root';
    $password = '';

    // Connexion PDO
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Récupérer TOUTES les demandes d'emprunt
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
        ORDER BY submitted_at DESC
    ");
    
    $stmt->execute();
    $requests = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Compter les demandes en attente
    $pendingCount = 0;
    foreach ($requests as $request) {
        if ($request['status'] === 'En attente') {
            $pendingCount++;
        }
    }

    echo json_encode([
        'success' => true,
        'data' => $requests,
        'count' => count($requests),
        'pending_count' => $pendingCount
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
