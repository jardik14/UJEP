<!DOCTYPE html>
<html>
<head>
    <title>Project Information - Client Side Transformation</title>
    <meta charset="UTF-8">
    <style>
        .error-message {
            color: #cb2431;
            background-color: #ffeef0;
            padding: 15px;
            border-radius: 6px;
            margin: 10px 0;
            border: 1px solid #ffd7d5;
        }
        #loading {
            text-align: center;
            padding: 20px;
            font-style: italic;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .nav-link {
            display: inline-block;
            padding: 8px 16px;
            background-color: #2ea44f;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .nav-link:hover {
            background-color: #2c974b;
        }
    </style>
    <script>
        // Utility function to fetch text with error handling
        const fetchText = async (fileName) => {
            try {
                const response = await fetch(fileName);
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return await response.text();
            } catch (error) {
                throw new Error(`Failed to fetch ${fileName}: ${error.message}`);
            }
        };

        // Function to handle and display errors
        const handleError = (error) => {
            const errorDiv = document.createElement('div');
            errorDiv.className = 'error-message';
            errorDiv.innerHTML = `
                <h2>Error occurred during transformation:</h2>
                <p>${error.message}</p>
                <h3>Debug Information:</h3>
                <pre>${error.stack}</pre>
            `;
            document.getElementById('project-info').appendChild(errorDiv);
        };

        // Main transformation function
        const transformXML = async () => {
            try {
                // Show loading message
                const loadingDiv = document.createElement('div');
                loadingDiv.id = 'loading';
                loadingDiv.textContent = 'Loading project information...';
                document.getElementById('project-info').appendChild(loadingDiv);

                // Fetch XML and XSL files
                const [xmlText, xslText] = await Promise.all([
                    fetchText('xml/project.xml'),
                    fetchText('xml/project_better.xsl')
                ]);

                // Parse XML and XSL
                const parser = new DOMParser();
                const xml = parser.parseFromString(xmlText, 'application/xml');
                const xsl = parser.parseFromString(xslText, 'application/xml');

                // Check for parsing errors
                const xmlError = xml.querySelector('parsererror');
                const xslError = xsl.querySelector('parsererror');
                
                if (xmlError) throw new Error(`XML parsing error: ${xmlError.textContent}`);
                if (xslError) throw new Error(`XSL parsing error: ${xslError.textContent}`);

                // Create and configure XSLT processor
                const xsltProc = new XSLTProcessor();
                xsltProc.importStylesheet(xsl);

                // Transform XML
                const fragment = xsltProc.transformToFragment(xml, document);

                // Remove loading message
                loadingDiv.remove();

                // Clear previous content and append new content
                const projectInfo = document.getElementById('project-info');
                projectInfo.innerHTML = '';
                projectInfo.appendChild(fragment);

            } catch (error) {
                // Remove loading message if it exists
                const loadingDiv = document.getElementById('loading');
                if (loadingDiv) loadingDiv.remove();

                // Handle the error
                handleError(error);
            }
        };

        // Initialize transformation when DOM is loaded
        document.addEventListener("DOMContentLoaded", transformXML);
    </script>
</head>
<body>
    <div class="container">
        <h1>Project Information - Client Side Transformation</h1>
        <a href="index.php" class="nav-link">Back to Main Page</a>
        <div id="project-info"></div>
    </div>
</body>
</html>
