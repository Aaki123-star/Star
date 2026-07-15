<%@ Language="VBScript" %>
<% 
Option Explicit

Dim ConnStr
ConnStr = Session("ConnStr")

' Helper Function to get safe HTML
Function HtmlEncode(str)
    If IsNull(str) Or IsEmpty(str) Then
        HtmlEncode = ""
    Else
        HtmlEncode = Server.HTMLEncode(CStr(str))
    End If
End Function

' ====================== PAGE LOAD ======================
If Request.Form("btnConnect") <> "" Then
    Call ConnectDatabase()
ElseIf Request.Form("btnViewTable") <> "" Then
    Call ViewTable()
ElseIf Request.Form("btnRun") <> "" Then
    Call RunQuery()
End If

' ====================== CONNECT FUNCTION ======================
Sub ConnectDatabase()
    Dim server, dbname, user, pass, connStr
    server = Trim(Request.Form("txtServer"))
    dbname = Trim(Request.Form("txtDbName"))
    user   = Trim(Request.Form("txtUser"))
    pass   = Trim(Request.Form("txtPass"))
    
    If server = "" Or dbname = "" Or user = "" Or pass = "" Then
        Response.Write "<p style='color:red; font-weight:bold;'>Sab fields bharna zaroori hai!</p>"
        Exit Sub
    End If
    
    connStr = "Provider=SQLOLEDB;Server=" & server & ";Database=" & dbname & _
              ";User Id=" & user & ";Password=" & pass & ";TrustServerCertificate=True;"
    
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    
    On Error Resume Next
    conn.Open connStr
    
    If Err.Number <> 0 Then
        Response.Write "<pre style='color:red; background:#ffebee; padding:12px; border:1px solid red; white-space:pre-wrap;'>"
        Response.Write "Connection Error: " & HtmlEncode(Err.Description)
        Response.Write "</pre>"
    Else
        Response.Write "<p style='color:green; font-weight:bold;'>Connection successful ho gaya!</p>"
        Session("ConnStr") = connStr
        Call LoadTables()
    End If
    
    conn.Close
    Set conn = Nothing
    On Error GoTo 0
End Sub

' ====================== LOAD TABLES ======================
Sub LoadTables()
    Dim conn, rs, sql
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME"
    
    Set rs = conn.Execute(sql)
    
    Response.Write "<script>document.getElementById('ddlTables').innerHTML = '';</script>"
    
    Dim count
    count = 0
    
    Do While Not rs.EOF
        Response.Write "<option value='" & HtmlEncode(rs("TABLE_NAME")) & "'>" & HtmlEncode(rs("TABLE_NAME")) & "</option>"
        count = count + 1
        rs.MoveNext
    Loop
    
    Response.Write "<p style='color:#006600;'>Tables load ho gaye (" & count & " tables found).</p>"
    
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
End Sub

' ====================== VIEW TABLE ======================
Sub ViewTable()
    Dim tableName
    tableName = Trim(Request.Form("ddlTables"))
    
    If tableName = "" Then
        Response.Write "<p style='color:red;'>Table select karo!</p>"
        Exit Sub
    End If
    
    Dim conn, rs, sql
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    sql = "SELECT TOP 50 * FROM [" & Replace(tableName, "]", "]]") & "]"
    
    Set rs = Server.CreateObject("ADODB.Recordset")
    rs.Open sql, conn, 0, 1  ' adOpenForwardOnly, adLockReadOnly
    
    If rs.EOF Then
        Response.Write "<p style='color:orange;'>Table mein koi data nahi hai: " & HtmlEncode(tableName) & "</p>"
    Else
        Dim html
        html = "<h3 style='margin-top:20px;'>Table: " & HtmlEncode(tableName) & " (Top 50 rows)</h3>"
        html = html & "<table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse; width:100%;'>"
        html = html & "<tr style='background:#007bff; color:white;'>"
        
        Dim i
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
    
    rs.Close
    conn.Close
    Set rs = Nothing
    Set conn = Nothing
End Sub

' ====================== RUN CUSTOM QUERY ======================
Sub RunQuery()
    Dim query
    query = Trim(Request.Form("txtQuery"))
    
    If query = "" Then
        Response.Write "<p style='color:red;'>Query likho!</p>"
        Exit Sub
    End If
    
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open Session("ConnStr")
    
    On Error Resume Next
    
    If UCase(Left(Trim(query), 6)) = "SELECT" Then
        Dim rs
        Set rs = conn.Execute(query)
        
        If Err.Number <> 0 Then
            Response.Write "<pre style='color:red; background:#ffebee; padding:12px; border:1px solid red;'>Query Error: " & HtmlEncode(Err.Description) & "</pre>"
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
        ' Non-SELECT query (INSERT, UPDATE, DELETE)
        Dim affected
        affected = conn.Execute(query, affected)
        
        If Err.Number <> 0 Then
            Response.Write "<pre style='color:red; background:#ffebee; padding:12px; border:1px solid red;'>Query Error: " & HtmlEncode(Err.Description) & "</pre>"
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
    <title>MSSQL Manager - Classic ASP</title>
    <style>
        body { font-family: Arial, sans-serif; background:#f4f6f9; margin:0; padding:20px; }
        .container { max-width:1100px; margin:auto; background:white; padding:25px; border-radius:8px; box-shadow:0 2px 12px rgba(0,0,0,0.12); }
        h2, h3 { color:#333; }
        label { font-weight:bold; display:block; margin:12px 0 5px; }
        input, textarea, select { width:100%; padding:10px; box-sizing:border-box; border:1px solid #ccc; border-radius:4px; }
        button { padding:10px 20px; background:#007bff; color:white; border:none; border-radius:4px; cursor:pointer; margin:8px 0; }
        button:hover { background:#0056b3; }
        .section { margin:25px 0; padding:15px; border:1px solid #ddd; border-radius:6px; background:#fafafa; }
        table { border-collapse:collapse; width:100%; margin-top:10px; }
        th, td { border:1px solid #ddd; padding:8px; text-align:left; }
        th { background:#007bff; color:white; }
        pre { background:#ffebee; padding:12px; border:1px solid #dc3545; white-space:pre-wrap; border-radius:4px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>MSSQL Database Manager (Classic ASP)</h2>
        
        <form method="post">
            <div class="section">
                <h3>1. Database Connection Details Daalo</h3>
                <div style="display:flex; gap:15px; flex-wrap:wrap;">
                    <div style="flex:1; min-width:220px;">
                        <label>Server (e.g. localhost or IP)</label>
                        <input type="text" name="txtServer" placeholder="localhost" value="<%= Request.Form("txtServer") %>" />
                    </div>
                    <div style="flex:1; min-width:220px;">
                        <label>Database Name</label>
                        <input type="text" name="txtDbName" placeholder="YourDatabase" value="<%= Request.Form("txtDbName") %>" />
                    </div>
                </div>
                <div style="display:flex; gap:15px; flex-wrap:wrap;">
                    <div style="flex:1; min-width:220px;">
                        <label>User ID</label>
                        <input type="text" name="txtUser" placeholder="sa or username" value="<%= Request.Form("txtUser") %>" />
                    </div>
                    <div style="flex:1; min-width:220px;">
                        <label>Password</label>
                        <input type="password" name="txtPass" placeholder="password" />
                    </div>
                </div>
                <button type="submit" name="btnConnect" value="1">Connect to Database</button>
            </div>

            <div class="section">
                <h3>2. Tables Dekho</h3>
                <select name="ddlTables" id="ddlTables" style="width:350px; padding:10px;">
                    <% If Session("ConnStr") <> "" Then Call LoadTables() %>
                </select>
                <button type="submit" name="btnViewTable" value="1">View Table Data (Top 50)</button>
            </div>

            <div class="section">
                <h3>3. Custom Query Chalao</h3>
                <label>Connection String</label>
                <textarea name="txtConn" rows="2" readonly style="background:#f8f9fa;"><%= Session("ConnStr") %></textarea>
                
                <label>SQL Query</label>
                <textarea name="txtQuery" rows="8" placeholder="SELECT * FROM Users&#10;INSERT INTO ..."></textarea>
                
                <button type="submit" name="btnRun" value="1">Execute Query</button>
            </div>
        </form>

        <hr style="margin:30px 0;" />
        <div id="output">
            <% ' Output already written via Response.Write in functions %>
        </div>

        <p style="color:#666; font-size:0.9em; margin-top:40px;">
            Yeh tool sirf testing/lab ke liye hai. Real server pe use karne se pehle security consider kar lena.
        </p>
    </div>
</body>
</html>
