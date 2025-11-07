<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // Buscar histórico de mensagens
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 50;
    $limit = min(max($limit, 1), 100); // Limitar entre 1 e 100
    
    try {
        $pdo = getDBConnection();
        $stmt = $pdo->prepare("SELECT id, username, message, created_at FROM messages ORDER BY created_at DESC LIMIT ?");
        $stmt->bindValue(1, $limit, PDO::PARAM_INT);
        $stmt->execute();
        $messages = $stmt->fetchAll();
        
        // Reverter ordem para mostrar mais antigas primeiro
        $messages = array_reverse($messages);
        
        echo json_encode([
            'success' => true,
            'messages' => $messages
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
} else if ($method === 'POST') {
    // Salvar mensagem (opcional, Phoenix também pode salvar)
    $data = json_decode(file_get_contents('php://input'), true);
    $username = trim($data['username'] ?? '');
    $message = trim($data['message'] ?? '');
    
    if (empty($username) || empty($message)) {
        http_response_code(400);
        echo json_encode(['error' => 'Username and message are required']);
        exit;
    }
    
    if (strlen($message) > 1000) {
        http_response_code(400);
        echo json_encode(['error' => 'Message too long (max 1000 characters)']);
        exit;
    }
    
    try {
        $pdo = getDBConnection();
        $stmt = $pdo->prepare("INSERT INTO messages (username, message) VALUES (?, ?)");
        $stmt->execute([$username, $message]);
        
        $messageId = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => [
                'id' => $messageId,
                'username' => $username,
                'message' => $message,
                'created_at' => date('Y-m-d H:i:s')
            ]
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}


