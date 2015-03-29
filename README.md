# ResizeMe

A simple image resizer with caching, suitable for an ASP.NET based website.

## Requirements

 * Microsoft .NET Framework 2.0 or higher
 * IIS 6.0 or higher, alternatively IIS Express

## Installation

 1. Download ResizeMe.aspx from https://raw.githubusercontent.com/pmachapman/ResizeMe/master/ResizeMe.aspx
 2. Copy the ResizeMe.aspx file to the root of your website.

## Examples

### Resize by height
/ResizeMe.aspx?path=images/test.jpg&height=40

### Resize by width
/ResizeMe.aspx?path=images/test.jpg&height=60

### Resize by height and width
/ResizeMe.aspx?path=images/test.png&height=50&width=50

### Convert to JPEG
/ResizeMe.aspx?path=images/test.bmp
