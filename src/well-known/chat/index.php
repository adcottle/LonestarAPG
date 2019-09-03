<?php

require_once dirname(__FILE__)."/src/phpfreechat.class.php";
$params = array();
$params["title"] = "LSCAPG Chat";
$params["nick"] = "guest".rand(1,1000);  // setup the intitial nickname
$params["serverid"] = md5(__FILE__); // calculate a unique id for this chat
$params["max_channels"] = 1;
$params["max_msg"] = 100;
$params['admins'] = array('Debbie_Wayne' => 'lsc9apg2');
//$params["debug"] = true;
$chat = new phpFreeChat( $params );
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
 <head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <title>LSCAPG - phpFreeChat</title>
  <link rel="stylesheet" title="classic" type="text/css" href="style/generic.css" />
  <link rel="stylesheet" title="classic" type="text/css" href="style/header.css" />
  <link rel="stylesheet" title="classic" type="text/css" href="style/footer.css" />
  <link rel="stylesheet" title="classic" type="text/css" href="style/menu.css" />
  <link rel="stylesheet" title="classic" type="text/css" href="style/content.css" />  
 </head>
 <body>

<div class="header">
      <h1>LSCAPG - phpFreeChat</h1>
</div>

<div class="menu">
      <ul>
            <!--
        <li class="sub title">General</li>
        <li>
          <ul class="sub">
            <li class="item">
              <a href="admin/">Administration</a>
            </li>
            -->
          </ul>
        </li>
        <li class="sub title">Documentation</li>
        <li>
          <ul>
            <li class="item">
              After login please set your name using: <br />
              <big><b>/nick your_name</b></big><br />
               A max of 15 characters is allowed.
            </li>
            <li class="item"><br /><br />
              Type text in the one-line text bar near the bottom of the screen (a limit of 400 characters per message is in effect)
            </li>
            <li class="item"><br /><br />
              Send the text by clicking <b>SEND</b> or pressing the <b>ENTER</b> key
            </li>
            <li class="item"><br /><br />
              When entering text you can highlight a phrase then click on <big><b>B</b></big>old, <big><b>I</b></big>talics, <big><b>U</b></big>nderline, <big><b>S</b></big>trikethrough, or <big><b>C</b></big>olor (and pick a color); or you can add a smiley by clicking the image
            </li>
            <li class="item"><br /><br />
              <b>/clear</b> - will clear the chat window
            </li>
            <li class="item"><br /><br />
              <b>/quit</b> - will exit the chat session
            </li>
            </li>
          </ul>
        </li>
      </ul>
      <p class="partner">
        <a href="http://www.phpfreechat.net"><img alt="phpfreechat.net" src="style/logo_88x31.gif" /></a><br/>
      </p>
</div>

<div class="content">
  <?php $chat->printChat(); ?>
</div>

</body></html>
