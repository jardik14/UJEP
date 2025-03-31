<!DOCTYPE html>
<html>
<head>
    <title>Project Information - Server Side Transformation</title>
    <meta charset="UTF-8">
</head>
<body>
    <?php
    try {
        // Load XML file
        $xml = new DOMDocument();
        $xml->load('xml/project.xml');
        
        // Load XSL file
        $xsl = new DOMDocument();
        $xsl->load('xml/project.xsl');
        
        // Create XSLT processor
        $xslt = new XSLTProcessor();
        
        // Import the XSL stylesheet
        $xslt->importStylesheet($xsl);
        
        // Transform XML
        $transXml = $xslt->transformToXml($xml);
        
        // Output the transformed XML
        echo $transXml;
        
    } catch (Exception $e) {
        // Error handling
        echo '<div style="color: red; padding: 20px; border: 1px solid red; margin: 20px;">';
        echo '<h2>Error occurred during transformation:</h2>';
        echo '<p>' . htmlspecialchars($e->getMessage()) . '</p>';
        echo '</div>';
        
        // Debug information
        if (ini_get('display_errors')) {
            echo '<div style="background: #f5f5f5; padding: 20px; margin: 20px;">';
            echo '<h3>Debug Information:</h3>';
            echo '<pre>';
            echo 'XML File exists: ' . (file_exists('xml/project.xml') ? 'Yes' : 'No') . "\n";
            echo 'XSL File exists: ' . (file_exists('xml/project.xsl') ? 'Yes' : 'No') . "\n";
            echo 'XSLT Extension loaded: ' . (extension_loaded('xsl') ? 'Yes' : 'No') . "\n";
            echo '</pre>';
            echo '</div>';
        }
    }
    ?>
</body>
</html>
