<?php
/** pass_server.php
 *	
 *	Format: curl -i -X GET http://pkpasses.local/index.php/hello/jenny
 *
 *	Initalize the web services for handling pass management
 *
 *	Formats expected:
 *
 *	Device Registration
 * 	POST version/devices/deviceLibraryIdentifier/registrations/passTypeIdentifier/serialNumber
 *
 *	Serial Numbers for Passes on a Device
 *	GET version/devices/deviceLibraryIdentifier/registrations/passTypeIdentifier?passesUpdatedSince=tag
 *
 *	Latest Version of a Pass
 *	GET version/passes/passTypeIdentifier/serialNumber
 *
 *	Unregister a device
 *	DELETE version/devices/deviceLibraryIdentifier/registrations/passTypeIdentifier/serialNumber
 *
 *	Error logging
 *	POST version/log
 */

set_include_path('/home/darren/www/apps.darrenbaptiste.com/pass/Slim/Slim');

require 'Slim.php';

\Slim\Slim::registerAutoloader();
$app = new \Slim\Slim();

// define routings //

// pass create
$app->get('/create/:lon/:lat/:address', 'createPass');

// pass management - calls from within Passbook
$app->post('/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber', 'registerDevice');
$app->get('/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier?passesUpdatedSince=:tag', 'showSerials');
$app->get('/v1/passes/:passTypeIdentifier/:serialNumber', 'showPasses');
$app->delete('/v1/devices/:deviceLibraryIdentifier/registrations/:passTypeIdentifier/:serialNumber', 'unregisterDevice');
$app->post('/v1/log', 'logInfo');

$app->run();

// define web services

// CreatePass
//	Called by the Passbook demo inside the BDSI Ideas app
// 	Create a new pass for the Subs R Us chain using a demo address of the user's current location
function createPass($lon, $lat, $streetAddress)
{				
	// determine the key variables which will be used to build the pass
	$serial_number = time();	// use a timestamp to get a unique serial_number
	$discount_value = strftime('%M');	// display the hour and minute to make the passes visually unique during testing
	$passTypeIdentifier = "pass.com.broadstreetmobile.ideas.subspass";
	$authenticationToken = uniqid('', true);
	
	// persist them in the database
	$sql = "INSERT INTO passes( `serial_number`, `authentication_token`, `pass_type_id`) VALUES(:serialNumber, :authToken, :passTypeID)";
	try 
	{
		$db = getConnection();
		$stmt = $db->prepare($sql);  
		$stmt->bindParam("serialNumber", $serial_number);
		$stmt->bindParam("authToken", $authenticationToken);
		$stmt->bindParam("passTypeID", $passTypeIdentifier);
		$stmt->execute();
		
		$pass_entry_id = $db->lastInsertId();
		$db = null;
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
	
	// run the code to build and deliver a pass down to the device
	// buildpass.php relies on the variables set earlier in this function
	include "subs/buildpass.php";
}

# Registration
# register a device to receive push notifications for a pass
#
# POST /v1/devices/<deviceID>/registrations/<typeID>/<serial#>
# Header: Authorization: ApplePass <authenticationToken>
# JSON payload: { "pushToken" : <push token, which the server needs to send push notifications to this device> }
#
# Params definition
# :device_id      - the device's identifier
# :pass_type_id   - the bundle identifier for a class of passes, sometimes refered to as the pass topic, e.g. pass.com.apple.backtoschoolgift, registered with WWDR
# :serial_number  - the pass' serial number
# :pushToken      - the value needed for Apple Push Notification service
#
# server action: if the authentication token is correct, associate the given push token and device identifier with this pass
# server response:
# --> if registration succeeded: 201
# --> if this serial number was already registered for this device: 304
# --> if not authorized: 401

function registerDevice($deviceID, $passTypeIdentifier, $serialNumber)
{
	error_log('registerDevice command called ');

	global $app;
	
	$request = $app->request();
	$body = $request->getBody();
	$payload = json_decode($body, true);
	$pushToken = $payload['pushToken'];

	/*
	// retrieve then test the 'ApplePass' authToken
	$authToken = preg_replace("|ApplePass |", "", $_SERVER["HTTP_AUTHORIZATION"]);
	
	$sql = "SELECT * FROM passes WHERE authentication_token LIKE :authToken AND serial_number LIKE :serialNumber";
	try {
		$db = getConnection();
		$stmt = $db->prepare($sql);
		$query = "%".$query."%";  
		$stmt->bindParam("authToken", $authToken);
		$stmt->bindParam("serialNumber", $serialNumber);
		$stmt->execute();
		$passes = $stmt->fetchAll(PDO::FETCH_OBJ);
		$db = null;
		
		if ( count($passes) == 0 )
		{
			// not authorized, log and redirect
			error_log("Authentication token given in request ($authToken) fails validation for Serial# $serialNumber");
			echo "ERROR: validation fails!<br/>\n";
			$app->response()->status(401);
		}
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
	*/
	
	testAuthorizationForSerialNumber($serialNumber);
	
	// build a uuid = device_id + '-' + serial_number
	$uuID = $deviceID + "-" + $serialNumber;
	
	// insert into db
	error_log("attempting to REGISTER a new device (insert into db)");
	
	$sql = "INSERT INTO registrations (uuid, device_id, push_token, serial_number, pass_type_id) VALUES (:uuID, :deviceID, :pushToken, :serialNumber, :passTypeID)";
	try 
	{
		$db = getConnection();
		$stmt = $db->prepare($sql);  
		$stmt->bindParam("uuID", $uuID);
		$stmt->bindParam("deviceID", $deviceID);
		$stmt->bindParam("pushToken", $pushToken);
		$stmt->bindParam("serialNumber", $serialNumber);
		$stmt->bindParam("passTypeID", $passTypeIdentifier);
		$stmt->execute();
		
		$device_entry_id = $db->lastInsertId();
		$db = null;
		echo json_encode($device_entry_id); 
	} catch(PDOException $e) {
		if ( $db->errorCode() == 23000 )
		{
			// if this is a duplicate entry, report a status of 304
			$app->response->status(304);
		}
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
		error_log('insert new registration error: ' . $e->getMessage());
	}
	
	// everything is okay
	$app->response()->status(201);
}

# Updatable passes
#
# get all serial #s associated with a device for passes that need an update
# Optionally with a query limiter to scope the last update since
# 
# GET /v1/devices/<deviceID>/registrations/<typeID>
# GET /v1/devices/<deviceID>/registrations/<typeID>?passesUpdatedSince=<tag>
#
# server action: figure out which passes associated with this device have been modified since the supplied tag (if no tag provided, all associated serial #s)
# server response:
# --> if there are matching passes: 200, with JSON payload: { "lastUpdated" : <new tag>, "serialNumbers" : [ <array of serial #s> ] }
# --> if there are no matching passes: 204
# --> if unknown device identifier: 404
#
#

function showSerials($devideID, $passTypeIdentifier, $tag)
{
	// get the tag $_SERVER['QUERY_STRING'] 
	// tag == last_updated timestamp
	error_log("call to showSerials for a device");
}

# Pass delivery
#
# GET /v1/passes/<typeID>/<serial#>
# Header: Authorization: ApplePass <authenticationToken>
#
# server response:
# --> if auth token is correct: 200, with pass data payload
# --> if auth token is incorrect: 401
#

function showPasses($passTypeIdentifier, $serialNumber)
{
	error_log("call to show Passes for a device");
}

# Unregister
#
# unregister a device to receive push notifications for a pass
# 
# DELETE /v1/devices/<deviceID>/registrations/<passTypeID>/<serial#>
# Header: Authorization: ApplePass <authenticationToken>
#
# server action: if the authentication token is correct, disassociate the device from this pass
# server response:
# --> if disassociation succeeded: 200
# --> if not authorized: 401

function unregisterDevice($deviceID, $passTypeIdentifier, $serialNumber)
{
	error_log("attempting to un-register a device with deviceID, passTypeID, serial of $deviceID, $passTypeIdentifier, $serialNumber");
	
	$sql = "DELETE FROM registrations WHERE device_id=:deviceID AND pass_type_id=:passTypeID AND serial_number=:serialNumber ";
	try 
	{
		$db = getConnection();
		$stmt = $db->prepare($sql);  
		$stmt->bindParam("deviceID", $deviceID);
		$stmt->bindParam("passTypeID", $passTypeIdentifier);
		$stmt->bindParam("serialNumber", $serialNumber);
		$stmt->execute();
		$db = null;
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
		error_log('un-register error: ' . $e->getMessage());
	}
	$app->response()->status(200);
}


function logInfo()
{
	error_log('log info sent');
	global $app;
	
	$request = $app->request();
	$body = $request->getBody();
	$payload = json_decode($body, true);
	
	error_log('log message ' . $payload['logs']);
	
	$app->response()->status(200);
}

// helper functions
function getConnection() 
{
	// $link = mysql_connect('localhost','darren_puser','I1EUaW1hsWBHSHnn7') or die('Cannot connect to the DB');
	// mysql_select_db('darren_pkpass',$link) or die('Cannot select the DB');
	
	$dbhost="localhost";
	$dbuser="darren_puser";
	$dbpass="I1EUaW1hsWBHSHnn7";
	$dbname="darren_pkpass";
	$dbh = new PDO("mysql:host=$dbhost;dbname=$dbname", $dbuser, $dbpass);	
	$dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	return $dbh;
}

function testAuthorizationForSerialNumber($serialNumber)
{
	error_log("testing authorization");
	
	global $app;
	
	$authorized = false;
	
	// retrieve then test the 'ApplePass' authToken
	$authToken = preg_replace("|ApplePass |", "", $_SERVER["HTTP_AUTHORIZATION"]);
	
	$sql = "SELECT * FROM passes WHERE authentication_token LIKE :authToken AND serial_number LIKE :serialNumber";
	try {
		$db = getConnection();
		$stmt = $db->prepare($sql);
		$query = "%".$query."%";  
		$stmt->bindParam("authToken", $authToken);
		$stmt->bindParam("serialNumber", $serialNumber);
		$stmt->execute();
		$passes = $stmt->fetchAll(PDO::FETCH_OBJ);
		$db = null;
		
		if ( count($passes) > 0 )
		{
			$authorized = true;
		}
		else
		{
			error_log("Authentication token given in request ($authToken) fails validation for Serial# $serialNumber");
			echo "ERROR: validation fails!<br/>\n";
			$app->response()->status(401);	
		}
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
	
	return $authorized;
}
?>