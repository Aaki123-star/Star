<?php
// ================== CONFIG ==================
$password = "wiredmouseis";
$title = "Storage";
$mainDir = __DIR__; // You can set this to any root folder you want
// ============================================

session_start();

// AUTHENTICATION
if (!isset($_SESSION['auth']) && (!isset($_POST['pass']) || $_POST['pass'] !== $password)) {
    die('
    <html><head><title>'.$title.'</title>
    <style>
    body{background:#0f0f0f;color:#0f0;font-family:Consolas;margin:0;padding:0;display:flex;justify-content:center;align-items:center;height:100vh;}
    input{background:#1a1a1a;border:1px solid #0f0;color:#0f0;padding:15px;width:280px;text-align:center;}
    </style></head>
    <body>
    <form method="post"><input type="password" name="pass" placeholder="Enter Access Code" autofocus></form>
    </body></html>');
}
$_SESSION['auth'] = true;

// LOGOUT
if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

// DIRECTORY NAVIGATION
$dir = isset($_GET['d']) ? $_GET['d'] : $mainDir;

// Resolve and prevent escaping mainDir
$realDir = realpath($dir);
if (!$realDir || strpos($realDir, realpath($mainDir)) !== 0) {
    $realDir = $mainDir; // fallback to mainDir if trying to escape
}
chdir($realDir);

// DOWNLOAD HANDLER (must be before any HTML output)
if (isset($_GET['download'])) {
    $file = $realDir . '/' . $_GET['download'];
    if (file_exists($file) && is_file($file)) {
        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . basename($file) . '"');
        readfile($file);
        exit;
    }
}

// DELETE HANDLER
if (isset($_GET['del'])) {
    $delpath = $realDir . '/' . $_GET['del'];
    if (is_file($delpath)) unlink($delpath);
    elseif (is_dir($delpath)) rmdir($delpath);
    header("Location: ?d=" . urlencode($realDir));
    exit;
}

// FILES LIST
$files = scandir($realDir);

// UPLOAD HANDLER
if (isset($_FILES['uploadfile'])) {
    $target = $realDir . '/' . basename($_FILES['uploadfile']['name']);
    if (move_uploaded_file($_FILES['uploadfile']['tmp_name'], $target)) {
        $msg = "<p style='color:#4caf50;text-align:center;'>✓ Uploaded successfully</p>";
    } else {
        $msg = "<p style='color:#f66;text-align:center;'>✗ Upload failed</p>";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= $title ?> • <?= basename($realDir) ?></title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<style>
body { background:#0a0a0a; color:#e0e0e0; font-family:'Segoe UI',sans-serif; margin:0; padding:0; }
.header { background:#111; padding:15px 20px; display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #222; }
.path { color:#0f0; word-break:break-all; }
table { width:100%; border-collapse:collapse; }
th, td { padding:10px 12px; text-align:left; border-bottom:1px solid #222; }
tr:hover { background:#1a1a1a; }
.folder { color:#4fc3f7; }
.file { color:#81c784; }
.upload-box { background:#111; padding:20px; border:2px dashed #333; text-align:center; margin:15px; border-radius:8px; }
a { color:#0f0; text-decoration:none; }
a:hover { color:#4caf50; }
.btn { padding:8px 14px; background:#1f1f1f; border:1px solid #333; color:#0f0; border-radius:4px; cursor:pointer; }
</style>
</head>
<body>

<div class="header">
    <h2><i class="fas fa-folder-open"></i> <?= $title ?> <small style="color:#666;">- <?= basename($realDir) ?></small></h2>
    <a href="?logout=1" style="color:#f66;">Logout</a>
</div>

<div style="padding:15px;">
    <div class="path"><strong>Path:</strong> <?= htmlspecialchars($realDir) ?></div>

    <!-- Upload Form -->
    <div class="upload-box">
        <form action="" method="post" enctype="multipart/form-data">
            <input type="file" name="uploadfile" style="color:#aaa;">
            <input type="submit" value="Upload File" class="btn">
        </form>
    </div>

    <?= $msg ?? '' ?>

    <table>
        <tr><th>Name</th><th>Type</th><th>Size</th><th>Action</th></tr>
        <?php foreach($files as $file):
            if($file == "." || $file == "..") continue;
            $fullpath = $realDir . '/' . $file;
            $isDir = is_dir($fullpath);
        ?>
        <tr>
            <td>
                <?php if($isDir): ?>
                    <a href="?d=<?= urlencode($fullpath) ?>" class="folder"><i class="fas fa-folder"></i> <?= htmlspecialchars($file) ?></a>
                <?php else: ?>
                    <a href="?d=<?= urlencode($realDir) ?>&download=<?= urlencode($file) ?>" class="file"><i class="fas fa-file"></i> <?= htmlspecialchars($file) ?></a>
                <?php endif; ?>
            </td>
            <td><?= $isDir ? 'Folder' : pathinfo($file, PATHINFO_EXTENSION) ?></td>
            <td><?= $isDir ? '-' : round(filesize($fullpath)/1024, 2) . ' KB' ?></td>
            <td>
                <?php if(!$isDir): ?>
                    <a href="?del=<?= urlencode($file) ?>&d=<?= urlencode($realDir) ?>" onclick="return confirm('Delete?')" style="color:#f66;">Delete</a>
                <?php endif; ?>
            </td>
        </tr>
        <?php endforeach; ?>
    </table>
</div>

</body>
</html>
