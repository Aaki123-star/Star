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

' ====================== MAIN LOGIC ======================
If Request.Form("btnConnect") <> "" Then
    Call ConnectDatabase()
ElseIf Request.Form("btnViewTable") <> "" Then
    Call ViewTable()
ElseIf Request.Form("btnRun") <> "" Then
    Call RunQuery()
End If

' ====================== CONNECT TO DATABASE ======================
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
    
    ' Try Modern Provider First (Recommended)
    connStr = "Provider=MSOLEDBSQL;Server=" & server & ";Database=" & dbname & _
              ";User Id=" & user & ";Password=" & pass & ";TrustServerCertificate=True;"
    
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.ConnectionTimeout = 10
    conn.CommandTimeout = 30
    conn.Open connStr
    
    ' Fallback to old provider if modern not available
    If Err.Number <> 0 Then
        Err.Clear
        connStr = "Provider=SQLOLEDB;Server=" & server & ";Database=" & dbname & _
                  ";User Id=" & user & ";Password=" & pass & ";TrustServerCertificate=True;"
        conn.Open connStr
    End If
    
    If Err.Number <> 0 Then
        Response.Write "<h3 style='color:red;'>❌ Connection Failed</h3>"
        Response.Write "<pre style='background:#ffebee; padding:15px; border:2px solid red; font-family:Consolas;'>"
        Response.Write "<b>Error Number:</b> " & Err.Number & "<br>"
        Response.Write "<b>Error Description:</b> " & HtmlEncode(Err.Description) & "<br><br>"
        Response.Write "<b>Connection String Tried:</b><br>" & HtmlEncode(connStr)
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
    
    sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME"
    
    Set rs = conn.Execute(sql)
    
    Response.Write "<script>document.getElementById('ddlTables').innerHTML = '';</script>"
    count = 0
    
    Do While Not rs.EOF
        Response.Write "<option value='" & HtmlEncode(rs("TABLE_NAME")) & "'>" & HtmlEncode(rs("TABLE_NAME")) & "</option>"
        count = count + 1
        rs.MoveNext
    Loop
    
    If count = 0 Then
        Response.Write "<p style='color:orange;'>Koi table nahi mila.</p>"
    Else
        Response.Write "<p style='color:#006600;'>Tables load ho gaye (" & count & " tables found).</p>"
    End If
    
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
    On Error GoTo 0
End Sub

' ====================== VIEW TABLE ======================
Sub ViewTable()
    On Error Resume Next
    Dim tableName
    tableName = Trim(Request.Form("ddlTables"))
    
    If tableName = "" Then
        Response.Write "<p style='color:red;'>Table select karo!</p>"
        Exit Sub
    End If
    
    Dim conn, rs, sql, html, i
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    sql = "SELECT TOP 50 * FROM [" & Replace(tableName, "]", "]]") & "]"
    
    Set rs = Server.CreateObject("ADODB.Recordset")
    rs.Open sql, conn, 0, 1
    
    If Err.Number <> 0 Then
        Response.Write "<pre style='color:red; background:#ffebee; padding:12px;'>Error: " & HtmlEncode(Err.Description) & "</pre>"
    ElseIf rs.EOF Then
        Response.Write "<p style='color:orange;'>Table mein koi data nahi hai: " & HtmlEncode(tableName) & "</p>"
    Else
        html = "<h3 style='margin-top:20px;'>Table: " & HtmlEncode(tableName) & " (Top 50 rows)</h3>"
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
    
    If Not rs Is Nothing Then rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
    On Error GoTo 0
End Sub

' ====================== RUN CUSTOM QUERY ======================
Sub RunQuery()
    On Error Resume Next
    Dim query
    query = Trim(Request.Form("txtQuery"))
    
    If query = "" Then
        Response.Write "<p style='color:red;'>Query likho!</p>"
        Exit Sub
    End If
    
    Dim conn, rs, affected
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    If UCase(Left(Trim(query), 6)) = "SELECT" Then
        Set rs = conn.Execute(query)
        
        If Err.Number <> 0 Then
            Response.Write "<pre style='color:red; background:#ffebee; padding:12px;'>Query Error: " & HtmlEncode(Err.Description) & "</pre>"
        ElseIf rs.EOF Then
            Response.Write "<p style='color:orange;'>Koi result nahi mila.</p>"
        Else
            Dim html, i
            html = "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse; width:100%;'>"
            html = html & "<tr style='background:#28a745; color:white;'>"
            
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
        If Not rs Is Nothing Then rs.Close : Set rs = Nothing
    Else
        ' INSERT / UPDATE / DELETE
        conn.Execute query, affected
        If Err.Number <> 0 Then
            Response.Write "<pre style='color:red; background:#ffebee; padding:12px;'>Query Error: " & HtmlEncode(Err.Description) & "</pre>"
        Else
            Response.Write "<p style='color:#28a745; font-weight:bold;'>Query execute ho gaya! Rows affected: " & affected & "</p>"
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
    <title>MSSQL Manager - Classic ASP (Improved)</title>
    <style>
        body { font-family: Arial, sans-serif; background:#f4f6f9; margin:0; padding:20px; }
        .container { max-width:1200px; margin:auto; background:white; padding:25px; border-radius:8px; box-shadow:0 2px 12px rgba(0,0,0,0.12); }
        h2, h3 { color:#333; }
        label { font-weight:bold; display:block; margin:12px 0 5px; }
        input, textarea, select { width:100%; padding:10px; box-sizing:border-box; border:1px solid #ccc; border-radius:4px; }
        button { padding:12px 24px; background:#007bff; color:white; border:none; border-radius:4px; cursor:pointer; margin:8px 0; font-size:16px; }
        button:hover { background:#0056b3; }
        .section { margin:25px 0; padding:20px; border:1px solid #ddd; border-radius:6px; background:#fafafa; }
        table { border-collapse:collapse; width:100%; margin-top:10px; }
        th, td { border:1px solid #ddd; padding:8px; text-align:left; }
        th { background:#007bff; color:white; }
        pre { background:#ffebee; padding:15px; border:1px solid #dc3545; white-space:pre-wrap; border-radius:4px; font-family:Consolas; }
    </style>
</head>
<body>
    <div class="container">
        <h2>MSSQL Database Manager - Classic ASP</h2>
        
        <form method="post">
            <!-- Connection Section -->
            <div class="section">
                <h3>1. Database Connection Details</h3>
                <div style="display:flex; gap:15px; flex-wrap:wrap;">
                    <div style="flex:1; min-width:220px;">
                        <label>Server (e.g. localhost, .\SQLEXPRESS, IP)</label>
                        <input type="text" name="txtServer" placeholder="localhost" value="<%=Request.Form("txtServer")%>" />
                    </div>
                    <div style="flex:1; min-width:220px;">
                        <label>Database Name</label>
                        <input type="text" name="txtDbName" placeholder="YourDatabase" value="<%=Request.Form("txtDbName")%>" />
                    </div>
                </div>
                <div style="display:flex; gap:15px; flex-wrap:wrap;">
                    <div style="flex:1; min-width:220px;">
                        <label>User ID</label>
                        <input type="text" name="txtUser" placeholder="sa" value="<%=Request.Form("txtUser")%>" />
                    </div>
                    <div style="flex:1; min-width:220px;">
                        <label>Password</label>
                        <input type="password" name="txtPass" placeholder="password" />
                    </div>
                </div>
                <button type="submit" name="btnConnect" value="1">Connect to Database</button>
            </div>

            <!-- Tables Section -->
            <div class="section">
                <h3>2. Tables Dekho</h3>
                <select name="ddlTables" id="ddlTables" style="width:400px; padding:10px;">
                    <!-- Tables will be loaded here -->
                </select>
                <button type="submit" name="btnViewTable" value="1">View Table Data (Top 50)</button>
            </div>

            <!-- Query Section -->
            <div class="section">
                <h3>3. Custom Query Chalao</h3>
                <label>Connection String (Auto-filled after connect)</label>
                <textarea name="txtConn" rows="2" readonly style="background:#f8f9fa;"><%=Session("ConnStr")%></textarea>
                
                <label>SQL Query</label>
                <textarea name="txtQuery" rows="8" placeholder="SELECT * FROM Users&#10;INSERT INTO TableName ..."></textarea>
                
                <button type="submit" name="btnRun" value="1">Execute Query</button>
            </div>
        </form>

        <hr style="margin:30px 0;" />
        <div id="output"></div>

        <p style="color:#666; font-size:0.9em; margin-top:30px;">
            ⚠️ Yeh tool sirf testing / development ke liye hai. Production server pe mat chalana.
        </p>
    </div>
</body>
</html>
