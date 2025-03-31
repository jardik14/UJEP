<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match="/">
        <html>
            <head>
                <title>Project Information</title>
                <link rel="stylesheet" href="project.css"/>
            </head>
            <body>
                <div class="container">
                    <h1>Project Information</h1>
                    
                    <!-- Project Info Table -->
                    <h2>Project Details</h2>
                    <table border="1">
                        <tr bgcolor="#f6f8fa">
                            <th style="text-align:left">Name</th>
                            <th style="text-align:left">Version</th>
                            <th style="text-align:left">Author</th>
                            <th style="text-align:left">Date</th>
                        </tr>
                        <tr>
                            <td><xsl:value-of select="project/project-info/name"/></td>
                            <td><xsl:value-of select="project/project-info/version"/></td>
                            <td><xsl:value-of select="project/project-info/author"/></td>
                            <td><xsl:value-of select="project/project-info/date"/></td>
                        </tr>
                    </table>

                    <!-- Features Table -->
                    <h2>Features</h2>
                    <table border="1">
                        <tr bgcolor="#f6f8fa">
                            <th style="text-align:left">Name</th>
                            <th style="text-align:left">Description</th>
                            <th style="text-align:left">Status</th>
                        </tr>
                        <xsl:for-each select="project/features/feature">
                            <tr>
                                <td><xsl:value-of select="name"/></td>
                                <td><xsl:value-of select="description"/></td>
                                <td><xsl:value-of select="status"/></td>
                            </tr>
                        </xsl:for-each>
                    </table>

                    <!-- Settings Table -->
                    <h2>Configuration Settings</h2>
                    <table border="1">
                        <tr bgcolor="#f6f8fa">
                            <th style="text-align:left">Category</th>
                            <th style="text-align:left">Type</th>
                            <th style="text-align:left">Version</th>
                            <th style="text-align:left">Details</th>
                        </tr>
                        <xsl:for-each select="project/settings/*">
                            <tr>
                                <td><xsl:value-of select="name()"/></td>
                                <td><xsl:value-of select="type"/></td>
                                <td><xsl:value-of select="version"/></td>
                                <td>
                                    <xsl:for-each select="*[not(name()='type' or name()='version')]">
                                        <xsl:value-of select="name()"/>: <xsl:value-of select="."/><br/>
                                    </xsl:for-each>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>

                    <!-- Dependencies Table -->
                    <h2>Dependencies</h2>
                    <table border="1">
                        <tr bgcolor="#f6f8fa">
                            <th style="text-align:left">Name</th>
                            <th style="text-align:left">Version</th>
                            <th style="text-align:left">Type</th>
                        </tr>
                        <xsl:for-each select="project/dependencies/dependency">
                            <tr>
                                <td><xsl:value-of select="name"/></td>
                                <td><xsl:value-of select="version"/></td>
                                <td><xsl:value-of select="type"/></td>
                            </tr>
                        </xsl:for-each>
                    </table>

                    <!-- Contact Information -->
                    <h2>Contact Information</h2>
                    <table border="1">
                        <tr bgcolor="#f6f8fa">
                            <th style="text-align:left">Email</th>
                            <th style="text-align:left">Phone</th>
                            <th style="text-align:left">Address</th>
                        </tr>
                        <tr>
                            <td><xsl:value-of select="project/contact/email"/></td>
                            <td><xsl:value-of select="project/contact/phone"/></td>
                            <td>
                                <xsl:value-of select="project/contact/address/street"/><br/>
                                <xsl:value-of select="project/contact/address/city"/><br/>
                                <xsl:value-of select="project/contact/address/country"/>
                            </td>
                        </tr>
                    </table>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
