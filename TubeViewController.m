//
//  TubeViewController.m
//  iTube
//
//  Created by Vincenzo Auteri on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TubeViewController.h"
#import "UndergroundModel.h"
#import "Line+Underground.h"
#import "LineStatusViewController.h"
#import <iAd/ADBannerView.h>

@interface TubeViewController () <ADBannerViewDelegate>
@property (nonatomic,strong) UnderGroundModel *model;
@property (nonatomic,strong) NSArray *lineArray;
@property (strong,nonatomic) NSTimer *refreshTimer;
@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;
@property (nonatomic) BOOL newData;
@end

@implementation TubeViewController

@synthesize document = _document;
@synthesize lineArray = _lineArray;
@synthesize model = _model;
@synthesize refreshTimer = _refreshTimer;
@synthesize adBannerView = _adBannerView;
@synthesize newData = _newData;


-(void) fetchDataIntoDocument:(UIManagedDocument *) document
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
        [document.managedObjectContext performBlock:^{
            for (NSDictionary *lineDict in self.lineArray) {
                //NSLog(@"Dict to store %@",[lineDict description]);
                [Line lineWithData:lineDict inManagedObjectContext:document.managedObjectContext];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.document.fileURL.path])
            {
                [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {  
                }];        
            }
        }];
    });
    
}
-(NSArray *) lineArray 
{
    if (!_lineArray)
    {
        _lineArray = [[NSArray alloc] init];
    }
    return _lineArray;
}

-(void) setLineArray:(NSArray *)lineArray
{
    if(![_lineArray isEqualToArray:lineArray])
    {
        //NSLog(@"Old %@",[_lineArray description]);
        //NSLog(@"New %@",[lineArray description]);
        _lineArray = [NSArray arrayWithArray:lineArray];
        //[self fetchDataIntoDocument:self.document];
    }
    [self initAndFetchResultController];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) setupFetchedResultController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Line"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lineId" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] 
                                     initWithFetchRequest:request 
                                     managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
        [self.document.managedObjectContext performBlock:^{
        [Line resetStatusInManagedObjectContext:self.document.managedObjectContext];
    }];
    });
}


-(void) initAndFetchResultController
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
        [self.document.managedObjectContext performBlock:^{
                    [self fetchDataIntoDocument:self.document];
                 }];
        });
}

-(void) useDocument 
{  
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.document.fileURL.path])
    {
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {  
            [self setupFetchedResultController];
        }];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.document openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultController];
        }];
    } else if (self.document.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self setupFetchedResultController];
    }
}

-(void) setDocument:(UIManagedDocument *)document
{
    if (_document !=document)
    {
        _document = document;
        //Fetch the document object 
        [self useDocument];
    }
}

- (void) updateData{
    
    static int counter =0;
    NSLog(@"Timer fired %d times",counter++);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
        [self.model updateData];
        self.lineArray = self.model.lineArray;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
            self.lineArray = self.model.lineArray;
        });
    });
    
}

-(UnderGroundModel *) model 
{
    if (!_model)
    {
        _model = [[UnderGroundModel alloc] init];
    }
    return _model;
}

-(void) updateData:(NSTimer *)timer
{
    [self updateData];
}
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.adBannerView.hidden = YES;
    [self.adBannerView setDelegate:self];
    [self.model initModel];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setAdBannerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.refreshTimer invalidate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.document) {  // for demo purposes, we'll create a default database if none is set
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Tube Database"];
        // url is now "<Documents Directory>/Default Photo Database"
        //NSLog(@"URL :%@",[url description]);
        self.document = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateData:) userInfo:nil repeats:YES];
    [self updateData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Lines Status Cell"];
    
    Line *line = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UIColor *color = [self.model colorForLineWithName:line.name];
    
    CGRect cellContentFrame= cell.contentView.frame;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(cellContentFrame.origin.x, cellContentFrame.origin.y, cellContentFrame.size.width ,cellContentFrame.size.height)];
    
    CGRect cellBackgroundFrame= backgroundView.frame;
    
    UIView *nameBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(cellBackgroundFrame.origin.x, cellBackgroundFrame.origin.y, cellBackgroundFrame.size.width*3/5 ,cellBackgroundFrame.size.height)];
    
    CGRect nameFrame= nameBackgroundView.frame;
    
    UIView *statusBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(nameFrame.size.width, nameFrame.origin.y, cellBackgroundFrame.size.width - nameFrame.size.width, nameFrame.size.height)];
    
    nameBackgroundView.backgroundColor = color;
    statusBackgroundView.backgroundColor = [UIColor whiteColor];
    [backgroundView addSubview:nameBackgroundView];
    [backgroundView addSubview:statusBackgroundView];
    
    cell.backgroundView = backgroundView;
    cell.textLabel.backgroundColor =  color;
    
    cell.textLabel.textColor =  [UIColor whiteColor];
    
    cell.textLabel.text = [NSString stringWithString:line.name];
    if ([line.statusDetails isEqualToString:@""]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
    }
    
    cell.detailTextLabel.text = [NSString stringWithString:line.status];
    [cell.backgroundView setNeedsDisplay];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/


/*
// Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Line *line = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    if ([segue.identifier isEqualToString:@"Show Line Status"] &&
        sender.accessoryType != UITableViewCellAccessoryNone)
    {
        [(LineStatusViewController *)segue.destinationViewController setLineName:line.name];
        [(LineStatusViewController *)segue.destinationViewController setLineColor:[self.model colorForLineWithName:line.name]];
        [(LineStatusViewController *)segue.destinationViewController setLineStatus:line.status];
        [(LineStatusViewController *)segue.destinationViewController setLineStatusDetails:line.statusDetails];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner
               willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (self.adBannerView.hidden)
    {
        self.adBannerView.hidden = NO;
    } 
}


-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    self.adBannerView.hidden = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewContro
     ller:detailViewController animated:YES];
     */
}

@end
