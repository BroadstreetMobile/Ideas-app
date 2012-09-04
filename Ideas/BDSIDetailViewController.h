//
//  BDSIDetailViewController.h
//  Ideas
//
//  Created by Darren Baptiste on 2012-09-04.
//  Copyright (c) 2012 BroadstreetMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDSIDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
