<%@ Page Language="C#" AutoEventWireup="true" %>
<script language="c#" runat="server">
    /// <summary>
    /// Handles the Load event of the Page.
    /// </summary>
    /// <param name="sender">The source of the event.</param>
    /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
    public void Page_Load(object sender, EventArgs e)
    {
        // Clear the response
        this.Response.Clear();

        // Get the image parameters from the query string
        string path = string.Empty;
        if (!string.IsNullOrEmpty((Request.QueryString["path"] ?? string.Empty).Trim()))
        {
            path = this.Server.MapPath("~/" + this.Request.QueryString["path"]);
        }

        int width;
        if (!int.TryParse(Request.QueryString["width"] ?? string.Empty, out width))
        {
            width = 0;
        }

        int height;
        if (!int.TryParse(Request.QueryString["height"] ?? string.Empty, out height))
        {
            height = 0;
        }
    }
</script>
