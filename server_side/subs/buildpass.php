<?php

// note some key variables are created and passed in from the calling script

set_include_path('/home/darren/www/apps.darrenbaptiste.com/pass');
require_once('PKPass.php');

$pass = new PKPass();

$pass->setCertificate('Certificate/subspass.p12'); // Set the path to your Pass Certificate (.p12 file)
$pass->setCertificatePassword('242hello'); // Set password for certificate
$pass->setWWDRcertPath('Certificate/AppleWorldwideDeveloperRelationsCertificationAuthority.pem');

error_log("lon: " . $lon . "  lat: " . $lat);

//Check if an error occured within the constructor
if($pass->checkError($error) == true) {
	exit('An error occured: '.$error);
}

$discount_value = strftime('%M');	// display the hour and minute to make the passes visually unique during testing
$address = 'This pass is good at all participating restaurants.';

if ($streetAddress)
{
	$address .= '\nWe have encoded this pass with a reminder for the Subs R Us shop located at ' . $streetAddress . '. ' .
				'Whenever you are close to the restaurant, this pass will present itself on the Lock Screen of your device.';
}

$pass->setJSON('{
  "formatVersion" : 1,
  "passTypeIdentifier" : "' . $passTypeIdentifier . '",
  "serialNumber" : "' . $serial_number .'",
  "teamIdentifier" : "3NQBX2AGK5",
  "webServiceURL" : "https://apps.darrenbaptiste.com/pass/pass_server.php",
  "authenticationToken" : "' . $authenticationToken .'",
  "suppressStripShine" : true,
  "barcode" : {
    "message" : "AnySub' . $discount_value . 'Off-20121007",
	"altText" : "' . $serial_number . '",
    "format" : "PKBarcodeFormatPDF417",
    "messageEncoding" : "iso-8859-1"
  },
  "locations" : [
    {
      "longitude" : ' . $lon . ',
      "latitude" : ' . $lat . '
    }
  ],
  "organizationName" : "Subs R Us",
  "logoText" : "Subs R Us",
  "description" : "Good food. Great value!",
  "foregroundColor" : "rgb(255, 0, 0)",
  "backgroundColor": "rgb(183, 179, 97)",
  "labelColor" : "rgb(0, 0, 0)",
  "coupon" : {
	"primaryFields" : [
	  {
	    "key" : "offer",
	    "label" : "",
	    "value" : ""
	  }
	],
    "auxiliaryFields" : [
		{
			"key" : "discount",
			"label" : "DISCOUNT",
			"value" : "'. $discount_value . '% off any foot-long sandwich"
		}
    ],
    "backFields" : [
      {
        "key" : "terms",
        "label" : "TERMS AND CONDITIONS",
        "value" : "BroadstreetMobile provides this pass, associated code and services free of charge, purely as a demonstration of the technology. No monetary value whatsoever is attached to this demonstration."
      },
		{
			"key" : "store_locations",
			"label" : "WHERE CAN I EAT?",
			"value" : "' . $address . '"
		}
    ]
  }
}');

// add files to the PKPass package
$pass->addFile('subs/icon.png');
$pass->addFile('subs/icon@2x.png');
$pass->addFile('subs/logo.png');
$pass->addFile('subs/strip.png');

// Create and output the PKPass
$pass->create(true);