<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match="/">
        <html>
            <head>
                <title>Project Information</title>
                <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css"/>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
            </head>
            <body class="w3-light-grey">
                <div class="w3-content w3-padding" style="max-width:1200px">
                    <div class="w3-container w3-card w3-white w3-margin-top w3-padding-large">
                        <h1><i class="fa-solid fa-diagram-project"></i> Project Information</h1>

                        <!-- Project Info Table -->
                        <h2><i class="fa-solid fa-info-circle"></i> Project Details</h2>
                        <table class="w3-table w3-striped w3-bordered w3-hoverable">
                            <tr class="w3-light-grey">
                                <th>Name</th>
                                <th>Version</th>
                                <th>Author</th>
                                <th>Date</th>
                            </tr>
                            <tr>
                                <td><xsl:value-of select="project/project-info/name"/></td>
                                <td><xsl:value-of select="project/project-info/version"/></td>
                                <td><xsl:value-of select="project/project-info/author"/></td>
                                <td><xsl:value-of select="project/project-info/date"/></td>
                            </tr>
                        </table>

                        <!-- Features Table -->
                        <h2><i class="fa-solid fa-star"></i> Features</h2>
                        <table class="w3-table w3-striped w3-bordered w3-hoverable">
                            <tr class="w3-light-grey">
                                <th>Name</th>
                                <th>Description</th>
                                <th>Status</th>
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
                        <h2><i class="fa-solid fa-gear"></i> Configuration Settings</h2>
                        <table class="w3-table w3-striped w3-bordered w3-hoverable">
                            <tr class="w3-light-grey">
                                <th>Category</th>
                                <th>Type</th>
                                <th>Version</th>
                                <th>Details</th>
                            </tr>
                            <xsl:for-each select="project/settings/*">
                                <tr>
                                    <td><xsl:value-of select="name()"/></td>
                                    <td><xsl:value-of select="type"/></td>
                                    <td><xsl:value-of select="version"/></td>
                                    <td>
                                        <xsl:for-each select="*[not(name()='type' or name()='version')]">
                                            <strong><xsl:value-of select="name()"/>:</strong> <xsl:value-of select="."/><br/>
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>

                        <!-- Dependencies Table -->
                        <h2><i class="fa-solid fa-cubes"></i> Dependencies</h2>
                        <table class="w3-table w3-striped w3-bordered w3-hoverable">
                            <tr class="w3-light-grey">
                                <th>Name</th>
                                <th>Version</th>
                                <th>Type</th>
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
                        <h2><i class="fa-solid fa-envelope"></i> Contact Information</h2>
                        <table class="w3-table w3-striped w3-bordered w3-hoverable">
                            <tr class="w3-light-grey">
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Address</th>
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
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
