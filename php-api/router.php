<?php
// Router simples para servir frontend e API

$request_uri = $_SERVER['REQUEST_URI'];
$request_path = parse_url($request_uri, PHP_URL_PATH);

// Se for requisição para API
if (strpos($request_path, '/php-api/') === 0) {
    // Remover /php-api do path
    $api_path = substr($request_path, strlen('/php-api'));
    
    // Roteamento da API
    if ($api_path === '/user' || $api_path === '/user.php') {
        require __DIR__ . '/user.php';
        exit;
    }
    
    if ($api_path === '/messages' || $api_path === '/messages.php') {
        require __DIR__ . '/messages.php';
        exit;
    }
    
    // Se não encontrou, retornar 404
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint not found']);
    exit;
}

// Se não for API, servir arquivo estático do frontend
$frontend_path = __DIR__ . '/../public' . $request_path;

// Se for raiz, servir index.html
if ($request_path === '/' || $request_path === '') {
    $frontend_path = __DIR__ . '/../public/index.html';
}

// Se arquivo existe, servir
if (file_exists($frontend_path) && is_file($frontend_path)) {
    $mime_types = [
        'html' => 'text/html',
        'css' => 'text/css',
        'js' => 'application/javascript',
        'json' => 'application/json',
        'png' => 'image/png',
        'jpg' => 'image/jpeg',
        'gif' => 'image/gif',
        'svg' => 'image/svg+xml',
    ];
    
    $ext = pathinfo($frontend_path, PATHINFO_EXTENSION);
    $mime = $mime_types[$ext] ?? 'text/plain';
    
    header('Content-Type: ' . $mime);
    readfile($frontend_path);
    exit;
}

// 404
http_response_code(404);
echo "File not found";

