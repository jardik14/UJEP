<?php
header('Content-Type: application/json');

try {
    // Get all XML files from the xml directory
    $xmlFiles = glob('xml/*.xml');
    
    // Create an array of file information
    $files = array_map(function($file) {
        return [
            'name' => basename($file),
            'path' => $file,
            'size' => filesize($file),
            'modified' => date('Y-m-d H:i:s', filemtime($file))
        ];
    }, $xmlFiles);
    
    // Return the list of files
    echo json_encode([
        'success' => true,
        'files' => $files
    ]);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} 