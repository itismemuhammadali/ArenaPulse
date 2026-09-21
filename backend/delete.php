<?php
require_once __DIR__ . '/config.php';

set_cors_headers();
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST' && $_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    http_response_code(405);
    echo json_encode([
        'status' => 'error',
        'message' => 'Method Not Allowed. Use POST or DELETE.'
    ]);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
$fileUrl = $_POST['url'] ?? ($input['url'] ?? null);

if (!$fileUrl) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'File URL is required.'
    ]);
    exit();
}

// Extract relative path after /uploads/
$parts = explode('/uploads/', $fileUrl);
if (count($parts) < 2) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid file URL.'
    ]);
    exit();
}

$relativePath = $parts[1];
// Security check: prevent directory traversal
if (strpos($relativePath, '..') !== false) {
    http_response_code(403);
    echo json_encode([
        'status' => 'error',
        'message' => 'Access denied.'
    ]);
    exit();
}

$filePath = UPLOAD_DIR . $relativePath;

if (file_exists($filePath)) {
    if (@unlink($filePath)) {
        echo json_encode([
            'status' => 'success',
            'message' => 'File deleted successfully.'
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'status' => 'error',
            'message' => 'Could not delete file.'
        ]);
    }
} else {
    echo json_encode([
        'status' => 'success',
        'message' => 'File not found or already deleted.'
    ]);
}
