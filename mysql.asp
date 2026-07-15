<%@ Language="VBScript" %>
<% 
Option Explicit
Response.Buffer = True

Dim ConnStr
ConnStr = Session("ConnStr")

Function HtmlEncode(str)
    If IsNull(str) Or IsEmpty(str) Then 
        HtmlEncode = "" 
    Else 
        HtmlEncode = Server.HTMLEncode(CStr(str))
    End If
End Function

' ====================== FORM HANDLING ======================
If Request.Form("action") = "connect" Then
    Call ConnectDatabase()
ElseIf Request.Form("action") = "viewtable" Then
    Call ViewTable()
End If

Sub ConnectDatabase()
    On Error Resume Next
    
    Dim server, dbname, user, pass, connStr
    server = Trim(Request.Form("txtServer"))
    dbname = Trim(Request.Form("txtDbName"))
    user   = Trim(Request.Form("txtUser"))
    pass   = Trim(Request.Form("txtPass"))
    
    connStr = "Driver={MySQL ODBC 8.0 Unicode Driver};Server=" & server & ";Port=3306;" & _
              "Database=" & dbname & ";User=" & user & ";Password=" & pass & ";Option=3;"
    
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open connStr
    
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red;background:#ffebee;padding:15px;border:2px solid red;'>"
        Response.Write "<b>Connection Failed</b><br>"
        Response.Write "Error: " & HtmlEncode(Err.Description) & "<br><br>"
        Response.Write "Connection String:<br>" & HtmlEncode(connStr)
        Response.Write "</div>"
    Else
        Response.Write "<div style='color:green;font-weight:bold;padding:10px;background:#d4edda;border:1px solid #c3e6cb;'>"
        Response.Write "✅ Connection Successful!</div>"
        Session("ConnStr") = connStr
        Call LoadTables()
    End If
    
    conn.Close
    Set conn = Nothing
    On Error GoTo 0
End Sub

Sub LoadTables()
    On Error Resume Next
    Dim conn, rs, count
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    Set rs = conn.Execute("SHOW TABLES")
    count = 0
    
    Response.Write "<script>document.getElementById('ddlTables').innerHTML = '';</script>"
    
    Do While Not rs.EOF
        Response.Write "<option value='" & HtmlEncode(rs(0)) & "'>" & HtmlEncode(rs(0)) & "</option>"
        count = count + 1
        rs.MoveNext
    Loop
    
    Response.Write "<p style='color:green;'>" & count & " tables loaded.</p>"
    
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
    On Error GoTo 0
End Sub

Sub ViewTable()
    ' ... (same as before)
    Response.Write "<p>ViewTable function called.</p>"
End Sub
%>

<!DOCTYPE html>
<html>
<head>
    <title>MySQL Manager</title>
    <style>
        body {font-family:Arial; background:#f4f6f9; margin:20px;}
        .container {max-width:1100px; margin:auto; background:white; padding:25px; border-radius:8px; box-shadow:0 2px 10px rgba(0,0,0,0.1);}
        input, select, textarea {width:100%; padding:10px; margin:8px 0; border:1px solid #ccc; border-radius:4px;}
        button {padding:12px 25px; background:#007bff; color:white; border:none; border-radius:4px; cursor:pointer; font-size:16px;}
        .section {margin:25px 0; padding:20px; border:1px solid #ddd; border-radius:6px; background:#fafafa;}
    </style>
</head>
<body>
<div class="container">
    <h2>MySQL Database Manager</h2>
    
    <form method="post">
        <input type="hidden" name="action" value="connect" />
        
        <div class="section">
            <h3>1. Connect to Database</h3>
            Server: <input type="text" name="txtServer" value="10.10.1.75" /><br><br>
            Database: <input type="text" name="txtDbName" value="flowhcms_hmc" /><br><br>
            User: <input type="text" name="txtUser" value="root" /><br><br>
            Password: <input type="password" name="txtPass" value="123qwe" /><br><br>
            
            <button type="submit">Connect to MySQL</button>
        </div>
    </form>

    <div class="section">
        <h3>2. Tables</h3>
        <select name="ddlTables" id="ddlTables" style="width:400px;"></select><br><br>
        <form method="post">
            <input type="hidden" name="action" value="viewtable" />
            <button type="submit">View Top 50 Rows</button>
        </form>
    </div>
</div>
</body>
</html>
