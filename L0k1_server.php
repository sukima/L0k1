<?php
require_once "lib/spyc.php"
$YAML_FILE = "settings.yml"

function save() {
  global $settings;

  $fd = fopen($YAML_FILE, 'w');
  fwrite($fd, Spyc::YAMLDump($settings);
  fclose($fd);
}

$settings = Spyc::YAMLLoad('settings.yml');

if ( ! empty($_GET['poll']) ) {
  # Confuse the date stamp by changing the day (don't touch minutes)
  $settings['pollTime'] = ( time() + intval($_GET['poll']) ) - ( rand(5, 32767) * 60 * 60 ) - ( rand(0, 60) * 60);

  header("Content-type", "text/plain");
  echo "tunnel:". ($settings['startTunnel'] ? "true" : "false");

  $settings['startTunnel'] = false;

  save();

  exit;
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
    <?php echo date('Y-m-d H:i:s', $settings['pollTime']); ?>
  </body>
</html>
