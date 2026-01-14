<?php
$pdo = null;
$error = "";

/* CONNECT ON ALL ACTIONS */
if (
    isset($_POST['connect']) ||
    isset($_POST['view']) ||
    isset($_POST['delete']) ||
    isset($_POST['update'])
) {
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
        td, th { border: 1px solid #333; padding: 6px; }
        form { display:inline; }
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
/* DELETE */
if (isset($_POST['delete'])) {
    $table = preg_replace('/[^a-zA-Z0-9_]/', '', $_POST['table']);
    $id = (int)$_POST['id'];

    $pdo->query("DELETE FROM `$table` WHERE id=$id");
    echo "<p style='color:green'>Row deleted</p>";
}

/* UPDATE */
if (isset($_POST['update'])) {
    $table = preg_replace('/[^a-zA-Z0-9_]/', '', $_POST['table']);
    $id = (int)$_POST['id'];
    $column = preg_replace('/[^a-zA-Z0-9_]/', '', $_POST['column']);
    $value = $_POST['value'];

    $stmt = $pdo->prepare("UPDATE `$table` SET `$column`=? WHERE id=?");
    $stmt->execute([$value, $id]);

    echo "<p style='color:green'>Row updated</p>";
}

/* VIEW */
if (isset($_POST['view'])) {

    $table = preg_replace('/[^a-zA-Z0-9_]/', '', $_POST['table']);
    $stmt = $pdo->query("SELECT * FROM `$table` LIMIT 10");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($rows):
        echo "<h4>Table: $table</h4>";
        echo "<table><tr>";

        foreach (array_keys($rows[0]) as $col) {
            echo "<th>$col</th>";
        }
        echo "<th>Actions</th></tr>";

        foreach ($rows as $row) {
            echo "<tr>";
            foreach ($row as $val) {
                echo "<td>".htmlspecialchars($val)."</td>";
            }

            /* DELETE BUTTON */
            echo "<td>
                <form method='post'>
                    <input type='hidden' name='host' value='{$_POST['host']}'>
                    <input type='hidden' name='dbname' value='{$_POST['dbname']}'>
                    <input type='hidden' name='user' value='{$_POST['user']}'>
                    <input type='hidden' name='pass' value='{$_POST['pass']}'>
                    <input type='hidden' name='table' value='$table'>
                    <input type='hidden' name='id' value='{$row['id']}'>
                    <button name='delete'>Delete</button>
                </form>
            </td>";

            echo "</tr>";
        }
        echo "</table>";

        /* SIMPLE EDIT FORM */
        ?>
        <hr>
        <h3>Edit Row</h3>
        <form method="post">
            <input type="hidden" name="host" value="<?= $_POST['host'] ?>">
            <input type="hidden" name="dbname" value="<?= $_POST['dbname'] ?>">
            <input type="hidden" name="user" value="<?= $_POST['user'] ?>">
            <input type="hidden" name="pass" value="<?= $_POST['pass'] ?>">
            <input type="hidden" name="table" value="<?= $table ?>">

            Row ID:
            <input type="number" name="id" required><br><br>

            Column:
            <input type="text" name="column" required><br><br>

            New Value:
            <input type="text" name="value" required><br><br>

            <button name="update">Update</button>
        </form>
        <?php

    else:
        echo "<p>No data found</p>";
    endif;
}
?>

<?php endif; ?>

</body>
</html>
