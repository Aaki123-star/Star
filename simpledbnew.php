<?php
$pdo = null;
$msg = "";

if (
    isset($_POST['connect']) ||
    isset($_POST['view']) ||
    isset($_POST['insert']) ||
    isset($_POST['update']) ||
    isset($_POST['delete']) ||
    isset($_POST['drop_table'])
) {
    try {
        $pdo = new PDO(
            "mysql:host=".$_POST['host'].";dbname=".$_POST['dbname'].";charset=utf8",
            $_POST['user'],
            $_POST['pass'],
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
    } catch (PDOException $e) {
        $msg = "Database connection failed";
    }
}

function clean($v) {
    return preg_replace('/[^a-zA-Z0-9_]/', '', $v);
}

/* DROP TABLE */
if (isset($_POST['drop_table'])) {
    $table = clean($_POST['table']);
    $pdo->query("DROP TABLE `$table`");
    $msg = "Table <b>$table</b> deleted";
}

/* DELETE ROW */
if (isset($_POST['delete'])) {
    $table = clean($_POST['table']);
    $id = (int)$_POST['id'];
    $pdo->query("DELETE FROM `$table` WHERE id=$id");
    $msg = "Row deleted";
}

/* INSERT */
if (isset($_POST['insert'])) {
    $table = clean($_POST['table']);
    $column = clean($_POST['column']);
    $stmt = $pdo->prepare("INSERT INTO `$table` (`$column`) VALUES (?)");
    $stmt->execute([$_POST['value']]);
    $msg = "Row inserted";
}

/* UPDATE */
if (isset($_POST['update'])) {
    $table = clean($_POST['table']);
    $column = clean($_POST['column']);
    $stmt = $pdo->prepare("UPDATE `$table` SET `$column`=? WHERE id=?");
    $stmt->execute([$_POST['value'], (int)$_POST['id']]);
    $msg = "Row updated";
}
?>
<!DOCTYPE html>
<html>
<head>
<title>PHP DB Manager</title>
<style>
body{background:#f4f6f9;font-family:Arial,sans-serif;margin:0;padding:0;}
.container{width:1000px;margin:30px auto;background:#fff;padding:20px;border-radius:8px;box-shadow:0 0 10px rgba(0,0,0,0.1);}
h2,h3{color:#333;}
input,select,button{padding:8px;margin:4px 0;border-radius:4px;border:1px solid #ccc;}
button{background:#007bff;color:white;cursor:pointer;}
button:hover{background:#0056b3;}
button.danger{background:#dc3545;}
button.danger:hover{background:#a71d2a;}
table{width:100%;border-collapse:collapse;margin-top:10px;}
th{background:#007bff;color:white;}
td,th{padding:8px;border:1px solid #ddd;text-align:left;}
.msg{padding:10px;background:#e9ffe9;border:1px solid #b2ffb2;margin:10px 0;}
.flex{display:flex;gap:20px;flex-wrap:wrap;}
.card{background:#fafafa;padding:15px;border-radius:6px;border:1px solid #ddd;width:300px;}
</style>
</head>
<body>

<div class="container">

<h2>PHP Database Manager (Lab)</h2>

<?php if($msg): ?>
<div class="msg"><?= $msg ?></div>
<?php endif; ?>

<div class="card">
<form method="post">
<h3>Connect Database</h3>
<input name="host" placeholder="Host" value="<?= $_POST['host'] ?? 'localhost' ?>"><br>
<input name="dbname" placeholder="Database" value="<?= $_POST['dbname'] ?? '' ?>"><br>
<input name="user" placeholder="Username" value="<?= $_POST['user'] ?? '' ?>"><br>
<input type="password" name="pass" placeholder="Password"><br>
<button name="connect">Connect</button>
</form>
</div>

<?php if ($pdo): ?>

<hr>

<h3>Tables</h3>
<form method="post">
<?php foreach(['host','dbname','user','pass'] as $f): ?>
<input type="hidden" name="<?= $f ?>" value="<?= $_POST[$f] ?>">
<?php endforeach; ?>
<select name="table" style="padding:8px;width:300px;">
<?php
$tables = $pdo->query("SHOW TABLES");
while ($t = $tables->fetch(PDO::FETCH_NUM)) {
    echo "<option value='{$t[0]}'>{$t[0]}</option>";
}
?>
</select>
<button name="view">View Table</button>
</form>

<h3 style="color:red">Delete Table</h3>
<form method="post" onsubmit="return confirm('Delete table permanently?');">
<?php foreach(['host','dbname','user','pass'] as $f): ?>
<input type="hidden" name="<?= $f ?>" value="<?= $_POST[$f] ?>">
<?php endforeach; ?>
<select name="table" style="padding:8px;width:300px;">
<?php
$tables = $pdo->query("SHOW TABLES");
while ($t = $tables->fetch(PDO::FETCH_NUM)) {
    echo "<option value='{$t[0]}'>{$t[0]}</option>";
}
?>
</select>
<button class="danger" name="drop_table">DROP TABLE</button>
</form>

<?php
if (isset($_POST['view'])):
$table = clean($_POST['table']);
$rows = $pdo->query("SELECT * FROM `$table` LIMIT 10")->fetchAll(PDO::FETCH_ASSOC);
if ($rows):
    echo "<h3>Data: $table</h3><table><tr>";
    foreach(array_keys($rows[0]) as $c) echo "<th>$c</th>";
    echo "<th>Action</th></tr>";
    foreach($rows as $r):
        echo "<tr>";
        foreach($r as $v) echo "<td>".htmlspecialchars($v)."</td>";
        echo "<td>
        <form method='post'>
        ".implode('',array_map(function($f){return "<input type='hidden' name='$f' value='{$_POST[$f]}'>";},['host','dbname','user','pass']))."
        <input type='hidden' name='table' value='$table'>
        <input type='hidden' name='id' value='{$r['id']}'>
        <button class='danger' name='delete'>Delete</button>
        </form>
        </td></tr>";
    endforeach;
    echo "</table>";
endif;
endif;
?>

<?php if (isset($_POST['view'])): ?>
<hr>
<div class="flex">
<div class="card">
<h3>Insert Row</h3>
<form method="post">
<?php foreach(['host','dbname','user','pass'] as $f): ?>
<input type="hidden" name="<?= $f ?>" value="<?= $_POST[$f] ?>">
<?php endforeach; ?>
<input type="hidden" name="table" value="<?= clean($_POST['table']) ?>">
<input name="column" placeholder="Column Name">
<input name="value" placeholder="Value">
<button name="insert">Insert</button>
</form>
</div>

<div class="card">
<h3>Update Row</h3>
<form method="post">
<?php foreach(['host','dbname','user','pass'] as $f): ?>
<input type="hidden" name="<?= $f ?>" value="<?= $_POST[$f] ?>">
<?php endforeach; ?>
<input type="hidden" name="table" value="<?= clean($_POST['table']) ?>">
<input name="id" placeholder="Row ID">
<input name="column" placeholder="Column Name">
<input name="value" placeholder="New Value">
<button name="update">Update</button>
</form>
</div>
</div>
<?php endif; ?>

<?php endif; ?>

</div>
</body>
</html>
