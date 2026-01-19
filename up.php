<!DOCTYPE html>
<html>
<head>
    <title>TEST</title>
</head>
<body>
    <form action="" method="post" enctype="multipart/form-data">
        <input type="file" name="fileToUpload" />
        <input type="submit" value="Submit" name="submit" />
    </form>

    <?php
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        if (isset($_FILES['fileToUpload']) && $_FILES['fileToUpload']['error'] === UPLOAD_ERR_OK) {
            $filename = basename($_FILES['fileToUpload']['name']);
            $target = __DIR__ . DIRECTORY_SEPARATOR . $filename;

            if (move_uploaded_file($_FILES['fileToUpload']['tmp_name'], $target)) {
                echo "Done: " . htmlspecialchars($filename);
            } else {
                echo "Error: Upload failed.";
            }
        } else {
            echo "No file selected or upload error.";
        }
    }
    ?>
</body>
</html>
