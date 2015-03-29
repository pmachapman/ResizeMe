<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Drawing.Drawing2D" %>
<%@ Import Namespace="System.Drawing.Imaging" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<script language="C#" runat="server">
    /// <summary>
    /// Handles the Load event of the Page.
    /// </summary>
    /// <param name="sender">The source of the event.</param>
    /// <param name="e">The <see cref="EventArgs"/> instance containing the event data.</param>
    public void Page_Load(object sender, EventArgs e)
    {
        // Clear the response, set up caching
        this.Response.Clear();
        this.Response.Cache.SetExpires(DateTime.Now.AddMonths(1));

        // Get the image parameters from the query string
        string path = string.Empty;
        if (!string.IsNullOrEmpty((this.Request.QueryString["path"] ?? string.Empty).Trim()))
        {
            path = this.Server.MapPath("~/" + this.Request.QueryString["path"]);
        }
        else
        {
            // Return a 404 error
            this.Response.Status = "404 Not Found";
            this.Response.StatusCode = 404;
            this.Response.End();
            return;
        }

        int width;
        if (!int.TryParse(this.Request.QueryString["width"] ?? string.Empty, out width) || width < 0)
        {
            width = 0;
        }

        int height;
        if (!int.TryParse(this.Request.QueryString["height"] ?? string.Empty, out height) || height < 0)
        {
            height = 0;
        }

        // Use either PNG or JPEG
        string fileExtension;
        ImageFormat imageFormat;
        if (path.EndsWith(".png", StringComparison.OrdinalIgnoreCase))
        {
            this.Response.ContentType = "image/png";
            fileExtension = ".png";
            imageFormat = ImageFormat.Png;
        }
        else
        {
            this.Response.ContentType = "image/jpeg";
            fileExtension = ".jpg";
            imageFormat = ImageFormat.Jpeg;
        }

        // See if the cached copy is up to date
        DateTime lastModified;
        try
        {
            lastModified = File.GetLastWriteTime(path);
        }
        catch (Exception)
        {
            lastModified = DateTime.Now;
        }

        // See if we have a copy in the cache
        string fileName;
        FileInfo fileInfo;
        bool useCache;
        try
        {
            // Setup the cache directory and file
            string cache = Server.MapPath("~/Cache");
            fileName = cache + "\\" + CalculateMD5Hash(Request.Url.ToString()) + fileExtension;

            // Create the cache if it does not exist
            if (!Directory.Exists(cache))
            {
                DirectoryInfo directoryInfo = Directory.CreateDirectory(cache);
                directoryInfo.Attributes = FileAttributes.Directory | FileAttributes.Hidden;
            }

            // Make sure the file cached is correct
            fileInfo = new FileInfo(fileName);
            if (fileInfo.Exists && fileInfo.LastWriteTime == lastModified)
            {
                useCache = true;
            }
            else
            {
                useCache = false;
            }
        }
        catch (Exception)
        {
            // Do not use the cache
            useCache = false;
            fileName = default(string);
            fileInfo = default(FileInfo);
        }

        // See if we are to use the cache or not
        if (useCache)
        {
            Response.WriteFile(fileName);
        }
        else
        {
            // Use a memory stream to output the image
            using (MemoryStream stream = new MemoryStream())
            {
                try
                {
                    using (Bitmap bitmap = new Bitmap(path))
                    {
                        if (width == 0 && height == 0)
                        {
                            // No resizing
                            bitmap.Save(stream, imageFormat);
                        }
                        else
                        {
                            // If only height or width is specified, get the ration
                            double ratio;
                            if (height == 0)
                            {
                                ratio = (double)width / (double)bitmap.Width;
                            }
                            else if (width == 0)
                            {
                                ratio = (double)height / (double)bitmap.Height;
                            }
                            else
                            {
                                ratio = 0;
                            }

                            // Use the ratio if non-zero
                            if (ratio != 0)
                            {
                                height = Convert.ToInt32((double)bitmap.Height * ratio);
                                width = Convert.ToInt32((double)bitmap.Width * ratio);
                            }

                            // Clean up invalid heights and widths
                            if (height <= 0)
                            {
                                height = 1;
                            }

                            if (width <= 0)
                            {
                                width = 1;
                            }
                            
                            // Resize the image!
                            using (Bitmap newBitmap = new Bitmap(width, height))
                            {
                                using (Graphics graphics = Graphics.FromImage(newBitmap))
                                {
                                    graphics.SmoothingMode = SmoothingMode.AntiAlias;
                                    graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                                    graphics.DrawImage(bitmap, 0, 0, newBitmap.Width, newBitmap.Height);
                                    newBitmap.Save(stream, imageFormat);
                                }
                            }
                        }
                    }
                }
                catch (Exception)
                {
                    // Return a 404 error
                    this.Response.Status = "404 Not Found";
                    this.Response.StatusCode = 404;
                    this.Response.End();
                    return;
                }

                // Save the image to the cache
                try
                {
                    if (!string.IsNullOrEmpty(fileName))
                    {
                        using (FileStream file = File.OpenWrite(fileName))
                        {
                            stream.WriteTo(file);
                            if (fileInfo != default(FileInfo))
                            {
                                fileInfo.LastWriteTime = lastModified;
                            }
                        }
                    }
                }
                catch (Exception)
                {
                    // Ignore errors saving to the cache
                }

                // Write image to the response output stream
                stream.WriteTo(this.Response.OutputStream);
            }
        }

        // Image has been returned
        this.Response.End();
    }

    /// <summary>
    /// Calculates the MD5 hash.
    /// </summary>
    /// <param name="input">The input.</param>
    /// <returns>An MD5 hash</returns>
    /// <remarks>Code based on the example given at <c>http://blogs.msdn.com/b/csharpfaq/archive/2006/10/09/how-do-i-calculate-a-md5-hash-from-a-string_3f00_.aspx</c></remarks>
    private static string CalculateMD5Hash(string input)
    {
        // Step 1, calculate MD5 hash from input
        using (MD5 md5 = MD5.Create())
        {
            byte[] inputBytes = Encoding.ASCII.GetBytes(input);
            byte[] hash = md5.ComputeHash(inputBytes);

            // Step 2, convert byte array to hex string
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < hash.Length; i++)
            {
                sb.Append(hash[i].ToString("X2"));
            }

            return sb.ToString();
        }
    }
</script>
