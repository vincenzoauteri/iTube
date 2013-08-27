//
//  LineStatusViewController.m
//  iTube
//
//  Created by Vincenzo Auteri on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LineStatusViewController.h"
#import <iAd/AdBannerView.h>

@interface LineStatusViewController () <ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lineNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusDetailsLabel;
@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;

@end

@implementation LineStatusViewController
@synthesize lineNameLabel=_lineNameLabel;
@synthesize lineStatusLabel = _lineStatusLabel;
@synthesize statusDetailsLabel = _statusDetailsLabel;
@synthesize adBannerView = _adBannerView;
@synthesize lineName = _lineName;
@synthesize lineColor = _lineColor;
@synthesize lineStatusDetails = _lineStatusDetails;
@synthesize lineStatus = _lineStatus;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lineNameLabel.text = [NSString stringWithString:self.lineName];
    self.lineNameLabel.textColor = [UIColor whiteColor];
    self.lineNameLabel.backgroundColor = self.lineColor;
    self.lineStatusLabel.text = [NSString stringWithString:self.lineStatus];
    self.lineStatusLabel.backgroundColor = [UIColor lightGrayColor];
    self.lineStatusLabel.textColor = [UIColor whiteColor];
    if ([self.statusDetailsLabel.text isEqualToString:@"Status Details"]){
        //NSLog(@"%@",self.statusDetailsLabel.text);
        self.statusDetailsLabel.text = [NSString stringWithString:self.lineStatusDetails];
    }
    else {
       self.statusDetailsLabel.text = [NSString stringWithString:self.lineStatus];
    }
	self.statusDetailsLabel.textColor = [UIColor darkGrayColor];
    [self.adBannerView setDelegate:self];
    self.adBannerView.hidden = YES;
    // Do any additional setup after loading the view.
}


- (void)viewDidUnload
{
    [self setLineNameLabel:nil];
    [self setLineStatusLabel:nil];
    [self setStatusDetailsLabel:nil];
    [self setAdBannerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
@end
