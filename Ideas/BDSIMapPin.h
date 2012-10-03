//
//  BDSIMapPin.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-10-02.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BDSIMapPin : NSObject <MKAnnotation>
@property (nonatomic, strong) CLPlacemark *placemark;

@end
