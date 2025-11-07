<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);
    $username = trim($data['username'] ?? '');
    
    if (empty($username) || strlen($username) < 2 || strlen($username) > 50) {
        http_response_code(400);
        echo json_encode(['error' => 'Username must be between 2 and 50 characters']);
        exit;
    }
    
    // Sanitizar username (apenas letras, números, espaços e alguns caracteres especiais)
    if (!preg_match('/^[a-zA-Z0-9\s_\-]+$/', $username)) {
        http_response_code(400);
        echo json_encode(['error' => 'Username contains invalid characters']);
        exit;
    }
    
    try {
        $pdo = getDBConnection();
        
        // Verificar se usuário já existe
        $stmt = $pdo->prepare("SELECT id, username, created_at FROM users WHERE username = ?");
        $stmt->execute([$username]);
        $user = $stmt->fetch();
        
        if ($user) {
            // Usuário já existe, retornar dados
            echo json_encode([
                'success' => true,
                'user' => [
                    'id' => $user['id'],
                    'username' => $user['username'],
                    'created_at' => $user['created_at']
                ]
            ]);
        } else {
            // Criar novo usuário
            $stmt = $pdo->prepare("INSERT INTO users (username) VALUES (?)");
            $stmt->execute([$username]);
            
            $userId = $pdo->lastInsertId();
            
            echo json_encode([
                'success' => true,
                'user' => [
                    'id' => $userId,
                    'username' => $username,
                    'created_at' => date('Y-m-d H:i:s')
                ]
            ]);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}


