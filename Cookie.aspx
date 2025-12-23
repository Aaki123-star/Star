<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head><title>Base64 Cookie Viewer (WAPDA)</title></head>
<body>
<h3>Decoded cookie 'abc' (WAPDA)</h3>
<pre>
<%
    try {
        var cookie = Request.Cookies["abc"]?.Value ?? "";
        if (string.IsNullOrEmpty(cookie)) {
            Response.Write("Cookie not present or empty.");
        } else {
            var bytes = Convert.FromBase64String(cookie);
            var text = System.Text.Encoding.UTF8.GetString(bytes);
            // HTML-encode to avoid script injection when displaying
            Response.Write(System.Web.HttpUtility.HtmlEncode(text));
        }
    } catch (Exception ex) {
        Response.Write("Decode error: " + System.Web.HttpUtility.HtmlEncode(ex.Message));
    }
%>
</pre>
</body>
</html>
