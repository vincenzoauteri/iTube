//
//  LineStatusViewController.h
//  iTube
//
//  Created by Vincenzo Auteri on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineStatusViewController : UIViewController
@property (nonatomic,strong) NSString *lineName; 
@property (nonatomic,strong) UIColor *lineColor; 
@property (nonatomic,strong) NSString *lineStatus; 
@property (nonatomic,strong) NSString *lineStatusDetails; 
@end
