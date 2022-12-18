<?php
error_reporting(E_ERROR | E_PARSE);

// Response object structure
$response = new stdClass;
$response->status = null;
$response->message = null;
$response->filename = null;
$response->filedest = null;
$response->target = null;

// Uploading file
$destination_dir = $_SERVER['DOCUMENT_ROOT']."/"."uploads/" . $_POST['coursefolder'] . '/' . $_POST['unitfolder'] . '/' . $_POST['foldername'] . '/';
$path_info = mb_pathinfo($destination_dir.$_FILES["file"]["name"]);

$base_filename = str_replace(",","_",$path_info['filename']);
$base_fileext = $path_info['extension'];
$target_file = $destination_dir . $base_filename . '.' . $base_fileext;

if (!file_exists($destination_dir)) {
    mkdir($destination_dir, 0755, true);
}

if(file_exists($target_file)){
    $base_filename = $base_filename . '_' . intval(time() / rand(100,10000000)) . '.' .$base_fileext;
    $target_file = $destination_dir . $base_filename;
} else {
    $base_filename = $base_filename . '.' .$base_fileext;
    $target_file = $destination_dir . $base_filename;
}

$response->filename = $base_filename;
$response->filedest = $destination_dir;
$response->target = $target_file;

if(!$_FILES["file"]["error"])
{
    if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {        
        $response->status = true;
        $response->message = "File uploaded successfully";
    } else {
        $response->status = false;
        $response->message = "File uploading failed";
    }    
} 
else
{
    $response->status = false;
    $response->message = $_FILES["file"]["error"];
}

header('Content-Type: application/json');
echo json_encode($response);

function mb_pathinfo($filepath) {
    preg_match('%^(.*?)[\\\\/]*(([^/\\\\]*?)(\.([^\.\\\\/]+?)|))[\\\\/\.]*$%im',$filepath,$m);
    if($m[1]) $ret['dirname']=$m[1];
    if($m[2]) $ret['basename']=$m[2];
    if($m[5]) $ret['extension']=$m[5];
    if($m[3]) $ret['filename']=$m[3];
    return $ret;
}
?>