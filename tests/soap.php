<?php 

$client = new SoapClient('http://delhaye.milizone.com/api/?wsdl');
// If soap isn't default use this link instead
// http://youmagentohost/api/soap/?wsdl
 
// If somestuff requires api authentification,
// we should get session token
$session = $client->login('admin', 'secret09');
print_r($session);
 
$result = $client->call($session, 'category.create', array (2, array ('name' => 'titi')));
print_r ($result);
?>