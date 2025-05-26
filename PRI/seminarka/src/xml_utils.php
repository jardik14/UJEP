<?php
declare(strict_types=1);

/**
 * Validate an XML file against an XSD schema.
 *
 * @param string $xmlPath Absolute path to the XML document.
 * @param string $xsdPath Absolute path to the XSD schema.
 * @return bool           true = valid, false = invalid
 * @throws RuntimeException if the XML cannot be loaded.
 */
function validateXml(string $xmlPath, string $xsdPath): bool
{
    libxml_use_internal_errors(true);

    $dom = new DOMDocument();
    if (!$dom->load($xmlPath)) {
        throw new RuntimeException("Cannot load XML: $xmlPath");
    }

    $isValid = $dom->schemaValidate($xsdPath);
    if (!$isValid) {
        // Volitelně: vypsat chyby do logu
        foreach (libxml_get_errors() as $err) {
            error_log(trim($err->message));
        }
    }
    libxml_clear_errors();
    return $isValid;
}
