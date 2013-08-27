//
//  UnderGroundModel.m
//  Underground
//
//  Created by Vincenzo Auteri on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UnderGroundModel.h"
#import <CoreData/CoreData.h>
#import "Line.h"

@interface UnderGroundModel() <NSXMLParserDelegate>
@property (nonatomic,strong) NSXMLParser *parser;
@property (nonatomic,strong) NSURL *rssDataSource;
@property (nonatomic,strong) UIManagedDocument *document;
@property (nonatomic,strong) NSMutableDictionary *tempLine;
@property (nonatomic,strong) NSMutableArray *tempArray;
@property (nonatomic,strong) NSDictionary *colorDict;
@property (nonatomic) int lineOrder;
@end

@implementation UnderGroundModel

@synthesize document=_document;
@synthesize parser=_parser;
@synthesize rssDataSource =_rssDataSource;
@synthesize lineArray = _lineArray;
@synthesize tempLine = _tempLine;
@synthesize tempArray = _tempArray;
@synthesize colorDict  = _colorDict;
@synthesize lineOrder = _lineOrder;

-(void) updateData
{
    [self.parser parse];
}




-(void) initModel
{
    self.rssDataSource = [NSURL URLWithString:@"http://cloud.tfl.gov.uk/TrackerNet/LineStatus"];
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:self.rssDataSource];
    [self.parser setDelegate:self];
    
    self.colorDict =[NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithRed:0.537 green:0.305 blue:0.141 alpha:1.0],@"Bakerloo",
                          [UIColor colorWithRed:0.862 green:0.141 blue:0.121 alpha:1.0],@"Central",
                          [UIColor colorWithRed:1.0   green:0.807 blue:0.160 alpha:1.0],@"Circle",
                          [UIColor colorWithRed:0.0   green:0.447 blue:0.160 alpha:1.0],@"District",
                          [UIColor colorWithRed:0.843 green:0.6   blue:0.686 alpha:1.0],@"Hammersmith and City",
                          [UIColor colorWithRed:0.525 green:0.560 blue:0.596 alpha:1.0],@"Jubilee",
                          [UIColor colorWithRed:0.458 green:0.062 blue:0.337 alpha:1.0],@"Metropolitan",
                          [UIColor colorWithRed:0.0   green:0.0   blue:0.0   alpha:1.0],@"Northern",
                          [UIColor colorWithRed:0.0   green:0.098 blue:0.658 alpha:1.0],@"Piccadilly", 
                          [UIColor colorWithRed:0.0   green:0.627 blue:0.886 alpha:1.0],@"Victoria", 
                          [UIColor colorWithRed:0.462 green:0.815 blue:0.741 alpha:1.0],@"Waterloo and City", 
                          [UIColor colorWithRed:0.909 green:0.415 blue:0.627 alpha:1.0],@"Overground", 
                          [UIColor colorWithRed:0.0   green:0.686 blue:0.678 alpha:1.0],@"DLR", 
                          nil];
}

-(NSMutableArray *) tempArray
{
    if (!_tempArray)
    {
        _tempArray = [[NSMutableArray alloc] init ];
    }
    return _tempArray;
}


-(NSArray *) lineArray
{
    if (!_lineArray)
    {
        _lineArray = [[NSMutableArray alloc] init ];
    }
    return _lineArray;
}

-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:@"ArrayOfLineStatus"])
    {
        self.tempArray  = [[NSMutableArray alloc] init];
    }
    
    if ([elementName isEqualToString:@"LineStatus"])
    {
        self.tempLine = [[NSMutableDictionary alloc] init];
        
        
        NSString *statusDetails = [NSString stringWithString:[attributeDict valueForKey:@"StatusDetails"]];
        if (statusDetails)
        {                        
            [self.tempLine setObject:[NSString stringWithString:statusDetails] forKey:@"StatusDetails"];
        }

    }
    
    if ([elementName isEqualToString:@"Line"])
    {        
        NSString *lineName = [NSString stringWithString:[attributeDict valueForKey:@"Name"]];
        if (lineName)
        {
            [self.tempLine setObject:[NSNumber numberWithInt:self.lineOrder] forKey:@"ID"];
            [self.tempLine setObject:[NSString stringWithString:lineName] forKey:@"Name"];
            self.lineOrder++;
        }
    }
    else if([elementName isEqualToString:@"Status"])
    {
        NSString *lineStatusDescription = [NSString stringWithString:[attributeDict valueForKey:@"Description"]];
        if (lineStatusDescription)
        {
            [self.tempLine setObject:[NSString stringWithString:lineStatusDescription] forKey:@"Description"];
        }
    }
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"ArrayOfLineStatus"])
    {
        //NSLog (@"Parsed Array %@",[self.tempArray description]);
        self.lineArray =[NSArray arrayWithArray:[self.tempArray copy]];
        self.lineOrder = 0;
        self.tempArray = nil;
    }
    
    if ([elementName isEqualToString:@"LineStatus"])
    {
        [self.tempArray addObject:self.tempLine];
       // NSLog (@"Parsed Line %@",[self.tempArray description]);
        self.tempLine= nil;
    }
    
}



-(void) parserDidStartDocument:(NSXMLParser *)parser
{
    
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
   // NSLog (@"Parsed Array %@",[self.lineArray description]);
}

-(UIColor *) colorForLineWithName:(NSString *) name
{
    UIColor *returnColor = [self.colorDict objectForKey:name];
    if (!returnColor)
    {
        returnColor = [UIColor whiteColor];
    }
    return returnColor;
}


@end
