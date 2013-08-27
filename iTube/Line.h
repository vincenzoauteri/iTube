//
//  Line.h
//  iTube
//
//  Created by Vincenzo Auteri on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Line : NSManagedObject

@property (nonatomic, retain) NSNumber * lineId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * statusDetails;

@end
