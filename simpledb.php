<?php
$pdo = null;
$error = "";

if (isset($_POST['connect'])) {
    try {
        $pdo = new PDO(
            "mysql:host=".$_POST['host'].";dbname=".$_POST['dbname'].";charset=utf8",
            $_POST['user'],
            $_POST['pass'],
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
    } catch (PDOException $e) {
        $error = "Connection failed";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>PHP DB Manager (Lab)</title>
</head>
<body>

<h2>Database Connection</h2>

<form method="post">
    Host: <input type="text" name="host" value="localhost"><br><br>
    DB Name: <input type="text" name="dbname"><br><br>
    Username: <input type="text" name="user"><br><br>
    Password: <input type="password" name="pass"><br><br>
    <button type="submit" name="connect">Connect</button>
</form>

<?php if ($error) echo "<p style='color:red'>$error</p>"; ?>

<?php if ($pdo): ?>

<hr>
<h3>Tables</h3>

<?php
$tables = $pdo->query("SHOW TABLES");
while ($t = $tables->fetch(PDO::FETCH_NUM)) {
    echo $t[0] . "<br>";
}
?>

<hr>
<h3>View Table Data</h3>

<form method="post">
    <input type="hidden" name="host" value="<?= $_POST['host'] ?>">
    <input type="hidden" name="dbname" value="<?= $_POST['dbname'] ?>">
    <input type="hidden" name="user" value="<?= $_POST['user'] ?>">
    <input type="hidden" name="pass" value="<?= $_POST['pass'] ?>">
    Table name: <input type="text" name="table">
    <button name="view">View</button>
</form>

<?php
if (isset($_POST['view'])) {
    $stmt = $pdo->query("SELECT * FROM ".$_POST['table']." LIMIT 10");
    foreach ($stmt as $row) {
        print_r($row);
        echo "<br>";
    }
}
?>

<?php endif; ?>

</body>
</html>
