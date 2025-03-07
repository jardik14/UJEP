<? require __DIR__ . '/inc/start.php';
usrId() || redirect('login.php');
?>
<!DOCTYPE html>
<html lang="cs">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>XML Validátor</title>
  <link rel="icon" type="image/svg+xml" href="assets/logo.svg" />
  <link rel="stylesheet" href="css/main.css">
  <script src="js/main.js" defer></script>
</head>

<body>
  <header>
    <img src="assets/logo.svg" title="Logo" style="height: 100%;" class="ptr" onclick="location.href='index.php'">
    <a href="logout.php">Logout</a>
    <a href="home.php">Home</a>
    <?= usr() ?>
  </header>

  <main>
    <h1>XML Validátor</h1>
    <p>Nahrajte XML soubor, případně také DTD soubor.</p>
    <form enctype="multipart/form-data" method="POST">
      <table>
        <tr>
          <td>XML soubor:</td>
          <td><input type="file" name="xml" accept="text/xml" data-max-file-size="2M"></td>
        </tr>
        <tr>
          <td>DTD soubor:</td>
          <td><input type="file" name="dtd" data-max-file-size="2M"></td>
        </tr>
        <tr>
          <td></td>
          <td><input type="submit" value="Odeslat"></td>
        </tr>
      </table>
    </form>

    <?
    function printErrors() { ?>
      <table>
        <? foreach (libxml_get_errors() as $error) { ?>
          <tr>
            <td><?= $error->line ?></td>
            <td><?= $error->message ?></td>
          </tr>
        <? } ?>
      </table>
    <?
    }

    function validate($xmlPath, $dtdPath = '') {
      $doc = new DOMDocument;
      
      libxml_use_internal_errors(true);
      $doc->loadXML(file_get_contents($xmlPath));
      printErrors();
      libxml_use_internal_errors(false);

      @$root = $doc->firstElementChild->tagName;
      if ($root && $dtdPath) {
        $systemId = 'data://text/plain;base64,' . base64_encode(file_get_contents($dtdPath));
        echo "<p>Validuji podle DTD. Kořen: <b>$root</b></p>";
        
        $creator = new DOMImplementation;
        $doctype = $creator->createDocumentType($root, '', $systemId);
        $newDoc = $creator->createDocument(null, '', $doctype);
        $newDoc->encoding = "utf-8";
        
        $oldRootNode = $doc->getElementsByTagName($root)->item(0);
        $newRootNode = $newDoc->importNode($oldRootNode, true);
        
        $newDoc->appendChild($newRootNode);
        $doc = $newDoc;
      }

      libxml_use_internal_errors(true);
      $isValid = $doc->validate();
      printErrors();
      libxml_use_internal_errors(false);
      
      return $isValid;
    }

    $xmlFile = @$_FILES['xml'];
    $dtdFile = @$_FILES['dtd'];
    
    if ($xmlTmpName = @$xmlFile['tmp_name']) {
      $dtdTmpName = $dtdFile['tmp_name'];
      $isValid = validate($xmlTmpName, $dtdTmpName);
      if ($isValid) {
        echo "<p>Nahraný XML soubor je validní.</p>";
      }
    }
    ?>
  </main>

  <footer>
    &copy; KI/PRI
  </footer>
</body>

</html>
