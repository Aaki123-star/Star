<?php
$pdo = null;
$error = "";

/* CONNECT ON BOTH CONNECT & VIEW */
if (isset($_POST['connect']) || isset($_POST['view'])) {
    try {
        $pdo = new PDO(
            "mysql:host=".$_POST['host'].";dbname=".$_POST['dbname'].";charset=utf8",
            $_POST['user'],
            $_POST['pass'],
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
    } catch (PDOException $e) {
        $error = "Database connection failed";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>PHP DB Manager (Lab)</title>
    <style>
        table { border-collapse: collapse; }
        td, th { border: 1px solid #333; padding: 5px; }
    </style>
</head>
<body>

<h2>Database Connection</h2>

<form method="post">
    Host:
    <input type="text" name="host" value="<?= $_POST['host'] ?? 'localhost' ?>"><br><br>

    DB Name:
    <input type="text" name="dbname" value="<?= $_POST['dbname'] ?? '' ?>"><br><br>

    Username:
    <input type="text" name="user" value="<?= $_POST['user'] ?? '' ?>"><br><br>

    Password:
    <input type="password" name="pass" value="<?= $_POST['pass'] ?? '' ?>"><br><br>

    <button type="submit" name="connect">Connect</button>
</form>

<?php if ($error): ?>
    <p style="color:red"><?= $error ?></p>
<?php endif; ?>

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

    Table Name:
    <input type="text" name="table" required>
    <button name="view">View</button>
</form>

<?php
if (isset($_POST['view'])) {

    // sanitize table name (lab-safe)
    $table = preg_replace('/[^a-zA-Z0-9_]/', '', $_POST['table']);

    $stmt = $pdo->query("SELECT * FROM `$table` LIMIT 10");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($rows):
        echo "<h4>Showing data from table: $table</h4>";
        echo "<table><tr>";

        // table headers
        foreach (array_keys($rows[0]) as $col) {
            echo "<th>$col</th>";
        }
        echo "</tr>";

        // table data
        foreach ($rows as $row) {
            echo "<tr>";
            foreach ($row as $val) {
                echo "<td>".htmlspecialchars($val)."</td>";
            }
            echo "</tr>";
        }

        echo "</table>";
    else:
        echo "<p>No data found</p>";
    endif;
}
?>

<?php endif; ?>

</body>
</html>
