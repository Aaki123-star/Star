<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

session_start();

$panel_password = "wiredmouse";   

// ====================== PANEL PASSWORD ======================
if (!isset($_SESSION['panel_auth'])) {
    if (isset($_POST['ppass']) && $_POST['ppass'] === $panel_password) {
        $_SESSION['panel_auth'] = true;
        header("Location: " . $_SERVER['PHP_SELF']);
        exit;
    }
    // Login Page
    die('
    <!DOCTYPE html>
    <html><head><title>Access</title>
    <style>body{background:#f8f9fa;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;font-family:Arial;}
    .box{background:white;padding:40px;border-radius:10px;box-shadow:0 5px 20px rgba(0,0,0,0.1);width:360px;text-align:center;}
    input{width:100%;padding:15px;margin:10px 0;border:1px solid #888;border-radius:5px;}
    button{width:100%;padding:14px;background:#0066ff;color:white;border:none;border-radius:5px;}</style>
    </head><body>
    <div class="box">
        <h2>Panel Access</h2>
        <form method="post">
            <input type="password" name="ppass" placeholder="Enter Panel Password" autofocus>
            <button type="submit">Login</button>
        </form>
    </div>
    </body></html>');
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
            $error = "MySQL Connection Failed: " . mysqli_connect_error();
        }
    }
    ?>
    <!DOCTYPE html>
    <html><head><title>DB Login</title>
    <style>
        body{background:#0a0a0a;color:#ddd;font-family:Consolas;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}
        .box{background:#111;padding:40px;border-radius:10px;width:420px;border:1px solid #0f0;}
        input{width:100%;padding:12px;margin:8px 0;background:#222;color:#0f0;border:1px solid #0f0;border-radius:5px;}
        button{width:100%;padding:14px;background:#0066ff;color:white;border:none;border-radius:5px;cursor:pointer;}
    </style>
    </head><body>
    <div class="box">
        <h2>MySQL Database Login</h2>
        <?php if(isset($error)) echo "<p style='color:red'>$error</p>"; ?>
        <form method="post">
            <input type="text" name="host" value="localhost" placeholder="Host"><br>
            <input type="text" name="user" placeholder="Username" required><br>
            <input type="password" name="dbpass" placeholder="Password"><br>
            <button type="submit">Connect</button>
        </form>
        <br><a href="?logout=1" style="color:red;">← Back to Panel Login</a>
    </div>
    </body></html>
    <?php
    exit;
}

// ====================== MAIN PANEL ======================
$conn = mysqli_connect($_SESSION['host'], $_SESSION['user'], $_SESSION['pass']);
if (!$conn) {
    echo "<h2 style='color:red'>Connection Lost. Please Login Again.</h2>";
    session_destroy();
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
    <a href="?logout=1" style="color:red;">Logout</a>
</div>

<?php
// Show Databases
if(empty($db)){
    echo "<h3>Databases List</h3>";
    $res = mysqli_query($conn, "SHOW DATABASES");
    echo "<table><tr><th>Database</th><th>Action</th></tr>";
    while($row = mysqli_fetch_row($res)){
        if(in_array(strtolower($row[0]), ['information_schema','performance_schema','mysql','sys'])) continue;
        echo "<tr><td><a href='?db=".$row[0]."'>".$row[0]."</a></td><td><a href='?db=".$row[0]."'>Open →</a></td></tr>";
    }
    echo "</table>";
}

// Show Tables
elseif(empty($table)){
    mysqli_select_db($conn, $db);
    echo "<h3>Database: <b>$db</b> <a href='?' style='color:orange;'>← Back</a></h3>";
    $res = mysqli_query($conn, "SHOW TABLES");
    echo "<table><tr><th>Table Name</th><th>Rows</th><th>Action</th></tr>";
    while($row = mysqli_fetch_row($res)){
        $count_res = mysqli_query($conn, "SELECT COUNT(*) FROM `".$row[0]."`");
        $count = $count_res ? mysqli_fetch_row($count_res)[0] : 0;
        echo "<tr>
            <td><a href='?db=$db&table=".$row[0]."'>".$row[0]."</a></td>
            <td>$count</td>
            <td><a href='?db=$db&table=".$row[0]."&export=1'>Download SQL</a></td>
        </tr>";
    }
    echo "</table>";
}

// Show Table Records + Export
else {
    mysqli_select_db($conn, $db);
    echo "<h3>DB: $db | Table: $table <a href='?db=$db'>← Back</a></h3>";

    if(isset($_GET['export'])){
        header('Content-Type: text/sql');
        header('Content-Disposition: attachment; filename="'.$table.'.sql"');
        $result = mysqli_query($conn, "SELECT * FROM `$table`");
        while($row = mysqli_fetch_assoc($result)){
            $values = array_map(fn($v) => $v === null ? 'NULL' : "'".mysqli_real_escape_string($conn, $v)."'", $row);
            echo "INSERT INTO `$table` VALUES (".implode(",", $values).");\n";
        }
        exit;
    }

    $result = mysqli_query($conn, "SELECT * FROM `$table` LIMIT 200");
    if($result){
        echo "<table><tr>";
        $fields = mysqli_fetch_fields($result);
        foreach($fields as $f) echo "<th>".$f->name."</th>";
        echo "</tr>";

        while($row = mysqli_fetch_row($result)){
            echo "<tr>";
            foreach($row as $val) echo "<td>".htmlspecialchars(substr($val??'',0,100))."</td>";
            echo "</tr>";
        }
        echo "</table>";
    } else {
        echo "Error: " . mysqli_error($conn);
    }
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
