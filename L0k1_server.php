<?php
require_once "lib/spyc.php";
require_once "lib/ga4php.php";

$YAML_FILE = "settings.yml";

function save() {
  global $settings, $YAML_FILE;

  $fd = fopen($YAML_FILE, 'w');
  fwrite($fd, Spyc::YAMLDump($settings));
  fclose($fd);
}

class MyGoogleAuth extends GoogleAuthenticator {
  function getData($user) {
    global $settings;
    return $settings['gaData'];
  }

  function putData($user, $data) {
    global $settings;
    $settings['gaData'] = $data;
    return true;
  }

  function getUsers() { }
}

$defaults = array (
  'startTunnel' => false,
  'pollTime' => 0,
  'gaData' => ""
);
$settings = Spyc::YAMLLoad('settings.yml');
$settings = array_merge($defaults, $settings);
$ga = new MyGoogleAuth();
$gaResult = "";

// $settings['lastUpdate'] = time();
// save();

if ( ! empty($_GET['poll']) ) {
  // Confuse the date stamp by changing the day (don't touch minutes)
  $poll = intval($_GET['poll']);
  if ($poll != 0) {
    $settings['pollTime'] = ( time() + $poll ) - ( rand(5, 32767) * 60 * 60 ) - ( rand(0, 60) * 60);
  } else {
    $settings['pollTime'] = 0;
  }

  header("Content-type", "text/plain");
  echo "tunnel:". ($settings['startTunnel'] ? "true" : "false");

  $settings['startTunnel'] = false;

  save();

  exit;
} elseif ( ! empty($_GET['ga']) ) {
  if ( $ga->authenticateUser("", $_GET['ga']) ) {
    $settings['startTunnel'] = true;
    save();
    $gaResult = "<span style=\"color:green;\">:)</span>";
  } else {
    $gaResult = "<span style=\"color:red;\">:(</span>";
  }
}
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <title>L0k1</title>
    <meta http-equiv="Content-type" content="text/html; charset=iso-8859-1" />
    <meta http-equiv="Content-Language" content="en-us" />
  </head>
  <body>
    <p><?php echo $gaResult; ?></p>
    <p><?php echo date('Y-m-d H:i:s', $settings['pollTime']); ?></p>
    <?php
      if ( empty($settings['gaData']) ) {
        $gaKey = $ga->setUser("x");
        $gaUrl = $ga->createUrl("x");
        save();
        echo "<p>$gaKey</p>\n";
        echo "<p><img src=\"$gaUrl\" /></p>\n";
      }
    ?>
  </body>
</html>