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
If Request.Form("btnConnect") <> "" Then
    Call ConnectDatabase()
ElseIf Request.Form("btnViewTable") <> "" Then
    Call ViewTable()
ElseIf Request.Form("btnRun") <> "" Then
    Call RunQuery()
End If

Sub ConnectDatabase()
    On Error Resume Next
    
    Dim server, dbname, user, pass, connStr
    server = Trim(Request.Form("txtServer"))
    dbname = Trim(Request.Form("txtDbName"))
    user   = Trim(Request.Form("txtUser"))
    pass   = Trim(Request.Form("txtPass"))
    
    If server = "" Or dbname = "" Or user = "" Or pass = "" Then
        Response.Write "<p style='color:red; font-weight:bold;'>Sab fields bharna zaroori hai!</p>"
        Exit Sub
    End If
    
    ' MySQL Connection String (MySQL ODBC Driver)
    connStr = "Driver={MySQL ODBC 8.0 Unicode Driver};" & _
              "Server=" & server & ";" & _
              "Port=3306;" & _
              "Database=" & dbname & ";" & _
              "User=" & user & ";" & _
              "Password=" & pass & ";" & _
              "Option=3;"
    
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open connStr
    
    If Err.Number <> 0 Then
        Response.Write "<h3 style='color:red;'>❌ Connection Failed</h3>"
        Response.Write "<pre style='background:#ffebee; padding:15px; border:2px solid red;'>"
        Response.Write "<b>Error Number:</b> " & Err.Number & "<br>"
        Response.Write "<b>Error Description:</b> " & HtmlEncode(Err.Description) & "<br><br>"
        Response.Write "<b>Connection String:</b><br>" & HtmlEncode(connStr)
        Response.Write "</pre>"
    Else
        Response.Write "<p style='color:green; font-weight:bold;'>✅ Connection successful ho gaya!</p>"
        Session("ConnStr") = connStr
        Call LoadTables()
    End If
    
    If Not conn Is Nothing Then
        If conn.State = 1 Then conn.Close
        Set conn = Nothing
    End If
    On Error GoTo 0
End Sub

' ====================== LOAD TABLES ======================
Sub LoadTables()
    On Error Resume Next
    Dim conn, rs, sql, count
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    sql = "SHOW TABLES"
    
    Set rs = conn.Execute(sql)
    count = 0
    
    Response.Write "<script>document.getElementById('ddlTables').innerHTML = '';</script>"
    
    Do While Not rs.EOF
        Response.Write "<option value='" & HtmlEncode(rs(0)) & "'>" & HtmlEncode(rs(0)) & "</option>"
        count = count + 1
        rs.MoveNext
    Loop
    
    Response.Write "<p style='color:#006600;'>Tables load ho gaye (" & count & " tables found).</p>"
    
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
    On Error GoTo 0
End Sub

' ====================== VIEW TABLE & RUN QUERY ======================
Sub ViewTable()
    ' Same as previous version but with MySQL support
    On Error Resume Next
    Dim tableName : tableName = Trim(Request.Form("ddlTables"))
    If tableName = "" Then
        Response.Write "<p style='color:red;'>Table select karo!</p>"
        Exit Sub
    End If
    
    Dim conn, rs, sql
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    sql = "SELECT * FROM `" & Replace(tableName, "`", "``") & "` LIMIT 50"
    
    Set rs = conn.Execute(sql)
    
    If rs.EOF Then
        Response.Write "<p style='color:orange;'>Table mein koi data nahi hai.</p>"
    Else
        Dim html, i
        html = "<h3>Table: " & HtmlEncode(tableName) & " (Top 50 rows)</h3>"
        html = html & "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse; width:100%;'>"
        html = html & "<tr style='background:#007bff; color:white;'>"
        
        For i = 0 To rs.Fields.Count - 1
            html = html & "<th>" & HtmlEncode(rs.Fields(i).Name) & "</th>"
        Next
        html = html & "</tr>"
        
        Do While Not rs.EOF
            html = html & "<tr>"
            For i = 0 To rs.Fields.Count - 1
                html = html & "<td>" & HtmlEncode(rs.Fields(i).Value) & "</td>"
            Next
            html = html & "</tr>"
            rs.MoveNext
        Loop
        html = html & "</table>"
        Response.Write html
    End If
    
    rs.Close : conn.Close
    Set rs = Nothing : Set conn = Nothing
    On Error GoTo 0
End Sub

Sub RunQuery()
    On Error Resume Next
    Dim query : query = Trim(Request.Form("txtQuery"))
    If query = "" Then
        Response.Write "<p style='color:red;'>Query likho!</p>" : Exit Sub
    End If
    
    Dim conn, rs, affected
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    If UCase(Left(Trim(query), 6)) = "SELECT" Then
        Set rs = conn.Execute(query)
        If Err.Number <> 0 Then
            Response.Write "<pre style='color:red;'>Query Error: " & HtmlEncode(Err.Description) & "</pre>"
        ElseIf rs.EOF Then
            Response.Write "<p style='color:orange;'>Koi result nahi mila.</p>"
        Else
            ' Table generation code (same as ViewTable)
            Dim html, i
            html = "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse;width:100%;'>"
            html = html & "<tr style='background:#28a745;color:white;'>"
            For i = 0 To rs.Fields.Count-1
                html = html & "<th>" & HtmlEncode(rs.Fields(i).Name) & "</th>"
            Next
            html = html & "</tr>"
            
            Do While Not rs.EOF
                html = html & "<tr>"
                For i = 0 To rs.Fields.Count-1
                    html = html & "<td>" & HtmlEncode(rs.Fields(i).Value) & "</td>"
                Next
                html = html & "</tr>"
                rs.MoveNext
            Loop
            html = html & "</table>"
            Response.Write html
        End If
        If Not rs Is Nothing Then rs.Close
    Else
        conn.Execute query, affected
        If Err.Number <> 0 Then
            Response.Write "<pre style='color:red;'>Query Error: " & HtmlEncode(Err.Description) & "</pre>"
        Else
            Response.Write "<p style='color:green;'>Query execute ho gaya! Rows affected: " & affected & "</p>"
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
    <title>MySQL Manager - Classic ASP</title>
    <style>
        body { font-family: Arial, sans-serif; background:#f4f6f9; margin:0; padding:20px; }
        .container { max-width:1200px; margin:auto; background:white; padding:25px; border-radius:8px; box-shadow:0 2px 12px rgba(0,0,0,0.12); }
        input, textarea, select { width:100%; padding:10px; box-sizing:border-box; border:1px solid #ccc; border-radius:4px; }
        button { padding:12px 24px; background:#007bff; color:white; border:none; border-radius:4px; cursor:pointer; }
        .section { margin:25px 0; padding:20px; border:1px solid #ddd; border-radius:6px; background:#fafafa; }
        table { border-collapse:collapse; width:100%; margin-top:10px; }
        th, td { border:1px solid #ddd; padding:8px; }
        th { background:#007bff; color:white; }
        pre { background:#ffebee; padding:15px; border:2px solid red; white-space:pre-wrap; }
    </style>
</head>
<body>
    <div class="container">
        <h2>MySQL Database Manager</h2>
        <form method="post">
            <div class="section">
                <h3>1. Connection Details</h3>
                <input type="text" name="txtServer" placeholder="Server (10.10.1.75)" value="10.10.1.75" /><br><br>
                <input type="text" name="txtDbName" placeholder="Database" value="flowhcms_hmc" /><br><br>
                <input type="text" name="txtUser" placeholder="User" value="root" /><br><br>
                <input type="password" name="txtPass" placeholder="Password" value="123qwe" /><br><br>
                <button type="submit" name="btnConnect" value="1">Connect</button>
            </div>

            <div class="section">
                <h3>2. Tables</h3>
                <select name="ddlTables" id="ddlTables" style="width:400px;"></select><br><br>
                <button type="submit" name="btnViewTable" value="1">View Top 50 Rows</button>
            </div>

            <div class="section">
                <h3>3. Run Query</h3>
                <textarea name="txtQuery" rows="8" placeholder="SELECT * FROM users LIMIT 10"></textarea><br>
                <button type="submit" name="btnRun" value="1">Execute Query</button>
            </div>
        </form>
    </div>
</body>
</html>
