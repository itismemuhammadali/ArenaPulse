<?php
require_once __DIR__ . '/config.php';

set_cors_headers();
header('Content-Type: application/json');

echo json_encode([
    'status' => 'online',
    'service' => 'SprintIndex PHP Media & Storage Backend',
    'version' => '1.0.0',
    'base_url' => BASE_URL,
    'endpoints' => [
        'POST /upload.php' => 'Upload a media file (fields: file [binary], folder [optional: profiles, posts, clubs, facilities, nets])',
        'POST /delete.php' => 'Delete an uploaded file (fields: url [string])'
    ],
    'max_upload_size' => '25MB',
    'timestamp' => date('Y-m-d H:i:s')
], JSON_PRETTY_PRINT);
