<?php
session_start();

/* ===== CONFIG (ONLY HASH STORED) ===== */
$PASSWORD_HASH = md5("fbf57fc6791bf90d94d8bb6c860772b5");  // only hash, no plain password stored

$UPLOAD_DIR = __DIR__ . "/uploads/";
$ALLOWED = ['image/jpeg','image/png','application/pdf'];

/* ===== AUTH CHECK ===== */
if (isset($_GET['p'])) {

    $input_hash = md5($_GET['p']);

    if (hash_equals($PASSWORD_HASH, $input_hash)) {
        $_SESSION['auth'] = true;
    } else {
        die("Wrong password");
    }
}

/* ===== LOGOUT ===== */
if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: uploader.php");
    exit;
}

/* ===== UPLOAD ===== */
if (isset($_SESSION['auth']) && isset($_FILES['file'])) {

    if ($_FILES['file']['error'] === UPLOAD_ERR_OK) {

        $tmp = $_FILES['file']['tmp_name'];
        $mime = mime_content_type($tmp);

        if (!in_array($mime, $ALLOWED)) {
            die("Invalid file type");
        }

        if (!is_dir($UPLOAD_DIR)) {
            mkdir($UPLOAD_DIR, 0700, true);
        }

        $name = bin2hex(random_bytes(8)) . "_" . basename($_FILES['file']['name']);

        move_uploaded_file($tmp, $UPLOAD_DIR . $name);

        echo "Uploaded successfully<br><a href='uploader.php'>Back</a>";
        exit;
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Hash Uploader</title>
</head>
<body>

<h2>File Uploader</h2>

<?php if (empty($_SESSION['auth'])): ?>

<p>Login via URL:</p>
<code>?p=test123</code>

<?php else: ?>

<form method="POST" enctype="multipart/form-data">
    <input type="file" name="file" required>
    <button type="submit">Upload</button>
</form>

<br>
<a href="?logout=1">Logout</a>

<?php endif; ?>

</body>
</html>
