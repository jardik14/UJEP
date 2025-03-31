<!DOCTYPE html>
<html>
<head>
    <title>Choose XML File - Client Side Transformation</title>
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
        .file-selector {
            margin: 20px 0;
            padding: 15px;
            background-color: #f6f8fa;
            border-radius: 6px;
            border: 1px solid #e1e4e8;
        }
        .file-selector input[type="file"] {
            margin-right: 10px;
        }
        .file-selector button {
            padding: 8px 16px;
            background-color: #2ea44f;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .file-selector button:hover {
            background-color: #2c974b;
        }
        .file-info {
            font-size: 0.9em;
            color: #6a737d;
            margin-top: 5px;
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
        .file-input-wrapper {
            display: flex;
            align-items: center;
            gap: 10px;
        }
    </style>
    <script>
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

        // Function to update file info
        const updateFileInfo = (file) => {
            const infoDiv = document.getElementById('file-info');
            
            if (file) {
                const size = (file.size / 1024).toFixed(2);
                const modified = new Date(file.lastModified).toLocaleString();
                infoDiv.innerHTML = `
                    <div class="file-info">
                        Name: ${file.name}<br>
                        Size: ${size} KB<br>
                        Last modified: ${modified}
                    </div>
                `;
                infoDiv.style.display = 'block';
            } else {
                infoDiv.style.display = 'none';
            }
        };

        // Main transformation function
        const transformXML = async (file) => {
            try {
                // Show loading message
                const loadingDiv = document.createElement('div');
                loadingDiv.id = 'loading';
                loadingDiv.textContent = 'Loading project information...';
                document.getElementById('project-info').appendChild(loadingDiv);

                // Read the selected file
                const xmlText = await file.text();

                // Fetch XSL file
                const response = await fetch('xml/project.xsl');
                if (!response.ok) {
                    throw new Error(`Failed to fetch XSL file: ${response.status}`);
                }
                const xslText = await response.text();

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

        // Initialize when DOM is loaded
        document.addEventListener("DOMContentLoaded", () => {
            const fileInput = document.getElementById('xml-file-input');
            const transformBtn = document.getElementById('transform-btn');

            // Update file info when a file is selected
            fileInput.addEventListener('change', (e) => {
                const file = e.target.files[0];
                if (file) {
                    updateFileInfo(file);
                }
            });

            // Transform when button is clicked
            transformBtn.addEventListener('click', () => {
                const file = fileInput.files[0];
                if (file) {
                    transformXML(file);
                }
            });
        });
    </script>
</head>
<body>
    <div class="container">
        <a href="client-side.php" class="nav-link">View Default Project XML</a>
        <h1>Choose XML File to Transform</h1>
        
        <div class="file-selector">
            <div class="file-input-wrapper">
                <input type="file" id="xml-file-input" accept=".xml" />
                <button id="transform-btn">Transform XML</button>
            </div>
            <div id="file-info"></div>
        </div>

        <div id="project-info"></div>
    </div>
</body>
</html> 