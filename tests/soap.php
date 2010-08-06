<?php 

$client = new SoapClient('http://delhaye.milizone.com/api/?wsdl');
// If soap isn't default use this link instead
// http://youmagentohost/api/soap/?wsdl
 
// If somestuff requires api authentification,
// we should get session token
$session = $client->login('admin', 'secret09');
#print_r($session);

#print_r($client->call($session, 'category.tree'));

print_r($client->call($session, 'category.info', 2));


#$result = $client->call($session, 'category.create', array (2, array ('name' => 'titi', 'available_sort_by'=> 'name', 'default_sort_by' => 'name', 'is_active'=>'1')));
#print_r ($result);

#php -r '$client = new SoapClient("http://delhaye.milizone.com/api/?wsdl"); $client->call("e218d971ce8af8e0d495fff31d9d6aab", "category.create", array (2, array ("name" => "titi")));'
?>