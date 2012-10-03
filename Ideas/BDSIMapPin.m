//
//  BDSIMapPin.m
//  Ideas
//
//  Created by Darren Baptiste on 2012-10-02.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import "BDSIMapPin.h"

@implementation BDSIMapPin
@synthesize placemark = _placemark;

#pragma mark - MKAnnotation Protocol

- (CLLocationCoordinate2D)coordinate
{
    return self.placemark.location.coordinate;
}

- (NSString *)title
{
    return self.placemark.thoroughfare;
}

@end
