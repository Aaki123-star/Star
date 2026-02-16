<%@ Language=VBScript %>
<%
Dim Conn, ConnStr, ErrMsg

' Tere details
Dim ServerIPorName : ServerIPorName = "ATT-N-ACC"   ' <-- Yahan IP daal (e.g. 192.168.1.50) ya ATT-N-ACC\SQL2012
Dim DbName : DbName = "HRSuiteHC"
Dim User : User = "sa"
Dim Pass : Pass = "HRPass123"

ConnStr = "Provider=SQLNCLI11;Server=tcp:" & ServerIPorName & ",1433;Database=" & DbName & ";Uid=" & User & ";Pwd=" & Pass & ";"

Set Conn = Server.CreateObject("ADODB.Connection")

On Error Resume Next
Conn.Open ConnStr

If Err.Number <> 0 Then
    ErrMsg = "Connection Failed: " & Err.Description & " (Code: " & Err.Number & ")"
Else
    ErrMsg = "<font color='lime'><b>Connection SUCCESS! Database: " & DbName & " connected.</b></font>"
End If

Conn.Close
Set Conn = Nothing
On Error Goto 0
%>

<html>
<head><title>Test Connection - SQL 2012</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; padding:30px;">
<h2>Connection Test (sa / HRPass123)</h2>
<p>Server: <%=ServerIPorName%> | DB: <%=DbName%></p>

<div style="padding:15px; border:2px solid <% If InStr(ErrMsg, "SUCCESS") > 0 Then Response.Write "lime" Else Response.Write "red" End If %>; background:#111;">
    <%=ErrMsg%>
</div>

<p style="color:yellow; margin-top:30px;">
Tips:<br>
- Server mein IP daal (ping ATT-N-ACC se IP le).<br>
- Instance name add kar agar hai (e.g. ATT-N-ACC\SQL2012).<br>
- Port 1433 block na ho (firewall check).<br>
- SQL Browser service running ho (Services.msc mein).
</p>
</body>
</html>
