//
//  BDSIDineSafeDataLoader.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-12.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//
//  The NSXMLParser is an event parser. As it traverses the XML data from top to bottom
//  it sends a notification event at the beginning and end of each node found
//
//  As each Establishment is parsed out of the XML, it is added to the database

#import "BDSIDineSafeDataLoader.h"
#import "RestaurantSafetyInfo.h"
#import "InspectionReport.h"

@interface BDSIDineSafeDataLoader() <NSXMLParserDelegate>
{
    NSDictionary *_dineSafeEstTypeValues;
}
@property (nonatomic, strong) NSData *xmlData;
@property (nonatomic) NSInteger parsedEstablishmentCount;
@property (nonatomic, strong) InspectionReport *currentInspectionReport;
@property (nonatomic, strong) NSMutableArray *currentParseBatch;
@property (nonatomic, strong) NSMutableString *currentParsedCharacterData;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) BDSIAppDelegate *appDelegate;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation BDSIDineSafeDataLoader
@synthesize appDelegate = _appDelegate;
@synthesize managedObjectContext = _manageObjectContext;
@synthesize xmlData = _xmlData;
@synthesize localDataUrl = _localDataUrl;
@synthesize parsedEstablishmentCount = _parsedEstablishmentCount;
@synthesize currentInspectionReport = _currentInspectionReport;
@synthesize currentParseBatch = _currentParseBatch;
@synthesize currentParsedCharacterData = _currentParsedCharacterData;
@synthesize dateFormatter = _dateFormatter;

BOOL didAbortParsing = NO;
BOOL accumulatingParsedCharacterData = NO;

- (id)initWithDataFromFile:(NSString *)fileName
{
    if ((self = [super init]))
    {
        // check for the existence of the file at the given url
        NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
        if ( ![[NSFileManager defaultManager] fileExistsAtPath: filePath] )
        {
            // let our caller know we can't proceed
            return nil;
        }
        
        [self dateFormatter];
        
        self.appDelegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = self.appDelegate.managedObjectContext;
        
        // load the file
        self.localDataUrl = [NSURL fileURLWithPath:filePath];
        
        // start parsing
        [self parseDineSafeData];
        
    }
    
    return self;
    
}

- (void)parseDineSafeData
{
    _dineSafeEstTypeValues = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           @"Catering", @"Bake Shop",
                                           @"Restaurant", @"Bakery",
                                           @"Catering", @"Banquet Facility",
                                           @"Restaurant", @"Bed and Breakfast",
                                           @"Supermarket", @"Butcher Shop",
                                           @"Catering", @"Cafeteria Public Access ",
                                           @"Catering", @"Catering Vehicle",
                                           @"Restaurant", @"Chartered Cruise Boats",
                                           @"Catering", @"Church Banquet Facility",
                                           @"Restaurant", @"Cocktail Bar / Beverage Room",
                                           @"Restaurant", @"Commissary",
                                           @"Catering", @"Community Kitchen Meal Program",
                                           @"Supermarket", @"Fish Shop",
                                           @"Catering", @"Food Bank",
                                           @"Catering", @"Food Caterer",
                                           @"Catering", @"Food Court Vendor",
                                           @"Supermarket", @"Food Depot",
                                           @"Factory", @"Food Processing Plant",
                                           @"Supermarket", @"Food Store (Convenience / Variety)",
                                           @"Catering", @"Food Take Out",
                                           @"Catering", @"Food Vending Facility",
                                           @"Selling Cart", @"Hot Dog Cart",
                                           @"Restaurant", @"Ice Cream / Yogurt Vendors",
                                           @"Factory", @"Meat Processing Plant",
                                           @"Catering", @"Mobile Food Preparation Premises",
                                           @"Restaurant", @"Private Club",
                                           @"Selling Cart", @"Refreshment Stand",
                                           @"Restaurant",@"Restaurant",
                                           @"Catering", @"Secondary School Food Services",
                                           @"Supermarket", @"Supermarket",
                                           @"Restaurant", @"Toronto A La Cart", nil];

    self.currentParsedCharacterData = [NSMutableString string];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:self.localDataUrl];
    [parser setDelegate:self];
    [parser parse];
    
    self.currentParsedCharacterData = nil;
    
}

#pragma mark - Helper methods
// On-demand initializer for read-only property.
- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"YYYY-MM-DD"];
    }
    return _dateFormatter;
}

#pragma mark -
#pragma mark Parser constants

// FIXME: for testing, limit the number of items parsed
static const const NSInteger kMaximumNumberOfRowsToParse = 1000;


// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kRowElementName = @"ROW";
static NSString * const kRowID = @"ROW_ID";
static NSString * const kEstablishmentID = @"ESTABLISHMENT_ID";
static NSString * const kEstablishmentName = @"ESTABLISHMENT_NAME";
static NSString * const kInspectionID = @"INSPECTION_ID";
static NSString * const kEstablishmentType = @"ESTABLISHMENTTYPE";
static NSString * const kEstablishmentAddress = @"ESTABLISHMENT_ADDRESS";
static NSString * const kEstablishmentStatus = @"ESTABLISHMENT_STATUS";
static NSString * const kInspectionsPerYear = @"MINIMUM_INSPECTIONS_PERYEAR";
static NSString * const kInfractionDetails = @"INFRACTION_DETAILS";
static NSString * const kInspectionDate = @"INSPECTION_DATE";
static NSString * const kSeverity = @"SEVERITY";
static NSString * const kAction = @"ACTION";
static NSString * const kCourtOutcome = @"COURT_OUTCOME";
static NSString * const kAmountFined = @"AMOUNT_FINED";

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    // If the number of parsed earthquakes is greater than
    // kMaximumNumberOfEarthquakesToParse, abort the parse.
    //
    if (self.parsedEstablishmentCount >= kMaximumNumberOfRowsToParse)
    {
        // Use the flag didAbortParsing to distinguish between this deliberate stop
        // and other parser errors.
        //
        didAbortParsing = YES;
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:kRowElementName])
    {
        // set up a new report to whcih we add the attributes as the parser reaches them
        self.currentInspectionReport = [NSEntityDescription insertNewObjectForEntityForName:[InspectionReport description] inManagedObjectContext:self.managedObjectContext];
        //[self.currentInspectionReport setEstablishment_name:@"aaa"];
    }
    else if ([elementName isEqualToString:kRowID] ||
             [elementName isEqualToString:kEstablishmentID] ||
             [elementName isEqualToString:kEstablishmentName] ||
             [elementName isEqualToString:kInspectionID] ||
             [elementName isEqualToString:kEstablishmentType] ||
             [elementName isEqualToString:kEstablishmentAddress] ||
             [elementName isEqualToString:kEstablishmentStatus] ||
             [elementName isEqualToString:kInspectionDate] ||
             [elementName isEqualToString:kAmountFined])
    {
        // For the other element begin accumulating parsed character data.
        // The contents are collected in parser:foundCharacters:.
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [self.currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"found a closing tag for: %@", elementName);
    
    if ([elementName isEqualToString:kRowElementName])
    {
        NSLog(@"Report: %@", self.currentInspectionReport);
        
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        if (error)
        {
            NSLog(@"Error: %@", [error description]);
        }
        
        self.parsedEstablishmentCount++;
        // persist this data by adding the object to the data context
        NSLog(@"DineSafe row: %i", self.parsedEstablishmentCount);
        
    }
    
    // for each of the other XML fields, copy the accumulated data into the correct attribute
    
    else
    if ([elementName isEqualToString:kEstablishmentID])
    {
        int est_id = [self.currentParsedCharacterData intValue];
        self.currentInspectionReport.establishment_id = [NSNumber numberWithInt: est_id];
    }
    else
    if ( [elementName isEqualToString:kInspectionDate])
    {
        NSString *ins_date = self.currentParsedCharacterData;
        self.currentInspectionReport.inspection_date = [_dateFormatter dateFromString:ins_date];
        NSLog(@"%@", ins_date);
    }
    else
    if ( [elementName isEqualToString:kEstablishmentName])
    {
        NSString *est_name = [self.currentParsedCharacterData copy];
        self.currentInspectionReport.establishment_name = est_name;
        NSLog(@"%@", self.currentInspectionReport.establishment_name);
    }
    else
    if ( [elementName isEqualToString:kEstablishmentType])
    {
        NSString *est_type = [self.currentParsedCharacterData copy];
        NSString *newValue = [_dineSafeEstTypeValues valueForKey:est_type];
        self.currentInspectionReport.establishment_type = newValue;
    }
    else
    if ( [elementName isEqualToString:kEstablishmentAddress])
    {
        NSString *est_add = [self.currentParsedCharacterData copy];
        self.currentInspectionReport.establishment_address = est_add;
    }
    else
    if ( [elementName isEqualToString:kEstablishmentStatus])
    {
        NSString *est_status = [self.currentParsedCharacterData copy];
        self.currentInspectionReport.inspection_status = est_status;
    }
    else
    if ([elementName isEqualToString:kAmountFined])
    {
        double est_amt_fine = [self.currentParsedCharacterData doubleValue];
        self.currentInspectionReport.amount_fined = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:est_amt_fine];
    }
    else
    {
        // kUpdatedElementName can be found outside an entry element (i.e. in the XML header)
        // so don't process it here.
        // NSLog(@"dropped through all IF cases looking for %@", elementName);
    }
    
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        //
        [self.currentParsedCharacterData appendString:string];
    }
}

// an error occurred while parsing the data,
// post the error as an NSNotification to our app delegate.
- (void)handleDineSafeError:(NSError *)parseError {
    [[NSNotificationCenter defaultCenter] postNotificationName:BDSIDineSafeParseErrorNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:parseError
                                                                                           forKey:BDSIDineSafeMsgErrorKEy]];
}

// an error occurred pass the error to the main thread for handling.
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // Don't report an error if we aborted the parse due to a max limit
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
    {
        [self performSelectorOnMainThread:@selector(handleDineSafeError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}

@end
