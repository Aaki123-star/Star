<%@ Language="VBScript" %>
<% 
Option Explicit
Response.Buffer = True

Dim ConnStr
ConnStr = Session("ConnStr")

Function HtmlEncode(str)
    If IsNull(str) Or IsEmpty(str) Then HtmlEncode = "" Else HtmlEncode = Server.HTMLEncode(CStr(str))
End Function

If Request.Form("btnConnect") <> "" Then Call ConnectDatabase()
If Request.Form("btnViewTable") <> "" Then Call ViewTable()
If Request.Form("btnRun") <> "" Then Call RunQuery()

Sub ConnectDatabase()
    On Error Resume Next
    Dim server, db, user, pass, connStr
    
    server = Trim(Request.Form("txtServer"))
    db     = Trim(Request.Form("txtDbName"))
    user   = Trim(Request.Form("txtUser"))
    pass   = Trim(Request.Form("txtPass"))
    
    connStr = "Driver={MySQL ODBC 8.0 Unicode Driver};Server=" & server & ";Port=3306;" & _
              "Database=" & db & ";User=" & user & ";Password=" & pass & ";Option=3;"
    
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open connStr
    
    If Err.Number <> 0 Then
        Response.Write "<pre style='color:red;background:#ffebee;padding:15px;'>"
        Response.Write "Error " & Err.Number & ": " & HtmlEncode(Err.Description) & "<br><br>"
        Response.Write "Connection String:<br>" & HtmlEncode(connStr)
        Response.Write "</pre>"
    Else
        Response.Write "<p style='color:green;font-weight:bold;'>✅ Connection Successful!</p>"
        Session("ConnStr") = connStr
        Call LoadTables()
    End If
    On Error GoTo 0
End Sub

Sub LoadTables()
    On Error Resume Next
    Dim conn, rs
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    Set rs = conn.Execute("SHOW TABLES")
    
    Response.Write "<script>document.getElementById('ddlTables').innerHTML='';</script>"
    Dim c : c = 0
    While Not rs.EOF
        Response.Write "<option value='" & HtmlEncode(rs(0)) & "'>" & HtmlEncode(rs(0)) & "</option>"
        c = c + 1
        rs.MoveNext
    Wend
    Response.Write "<p>" & c & " tables loaded.</p>"
    
    rs.Close : conn.Close
    On Error GoTo 0
End Sub

Sub ViewTable()
    On Error Resume Next
    Dim tbl : tbl = Trim(Request.Form("ddlTables"))
    If tbl = "" Then Response.Write "<p style='color:red;'>Table select karo</p>" : Exit Sub
    
    Dim conn, rs, html, i
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    Set rs = conn.Execute("SELECT * FROM `" & Replace(tbl,"`","``") & "` LIMIT 50")
    
    html = "<h3>Table: " & HtmlEncode(tbl) & "</h3><table border='1' cellpadding='6' style='border-collapse:collapse;width:100%'>"
    html = html & "<tr style='background:#007bff;color:white;'>"
    For i = 0 To rs.Fields.Count - 1
        html = html & "<th>" & HtmlEncode(rs.Fields(i).Name) & "</th>"
    Next
    html = html & "</tr>"
    
    While Not rs.EOF
        html = html & "<tr>"
        For i = 0 To rs.Fields.Count - 1
            html = html & "<td>" & HtmlEncode(rs.Fields(i).Value) & "</td>"
        Next
        html = html & "</tr>"
        rs.MoveNext
    Wend
    html = html & "</table>"
    Response.Write html
    
    rs.Close : conn.Close
    On Error GoTo 0
End Sub
%>

<!DOCTYPE html>
<html>
<head>
    <title>MySQL Manager</title>
    <style>
        body {font-family:Arial; background:#f4f6f9; margin:20px;}
        .container {max-width:1100px; margin:auto; background:white; padding:25px; border-radius:8px;}
        input, textarea, select {width:100%; padding:10px; margin:5px 0; border:1px solid #ccc;}
        button {padding:12px 20px; background:#007bff; color:white; border:none;}
        .section {margin:20px 0; padding:15px; border:1px solid #ddd; background:#fafafa;}
    </style>
</head>
<body>
<div class="container">
    <h2>MySQL Database Manager</h2>
    <form method="post">
        <div class="section">
            <h3>1. Connection</h3>
            Server: <input type="text" name="txtServer" value="10.10.1.75"><br><br>
            Database: <input type="text" name="txtDbName" value="flowhcms_hmc"><br><br>
            User: <input type="text" name="txtUser" value="root"><br><br>
            Password: <input type="password" name="txtPass" value="123qwe"><br><br>
            <button type="submit" name="btnConnect">Connect to MySQL</button>
        </div>
        
        <div class="section">
            <h3>2. Tables</h3>
            <select name="ddlTables" id="ddlTables"></select><br><br>
            <button type="submit" name="btnViewTable">View Top 50 Rows</button>
        </div>
    </form>
</div>
</body>
</html>
