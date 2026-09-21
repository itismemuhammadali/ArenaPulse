<?php
require_once __DIR__ . '/config.php';

set_cors_headers();
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'status' => 'error',
        'message' => 'Method Not Allowed. Use POST.'
    ]);
    exit();
}

// Check if file was uploaded
if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
    $errorCode = $_FILES['file']['error'] ?? 'no_file';
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'No file uploaded or upload error occurred.',
        'error_code' => $errorCode
    ]);
    exit();
}

$file = $_FILES['file'];

// Check file size
if ($file['size'] > MAX_FILE_SIZE) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'File exceeds maximum allowed size of 25MB.'
    ]);
    exit();
}

// Validate target folder
$folder = isset($_POST['folder']) ? trim(strtolower($_POST['folder'])) : 'general';
if (!in_array($folder, ALLOWED_FOLDERS)) {
    $folder = 'general';
}

// Validate file extension
$extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
if (!in_array($extension, ALLOWED_EXTENSIONS)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'File extension not permitted. Allowed: ' . implode(', ', ALLOWED_EXTENSIONS)
    ]);
    exit();
}

// Validate MIME type with finfo if available
if (function_exists('finfo_open')) {
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    if (!in_array($mimeType, ALLOWED_MIMES)) {
        http_response_code(400);
        echo json_encode([
            'status' => 'error',
            'message' => 'Invalid file MIME type (' . $mimeType . ').'
        ]);
        exit();
    }
}

// Ensure target directory exists
$targetDir = UPLOAD_DIR . $folder . '/';
if (!is_dir($targetDir)) {
    if (!mkdir($targetDir, 0755, true)) {
        http_response_code(500);
        echo json_encode([
            'status' => 'error',
            'message' => 'Failed to create upload directory on server.'
        ]);
        exit();
    }
}

// Generate unique, collision-resistant filename
try {
    $randomBytes = bin2hex(random_bytes(8));
} catch (Exception $e) {
    $randomBytes = uniqid();
}
$newFileName = time() . '_' . $randomBytes . '.' . $extension;
$destinationPath = $targetDir . $newFileName;

// Move uploaded file
if (!move_uploaded_file($file['tmp_name'], $destinationPath)) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Failed to save uploaded file on server.'
    ]);
    exit();
}

// Build public URL
// If PHP script is in /backend, the file is accessible at BASE_URL/backend/uploads/folder/filename or BASE_URL/uploads/folder/filename
// We compute relative path from the server root
$scriptDir = dirname($_SERVER['SCRIPT_NAME']);
$relativeUploadUrl = rtrim($scriptDir, '/') . '/uploads/' . $folder . '/' . $newFileName;
$fullUrl = BASE_URL . $relativeUploadUrl;

http_response_code(200);
echo json_encode([
    'status' => 'success',
    'message' => 'File uploaded successfully.',
    'url' => $fullUrl,
    'filename' => $newFileName,
    'folder' => $folder,
    'size' => $file['size']
]);
