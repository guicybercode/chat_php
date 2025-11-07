<?php
// Configuração do banco de dados MySQL

define('DB_HOST', 'localhost');
define('DB_NAME', 'chat_online');
// Para Arch Linux: crie um usuário específico ou use root com senha
// Opção 1: Usar usuário específico (recomendado)
define('DB_USER', 'chat_user');
define('DB_PASS', 'chat123');
// Opção 2: Usar root com senha (se configurou)
// define('DB_USER', 'chat_user');
// define('DB_PASS', 'chat123');
define('DB_CHARSET', 'utf8mb4');

// Função para obter conexão PDO
function getDBConnection() {
    try {
        // Tentar conexão normal primeiro
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];
        
        try {
            return new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            // Se falhar, tentar com socket (Arch Linux)
            if (file_exists('/run/mysqld/mysqld.sock')) {
                $dsn = "mysql:unix_socket=/run/mysqld/mysqld.sock;dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
                return new PDO($dsn, DB_USER, DB_PASS, $options);
            }
            throw $e;
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
        exit;
    }
}

// Headers CORS
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}


