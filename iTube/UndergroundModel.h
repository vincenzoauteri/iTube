//
//  UnderGroundModel.h
//  Underground
//
//  Created by Vincenzo Auteri on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UnderGroundModel : NSObject 

@property (nonatomic,strong) NSArray *lineArray;
-(void) initModel;
-(void) updateData;
-(UIColor *) colorForLineWithName:(NSString *) name;
@end
