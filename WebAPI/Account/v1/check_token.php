<?php
// Include and Initialization
header('Content-Type: application/json');
include_once($_SERVER['DOCUMENT_ROOT']."/Secret/MySQL/config.php");

$Results = array();
$statuscode = array(
    1000 => "OK",
    1001 => "Token Not Found",
);

// Get the secret key from DB for decoding the API Token
require $_SERVER['DOCUMENT_ROOT']."/Secret/php-jwt/vendor/autoload.php";

use \Firebase\JWT\JWT;
$jwt = null;
$Table_ApplicationSetting = table_ApplicationSetting;
$SQL_CheckAppSetting = $conn->prepare("SELECT * FROM $Table_ApplicationSetting");
$SQL_CheckAppSetting->execute();

while($row = $SQL_CheckAppSetting->fetch()) {
    $Server_AppCode = $row['AppCode'];
}
$headers = apache_request_headers();

if (isset($headers['Authorization'])) {
    $authHeader =  $headers['Authorization'];
    $arr = explode(" ", $authHeader);
    $jwt = $arr[1];
} else if (isset($headers['authorization'])) {
    $authHeader =  $headers['authorization'];
    $arr = explode(" ", $authHeader);
    $jwt = $arr[1];
}

if($jwt){
    $Results = array();
    $Results["JWT"] = $jwt;
    try{
        $decoded = JWT::decode($jwt, $Server_AppCode, array('HS256'));
        http_response_code(200);
    } catch (Exception $e){
        http_response_code(401);
        exit;
    }
} else {
    http_response_code(401);
    $Results["StatusCode"] = $statuscode[1001];
    $JSON_result = json_encode($Results, JSON_PRETTY_PRINT);
    print_r($JSON_result);
    exit;
}
// Getting the API Token for Current User Setting End
?>