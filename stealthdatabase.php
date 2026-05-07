<?php
error_reporting(0);
session_start();

$panel_password = "wiredmouseis";   // ← Yeh change kar do (Panel ka password)

// ====================== FIRST LAYER PASSWORD ======================
if (!isset($_SESSION['panel_auth'])) {
    if (isset($_POST['ppass']) && $_POST['ppass'] === $panel_password) {
        $_SESSION['panel_auth'] = true;
        header("Location: " . $_SERVER['PHP_SELF']);
        exit;
    }
    // Stealth First Login
    die('
    <!DOCTYPE html>
    <html>
    <head><title>Index</title>
    <style>
        body{background:#f8f9fa;color:#222;font-family:Arial,sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}
        .box{background:white;padding:45px;border-radius:10px;box-shadow:0 5px 25px rgba(0,0,0,0.15);text-align:center;width:360px;}
        input{width:100%;padding:15px;font-size:17px;border:1px solid #888;border-radius:5px;}
        button{width:100%;padding:14px;background:#0066ff;color:white;border:none;border-radius:5px;font-size:16px;cursor:pointer;margin-top:15px;}
    </style>
    </head>
    <body>
        <div class="box">
            <h2>Access Verification</h2>
            <form method="post">
                <input type="password" name="ppass" placeholder="Enter Panel Password" autofocus><br><br>
                <button type="submit">Continue</button>
            </form>
        </div>
    </body>
    </html>');
}

// ====================== DATABASE LOGIN ======================
if (!isset($_SESSION['db_connected'])) {
    if (isset($_POST['host'], $_POST['user'], $_POST['dbpass'])) {
        $conn = @mysqli_connect($_POST['host'], $_POST['user'], $_POST['dbpass']);
        if ($conn) {
            $_SESSION['db_connected'] = true;
            $_SESSION['host'] = $_POST['host'];
            $_SESSION['user'] = $_POST['user'];
            $_SESSION['pass'] = $_POST['dbpass'];
            header("Location: " . $_SERVER['PHP_SELF']);
            exit;
        } else {
            $error = "MySQL Login Failed!";
        }
    }
    ?>
    <!DOCTYPE html>
    <html>
    <head><title>DB Login</title>
    <style>
        body{background:#0a0a0a;color:#ddd;font-family:Consolas;margin:0;padding:0;display:flex;justify-content:center;align-items:center;height:100vh;}
        .box{background:#111;padding:40px;border-radius:10px;width:400px;border:1px solid #0f0;}
        input{width:100%;padding:12px;margin:8px 0;background:#222;color:#0f0;border:1px solid #0f0;border-radius:5px;}
        button{width:100%;padding:14px;background:#0066ff;color:white;border:none;border-radius:5px;cursor:pointer;}
    </style>
    </head>
    <body>
        <div class="box">
            <h2>Database Login</h2>
            <?php if(isset($error)) echo "<p style='color:red'>$error</p>"; ?>
            <form method="post">
                <input type="text" name="host" value="localhost" placeholder="Host"><br>
                <input type="text" name="user" placeholder="Username"><br>
                <input type="password" name="dbpass" placeholder="Database Password"><br>
                <button type="submit">Connect to MySQL</button>
            </form>
            <br><a href="?logout=1" style="color:red;">← Back</a>
        </div>
    </body>
    </html>
    <?php
    exit;
}

// ====================== MAIN DATABASE PANEL ======================
$conn = mysqli_connect($_SESSION['host'], $_SESSION['user'], $_SESSION['pass']);
if (!$conn) {
    session_destroy();
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

$db = $_GET['db'] ?? '';
$table = $_GET['table'] ?? '';
?>

<!DOCTYPE html>
<html>
<head>
    <title>DB Admin</title>
    <style>
        body {background:#0a0a0a;color:#ddd;font-family:Consolas;margin:0;padding:15px;}
        .header {background:#111;padding:12px;margin:-15px -15px 15px -15px;display:flex;justify-content:space-between;}
        table {width:100%;border-collapse:collapse;}
        th, td {padding:8px;border:1px solid #333;}
        th {background:#1a1a1a;}
        a {color:#0f0;}
    </style>
</head>
<body>

<div class="header">
    <h3>Database Admin Panel</h3>
    <a href="?logout=1" style="color:red;">Full Logout</a>
</div>

<?php

// Show Databases
if(empty($db)){
    echo "<h3>Available Databases</h3>";
    $res = mysqli_query($conn, "SHOW DATABASES");
    echo "<table><tr><th>Database</th><th>Action</th></tr>";
    while($row = mysqli_fetch_row($res)){
        if(in_array($row[0], ['information_schema','performance_schema','mysql','sys'])) continue;
        echo "<tr><td><a href='?db=".$row[0]."'>📁 ".$row[0]."</a></td><td><a href='?db=".$row[0]."'>Open</a></td></tr>";
    }
    echo "</table>";
}

// Show Tables
elseif(empty($table)){
    mysqli_select_db($conn, $db);
    echo "<h3>Database: <b>$db</b></h3><a href='?'>← Back to Databases</a><br><br>";
    $res = mysqli_query($conn, "SHOW TABLES");
    echo "<table><tr><th>Table Name</th><th>Rows</th><th>Action</th></tr>";
    while($row = mysqli_fetch_row($res)){
        $count = mysqli_fetch_row(mysqli_query($conn,"SELECT COUNT(*) FROM `".$row[0]."`"))[0] ?? 0;
        echo "<tr>
            <td><a href='?db=$db&table=".$row[0]."'>".$row[0]."</a></td>
            <td>$count</td>
            <td><a href='?db=$db&table=".$row[0]."&export=1'>Download SQL</a></td>
        </tr>";
    }
    echo "</table>";
}

// Show Table Data + Export
else {
    mysqli_select_db($conn, $db);
    echo "<h3>DB: $db | Table: $table</h3>";
    echo "<a href='?db=$db'>← Back to Tables</a><br><br>";

    if(isset($_GET['export'])){
        header('Content-Type: application/sql');
        header('Content-Disposition: attachment; filename="'.$table.'.sql"');
        // Code for export...
        $result = mysqli_query($conn, "SELECT * FROM `$table`");
        while($row = mysqli_fetch_assoc($result)){
            $values = array_map(function($v) use($conn){ 
                return $v === null ? 'NULL' : "'".mysqli_real_escape_string($conn, $v)."'"; 
            }, $row);
            echo "INSERT INTO `$table` VALUES (".implode(",", $values).");\n";
        }
        exit;
    }

    $result = mysqli_query($conn, "SELECT * FROM `$table` LIMIT 300");
    echo "<table><tr>";
    $fields = mysqli_fetch_fields($result);
    foreach($fields as $f) echo "<th>".$f->name."</th>";
    echo "</tr>";

    while($row = mysqli_fetch_row($result)){
        echo "<tr>";
        foreach($row as $val) echo "<td>".htmlspecialchars(substr($val??'',0,80))."</td>";
        echo "</tr>";
    }
    echo "</table>";
}
?>

</body>
</html>
<?php
if(isset($_GET['logout'])){
    session_destroy();
    header("Location: " . $_SERVER['PHP_SELF']);
}
?>
