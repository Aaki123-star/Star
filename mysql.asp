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

' ====================== CONNECT ======================
If Request.Form("btnConnect") <> "" Then Call ConnectDatabase()
If Request.Form("btnViewTable") <> "" Then Call ViewTable()
If Request.Form("btnRun") <> "" Then Call RunQuery()

Sub ConnectDatabase()
    On Error Resume Next
    
    Dim server, dbname, user, pass, connStr
    server = Trim(Request.Form("txtServer"))
    dbname = Trim(Request.Form("txtDbName"))
    user   = Trim(Request.Form("txtUser"))
    pass   = Trim(Request.Form("txtPass"))
    
    If server="" Or dbname="" Or user="" Or pass="" Then
        Response.Write "<p style='color:red;'>Sab fields bharo!</p>"
        Exit Sub
    End If
    
    ' MySQL ODBC Connection String
    connStr = "Driver={MySQL ODBC 8.0 Unicode Driver};" & _
              "Server=" & server & ";Port=3306;Database=" & dbname & ";" & _
              "User=" & user & ";Password=" & pass & ";Option=3;"
    
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open connStr
    
    If Err.Number <> 0 Then
        Response.Write "<h3 style='color:red;'>Connection Failed</h3>"
        Response.Write "<pre style='background:#ffebee;padding:15px;border:2px solid red;'>"
        Response.Write "Error " & Err.Number & ": " & HtmlEncode(Err.Description) & "<br><br>"
        Response.Write "Connection String:<br>" & HtmlEncode(connStr)
        Response.Write "</pre>"
    Else
        Response.Write "<p style='color:green;font-weight:bold;'>✅ Connection Successful!</p>"
        Session("ConnStr") = connStr
        Call LoadTables()
    End If
    
    If Not conn Is Nothing Then
        If conn.State = 1 Then conn.Close
        Set conn = Nothing
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
    Dim count : count = 0
    
    While Not rs.EOF
        Response.Write "<option value='" & HtmlEncode(rs(0)) & "'>" & HtmlEncode(rs(0)) & "</option>"
        count = count + 1
        rs.MoveNext
    Wend
    
    Response.Write "<p style='color:green;'>" & count & " tables loaded.</p>"
    
    rs.Close : conn.Close
    Set rs = Nothing : Set conn = Nothing
    On Error GoTo 0
End Sub

Sub ViewTable()
    On Error Resume Next
    Dim table : table = Trim(Request.Form("ddlTables"))
    If table = "" Then Response.Write "<p style='color:red;'>Table select karo</p>" : Exit Sub
    
    Dim conn, rs, html, i
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    Set rs = conn.Execute("SELECT * FROM `" & Replace(table,"`","``") & "` LIMIT 50")
    
    If rs.EOF Then
        Response.Write "<p style='color:orange;'>No data in table.</p>"
    Else
        html = "<h3>Table: " & HtmlEncode(table) & "</h3><table border='1' cellpadding='6' style='border-collapse:collapse;width:100%;'>"
        html = html & "<tr style='background:#007bff;color:white;'>"
        For i = 0 To rs.Fields.Count-1
            html = html & "<th>" & HtmlEncode(rs.Fields(i).Name) & "</th>"
        Next
        html = html & "</tr>"
        
        While Not rs.EOF
            html = html & "<tr>"
            For i = 0 To rs.Fields.Count-1
                html = html & "<td>" & HtmlEncode(rs.Fields(i).Value) & "</td>"
            Next
            html = html & "</tr>"
            rs.MoveNext
        Wend
        html = html & "</table>"
        Response.Write html
    End If
    
    rs.Close : conn.Close
    Set rs=Nothing : Set conn=Nothing
    On Error GoTo 0
End Sub

Sub RunQuery()
    On Error Resume Next
    Dim query : query = Trim(Request.Form("txtQuery"))
    If query = "" Then Response.Write "<p style='color:red;'>Query likho!</p>" : Exit Sub
    
    Dim conn, rs, affected
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    If UCase(Left(query,6)) = "SELECT" Then
        Set rs = conn.Execute(query)
        If Err.Number <> 0 Then
            Response.Write "<pre style='color:red;'>Error: " & HtmlEncode(Err.Description) & "</pre>"
        Else
            ' Table code (same as ViewTable) - abbreviated for brevity
            Dim html, i
            html = "<table border='1' cellpadding='6' style='border-collapse:collapse;width:100%;'>"
            html = html & "<tr style='background:#28a745;color:white;'>"
            For i=0 To rs.Fields.Count-1 : html=html&"<th>"&HtmlEncode(rs.Fields(i).Name)&"</th>" : Next
            html = html & "</tr>"
            While Not rs.EOF
                html = html & "<tr>"
                For i=0 To rs.Fields.Count-1 : html=html&"<td>"&HtmlEncode(rs.Fields(i).Value)&"</td>" : Next
                html = html & "</tr>"
                rs.MoveNext
            Wend
            html = html & "</table>"
            Response.Write html
        End If
        If Not rs Is Nothing Then rs.Close
    Else
        conn.Execute query, affected
        If Err.Number <> 0 Then
            Response.Write "<pre style='color:red;'>Error: " & HtmlEncode(Err.Description) & "</pre>"
        Else
            Response.Write "<p style='color:green;'>Success! Rows affected: " & affected & "</p>"
        End If
    End If
    
    conn.Close
    Set conn = Nothing
    On Error GoTo 0
End Sub
%>

<!DOCTYPE html>
<html>
<head>
    <title>MySQL Manager</title>
    <style>
        body{font-family:Arial;background:#f4f6f9;margin:20px;}
        .container{max-width:1100px;margin:auto;background:white;padding:25px;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.1);}
        input,textarea,select{width:100%;padding:10px;margin:5px 0;border:1px solid #ccc;border-radius:4px;}
        button{padding:12px 20px;background:#007bff;color:white;border:none;border-radius:4px;cursor:pointer;}
        .section{margin:20px 0;padding:15px;border:1px solid #ddd;border-radius:6px;background:#fafafa;}
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
            <button type="submit" name="btnConnect">Connect</button>
        </div>
        
        <div class="section">
            <h3>2. Tables</h3>
            <select name="ddlTables" id="ddlTables" style="width:350px;"></select><br><br>
            <button type="submit" name="btnViewTable">View Top 50</button>
        </div>
        
        <div class="section">
            <h3>3. Run Query</h3>
            <textarea name="txtQuery" rows="6" placeholder="SELECT * FROM tablename LIMIT 10"></textarea><br>
            <button type="submit" name="btnRun">Execute</button>
        </div>
    </form>
</div>
</body>
</html>
