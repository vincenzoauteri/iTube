//
//  Line+Underground.h
//  Underground
//
//  Created by Vincenzo Auteri on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Line.h"

@interface Line (Underground)

+(Line *) lineWithData:(NSDictionary *) dataDict inManagedObjectContext:(NSManagedObjectContext *) context;

+(void) resetStatusInManagedObjectContext:(NSManagedObjectContext *) context;

@end
