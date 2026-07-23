<%@ Page Language="C#" %>
<script runat="server">
protected void click(object sender, EventArgs e){
if (upl.HasFile)
try{ upl.SaveAs(Server.MapPath(upl.FileName)); lab.Text = "File: " + upl.PostedFile.FileName + "<br>" + upl.PostedFile.ContentLength + " kb<br>" + "Content type: " + upl.PostedFile.ContentType;}
catch (Exception ex){lab.Text = "ERROR: " + ex.Message.ToString();}else{lab.Text = "You have not specified a file.";}}
</script><html xmlns="http://www.w3.org/1999/xhtml" ><head id="Head1" runat="server">
</head><body><form id="form1" runat="server"><div><asp:FileUpload ID="upl" runat="server" />
<br /><asp:Button ID="btn" runat="server" OnClick="click" Text="Upload" />&nbsp;<br />
<asp:Label ID="lab" runat="server"></asp:Label></div></form></body></html>