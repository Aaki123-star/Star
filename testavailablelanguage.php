<?php
$test = $_GET['test'] ?? 'python3';

echo "<h3>Testing: $test</h3><pre>";
echo htmlspecialchars(`$test --version 2>&1`);
echo "\n\nReturn: " . `which $test 2>&1`;
echo "</pre>";
?>
