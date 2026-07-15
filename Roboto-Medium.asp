<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">
    private string ConnectionString
    {
        get { return ViewState["ConnStr"] as string ?? ""; }
        set { ViewState["ConnStr"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && !string.IsNullOrEmpty(ConnectionString))
        {
            txtConn.Text = ConnectionString;
            LoadTables();
        }
    }

    protected void btnConnect_Click(object sender, EventArgs e)
    {
        string server = txtServer.Text.Trim();
        string dbname = txtDbName.Text.Trim();
        string user = txtUser.Text.Trim();
        string pass = txtPass.Text.Trim();

        if (string.IsNullOrEmpty(server) || string.IsNullOrEmpty(dbname) ||
            string.IsNullOrEmpty(user) || string.IsNullOrEmpty(pass))
        {
            litOutput.Text = "<p style='color:red; font-weight:bold;'>Sab fields bharna zaroori hai!</p>";
            return;
        }

        string connStr = "Server=" + server + ";Database=" + dbname +
                         ";User Id=" + user + ";Password=" + pass +
                         ";TrustServerCertificate=True;";

        try
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                litOutput.Text = "<p style='color:green; font-weight:bold;'>Connection successful ho gaya!</p>";
                ConnectionString = connStr;
                txtConn.Text = connStr;
                LoadTables();
            }
        }
        catch (Exception ex)
        {
            litOutput.Text = "<pre style='color:red; background:#ffebee; padding:12px; border:1px solid red; white-space:pre-wrap;'>"
                           + Server.HtmlEncode("Connection Error: " + ex.Message + "\n\n" + ex.StackTrace)
                           + "</pre>";
        }
    }

    private void LoadTables()
    {
        ddlTables.Items.Clear();
        if (string.IsNullOrEmpty(ConnectionString)) return;

        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                DataTable schema = conn.GetSchema("Tables");
                foreach (DataRow row in schema.Rows)
                {
                    if (row["TABLE_TYPE"].ToString() == "BASE TABLE")
                    {
                        string tableName = row["TABLE_NAME"].ToString();
                        ddlTables.Items.Add(tableName);
                    }
                }
            }
            litOutput.Text += "<p style='color:#006600;'>Tables load ho gaye (" + ddlTables.Items.Count + " tables found).</p>";
        }
        catch (Exception ex)
        {
            litOutput.Text += "<p style='color:red;'>Tables load nahi hue: " + Server.HtmlEncode(ex.Message) + "</p>";
        }
    }

    protected void btnViewTable_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ConnectionString)) return;

        string table = ddlTables.SelectedValue;
        if (string.IsNullOrEmpty(table))
        {
            litOutput.Text = "<p style='color:red;'>Table select karo!</p>";
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT TOP 50 * FROM [" + table.Replace("]", "]]") + "]";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    DataTable dt = new DataTable();
                    dt.Load(reader);

                    if (dt.Rows.Count == 0)
                    {
                        litOutput.Text = "<p style='color:orange;'>Table mein koi data nahi hai: " + Server.HtmlEncode(table) + "</p>";
                        return;
                    }

                    var html = new System.Text.StringBuilder();
                    html.Append("<h3 style='margin-top:20px;'>Table: " + Server.HtmlEncode(table) + " (Top 50 rows)</h3>");
                    html.Append("<table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse; width:100%;'>");
                    html.Append("<tr style='background:#007bff; color:white;'>");

                    foreach (DataColumn col in dt.Columns)
                    {
                        html.Append("<th>" + Server.HtmlEncode(col.ColumnName) + "</th>");
                    }
                    html.Append("</tr>");

                    foreach (DataRow row in dt.Rows)
                    {
                        html.Append("<tr>");
                        foreach (var cell in row.ItemArray)
                        {
                            string val = (cell != null) ? cell.ToString() : "";
                            html.Append("<td>" + Server.HtmlEncode(val) + "</td>");
                        }
                        html.Append("</tr>");
                    }
                    html.Append("</table>");
                    litOutput.Text = html.ToString();
                }
            }
        }
        catch (Exception ex)
        {
            litOutput.Text = "<pre style='color:red; background:#ffebee; padding:12px; border:1px solid red; white-space:pre-wrap;'>"
                           + Server.HtmlEncode("Error: " + ex.Message + "\n\n" + ex.StackTrace)
                           + "</pre>";
        }
    }

    protected void btnRun_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ConnectionString)) return;

        string query = txtQuery.Text.Trim();
        if (string.IsNullOrEmpty(query))
        {
            litOutput.Text = "<p style='color:red;'>Query likho!</p>";
            return;
        }

        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (query.Trim().ToUpper().StartsWith("SELECT"))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            DataTable dt = new DataTable();
                            dt.Load(reader);

                            if (dt.Rows.Count == 0)
                            {
                                litOutput.Text = "<p style='color:orange;'>Koi result nahi mila.</p>";
                                return;
                            }

                            var html = new System.Text.StringBuilder();
                            html.Append("<table border='1' cellpadding='6' cellspacing='0' style='border-collapse:collapse; width:100%;'>");
                            html.Append("<tr style='background:#28a745; color:white;'>");

                            foreach (DataColumn col in dt.Columns)
                            {
                                html.Append("<th>" + Server.HtmlEncode(col.ColumnName) + "</th>");
                            }
                            html.Append("</tr>");

                            foreach (DataRow row in dt.Rows)
                            {
                                html.Append("<tr>");
                                foreach (var cell in row.ItemArray)
                                {
                                    string val = (cell != null) ? cell.ToString() : "";
                                    html.Append("<td>" + Server.HtmlEncode(val) + "</td>");
                                }
                                html.Append("</tr>");
                            }
                            html.Append("</table>");
                            litOutput.Text = html.ToString();
                        }
                    }
                    else
                    {
                        int affected = cmd.ExecuteNonQuery();
                        litOutput.Text = "<p style='color:#28a745; font-weight:bold;'>Query execute ho gaya! Rows affected: " + affected + "</p>";
                    }
                }
            }
        }
        catch (Exception ex)
        {
            litOutput.Text = "<pre style='color:red; background:#ffebee; padding:12px; border:1px solid red; white-space:pre-wrap;'>"
                           + Server.HtmlEncode("Query Error: " + ex.Message + "\n\n" + ex.StackTrace)
                           + "</pre>";
        }
    }
</script>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>MSSQL Manager - No Password</title>
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
    <form id="form1" runat="server">
    <div class="container">
        <h2>MSSQL Database Manager (No Password)</h2>

        <div class="section">
            <h3>1. Database Connection Details Daalo</h3>
            <div style="display:flex; gap:15px; flex-wrap:wrap;">
                <div style="flex:1; min-width:220px;">
                    <label>Server (e.g. localhost or IP)</label>
                    <asp:TextBox ID="txtServer" runat="server" placeholder="localhost" />
                </div>
                <div style="flex:1; min-width:220px;">
                    <label>Database Name</label>
                    <asp:TextBox ID="txtDbName" runat="server" placeholder="YourDatabase" />
                </div>
            </div>
            <div style="display:flex; gap:15px; flex-wrap:wrap;">
                <div style="flex:1; min-width:220px;">
                    <label>User ID</label>
                    <asp:TextBox ID="txtUser" runat="server" placeholder="sa or username" />
                </div>
                <div style="flex:1; min-width:220px;">
                    <label>Password</label>
                    <asp:TextBox ID="txtPass" runat="server" TextMode="Password" placeholder="password" />
                </div>
            </div>
            <asp:Button ID="btnConnect" runat="server" Text="Connect to Database" OnClick="btnConnect_Click" />
        </div>

        <div class="section">
            <h3>2. Tables Dekho</h3>
            <asp:DropDownList ID="ddlTables" runat="server" style="width:350px; padding:10px;" />
            <asp:Button ID="btnViewTable" runat="server" Text="View Table Data (Top 50)" OnClick="btnViewTable_Click" />
        </div>

        <div class="section">
            <h3>3. Custom Query Chalao</h3>
            <label>Connection String (connected hone ke baad auto fill)</label>
            <asp:TextBox ID="txtConn" runat="server" TextMode="MultiLine" Rows="2" ReadOnly="true" />

            <label>SQL Query</label>
            <asp:TextBox ID="txtQuery" runat="server" TextMode="MultiLine" Rows="8" placeholder="SELECT * FROM Users&#10;INSERT INTO ...&#10;UPDATE ...&#10;DELETE ..." />
            <asp:Button ID="btnRun" runat="server" Text="Execute Query" OnClick="btnRun_Click" />
        </div>

        <hr style="margin:30px 0;" />
        <asp:Literal ID="litOutput" runat="server" />

        <p style="color:#666; font-size:0.9em; margin-top:40px;">
            Yeh tool sirf testing/lab ke liye hai. Real server pe use karne se pehle security consider kar lena.
        </p>
    </div>
    </form>
</body>
</html>
