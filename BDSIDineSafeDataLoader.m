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
@property (nonatomic, strong) NSData *xmlData;
@property (nonatomic) NSInteger parsedEstablishmentCount;
@property (nonatomic, strong) InspectionReport *currentInspectionReport;
@property (nonatomic, strong) NSMutableArray *currentParseBatch;
@property (nonatomic, strong) NSMutableString *currentParsedCharacterData;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) BDSIAppDelegate *appDelegate;
@property (nonatomic) NSManagedObjectContext *manageObjectContext;
@end

@implementation BDSIDineSafeDataLoader
@synthesize appDelegate = _appDelegate;
@synthesize manageObjectContext = _manageObjectContext;
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
        
        self.appDelegate = [[UIApplication sharedApplication] delegate];
        self.manageObjectContext = self.appDelegate.managedObjectContext;
        
        // load the file
        self.localDataUrl = [NSURL fileURLWithPath:filePath];
        
        // start parsing
        [self parseDineSafeData];
    }

    return self;

}

- (void)parseDineSafeData
{
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
    if (self.dateFormatter == nil) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return self.dateFormatter;
}

#pragma mark -
#pragma mark Parser constants

// FIXME: for testing, limit the number of items parsed
static const const NSInteger kMaximumNumberOfRowsToParse = 50;


// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kRowElementName = @"ROW";
static NSString * const kRowID = @"ROW_ID";
static NSString * const kEstablishmentID = @"ESTABLISHMENT_ID";
static NSString * const kEstablishmentName = @"establishment_name";
static NSString * const kInspectionID = @"inspection_id";
static NSString * const kEstablishmentType = @"establishmenttype";
static NSString * const kEstablishmentAddress = @"establishment_address";
static NSString * const kEstablishmentStatus = @"establishment_status";
static NSString * const kInspectionsPerYear = @"minimum_inspections_peryear";
static NSString * const kInfractionDetails = @"infraction_details";
static NSString * const kInspectionDate = @"INSPECTION_DATE";
static NSString * const kSeverity = @"severity";
static NSString * const kAction = @"action";
static NSString * const kCourtOutcome = @"court_outcome";
static NSString * const kAmountFined = @"amount_fined";

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
        self.currentInspectionReport = [NSEntityDescription insertNewObjectForEntityForName:[InspectionReport description] inManagedObjectContext:self.manageObjectContext];
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
        [self.manageObjectContext save:nil];
        
        [self.currentParseBatch addObject:self.currentInspectionReport];
        // add this report to the data context
        
        self.parsedEstablishmentCount++;
        // persist this data by adding the object to the data context
        NSLog(@"DineSafe row: %i", self.parsedEstablishmentCount);
        
    }
    
    // for each of the other XML fields, copy the accumulated data into the correct attribute
    
    else
    if ([elementName isEqualToString:kEstablishmentID])
    {
        int est_id = [self.currentParsedCharacterData intValue];
        self.currentInspectionReport.establishment_id = [NSNumber numberWithInt:est_id];
    }
    else
    if ( [elementName isEqualToString:kInspectionDate])
    {
        self.currentInspectionReport.inspection_date = [NSDate date];   //[self.dateFormatter dateFromString:self.currentParsedCharacterData];
    }
    else
    {
        // kUpdatedElementName can be found outside an entry element (i.e. in the XML header)
        // so don't process it here.
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
