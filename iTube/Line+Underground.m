//
//  Line+Underground.m
//  Underground
//
//  Created by Vincenzo Auteri on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Line+Underground.h"


@implementation Line (Underground)
+(Line *) lineWithData:(NSDictionary *)dataDict inManagedObjectContext:(NSManagedObjectContext *) context{
    
    Line *line = nil;
    //Check if line is already there
    int uniqueId = [[dataDict objectForKey:@"ID"] intValue];
    NSString *lineName =[dataDict objectForKey:@"Name"];
    //NSLog(@"Searching for name %@",lineName);
    //NSLog(@"uniqueId %d",uniqueId);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Line"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",lineName];
    request.predicate = [NSPredicate predicateWithFormat:@"lineId = %d",uniqueId];
    //Sort by id (although we should receive just one result at most)
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineId" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:descriptor];

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"matches %d",[matches count]);
    
    if (error || (matches == nil)|| [matches count] > 1) {
        NSLog(@"Error %@",[error description]);
        for (Line *line in matches) {
            [context deleteObject:line];
        }
        //[context reset];
    } else if (0 == [matches count]) {
        line =[NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:context];
        line.lineId = [dataDict objectForKey:@"ID"];
        //NSLog(@"Line added id %d",[line.lineId intValue]);
        line.name = [dataDict objectForKey:@"Name"];
        //NSLog(@"Line added name %@",line.name);
        line.status = [dataDict objectForKey:@"Description"];
        line.statusDetails = [dataDict objectForKey:@"StatusDetails"];
        //NSLog(@"Line added name %@",line.statusDetails);
    }
    else if (1 == [matches count]){
        line = [matches lastObject];
        //NSLog(@"Line found name %@",line.name);
        NSString *status =  [dataDict objectForKey:@"Description"]; 
        NSString *statusDetails =  [dataDict objectForKey:@"StatusDetails"]; 
        if(![line.status isEqualToString:status]) {
            line.status = [dataDict objectForKey:@"Description"];
        }
        if(![line.statusDetails isEqualToString:statusDetails]) {
            line.statusDetails = [dataDict objectForKey:@"StatusDetails"];
        }
    }
    return line;
}

+(void) resetStatusInManagedObjectContext:(NSManagedObjectContext *) context{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Line"];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"Reset matches %d",[matches count]);
    int totalMatches = [matches count];
    
    if (error || (matches == nil)) {
        NSLog(@"Error %@",[error description]);
    }
    
    else if (totalMatches > 0){
        int index;
        for (index =0;index<totalMatches;index++){
            Line *line = [matches objectAtIndex:index];
                NSLog(@"Resetting Line");
                line.status = @"Fetching data...";
                line.statusDetails = @"";
            }
    }
    
}

@end
