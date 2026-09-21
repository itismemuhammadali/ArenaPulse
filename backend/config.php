<?php
/**
 * SprintIndex PHP Backend Configuration
 * 
 * When deploying to live cPanel / shared hosting:
 * Update BASE_URL to your domain (e.g. 'https://yourdomain.com/backend')
 */

// Detect protocol and host dynamically if BASE_URL is not manually hardcoded
$protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' || (isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT'] == 443)) ? "https://" : "http://";
$host = $_SERVER['HTTP_HOST'] ?? 'localhost:8080';
define('BASE_URL', $protocol . $host);

// Allowed upload file extensions and MIME types
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'webp', 'gif', 'mp4', 'mov']);
define('ALLOWED_MIMES', [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'video/mp4',
    'video/quicktime'
]);

// Maximum file size in bytes (e.g., 25 MB)
define('MAX_FILE_SIZE', 25 * 1024 * 1024);

// Base directory for uploads
define('UPLOAD_DIR', __DIR__ . '/uploads/');

// Allowed subfolders for organizing media
define('ALLOWED_FOLDERS', ['profiles', 'posts', 'clubs', 'facilities', 'nets', 'general']);

// CORS headers for Web and Mobile client requests
function set_cors_headers() {
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS, DELETE");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
    
    // Handle preflight OPTIONS request
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}
