//
//  BDSIDineSafeDataLoader.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//
//  This class is used to load the database with info from an XML file
//  We only need this to happen once in the lifetime of the typical app,
//  but we will check each time to be sure there is no other data before our load
//
//  The process:
//      - open the XML file
//      - loop through all of the data nodes
//      - add content from specified fields to the database
//
//  Parameters: XML file (source)
//
//  It is expected that this will be run on a background thread,
//  kicked off during the first run of the application

//  A notification is posted if we encounter fatal errors during the parse
//
/* Format of the DineSafe XML
 <ROW>
     <ROW_ID>3</ROW_ID>
     <ESTABLISHMENT_ID>9005101</ESTABLISHMENT_ID>
     <INSPECTION_ID>102603599</INSPECTION_ID>
     <ESTABLISHMENT_NAME>ETOBICOKE SCHOOL OF THE ARTS</ESTABLISHMENT_NAME>
     <ESTABLISHMENTTYPE>Secondary School Food Services</ESTABLISHMENTTYPE>
     <ESTABLISHMENT_ADDRESS>675 ROYAL YORK RD </ESTABLISHMENT_ADDRESS>
     <ESTABLISHMENT_STATUS>Conditional Pass</ESTABLISHMENT_STATUS>
     <MINIMUM_INSPECTIONS_PERYEAR>2</MINIMUM_INSPECTIONS_PERYEAR>
     <INFRACTION_DETAILS>USE TOWEL NOT IN GOOD REPAIR FOR CLEANING TABLES O. REG  562/90 SEC. 62(A)</INFRACTION_DETAILS>
     <INSPECTION_DATE>2011-10-12</INSPECTION_DATE>
     <SEVERITY>S - Significant</SEVERITY>
     <ACTION>Corrected During Inspection</ACTION>
     <COURT_OUTCOME> </COURT_OUTCOME>
     <AMOUNT_FINED> </AMOUNT_FINED>
 </ROW>
 */

#import <Foundation/Foundation.h>

#define BDSIDineSafeParseErrorNotification @"BDSIDineSafeParseErrorNotification"
#define BDSIDineSafeMsgErrorKEy @"BDSIDineSafeMsgErrorKey"

@interface BDSIDineSafeDataLoader : NSObject
@property (nonatomic, strong) NSURL *localDataUrl;

- (id)initWithDataFromFile:(NSString *)fileName;

@end
