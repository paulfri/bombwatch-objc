//
//  BWVideoDetailViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWVideoDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PocketAPIActivity.h"
#import "PocketAPI.h"
#import "SVProgressHUD.h"
#import "GiantBombAPIClient.h"
//#import "EVCircularProgressView.h"
#import "OpenOnGBActivity.h"
#import "BWVideoPlayerViewController.h"
#import "BWImagePulldownView.h"
#import "BWVideo.h"
#import "NSString+Extensions.h"

// default quality when no downloads are present
#define kQualityCell        1
#define kQualityPickerCell  2
#define kVideoBylineCell    3
#define kVideoDetailCell    4

@interface BWVideoDetailViewController ()

@property (strong, nonatomic) BWVideoPlayerViewController *player;
@property BOOL pickerVisible;

@end

@implementation BWVideoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self drawImagePulldown];

    self.titleLabel.text = self.video.name;
    self.descriptionLabel.text = self.video.summary;
    self.bylineLabel.text = [self bylineLabelText];

    [self updateDurationLabel];
}

// Tweetbot-style image pulldown
- (void)drawImagePulldown
{
    self.imagePulldownView = [[BWImagePulldownView alloc] initWithTitle:self.video.name
                                                               imageURL:self.video.imageSmallURL];
    self.tableView.tableHeaderView = self.imagePulldownView;
    [self.tableView sendSubviewToBack:self.tableView.tableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self selectQuality:[self defaultQuality]];
    [self refreshViews];
}

- (void)selectQuality:(int)quality {
    [self.qualityPicker selectRow:quality inComponent:0 animated:NO];
    [self pickerView:self.qualityPicker didSelectRow:quality inComponent:0];
}

- (NSInteger)defaultQuality {
    NSArray *qualities = @[@"Mobile", @"Low", @"High", @"HD"];
    int qual = [qualities indexOfObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"defaultQuality"]];
    if (qual >= 0 && qual <= 3)
        return qual;
//    return BWDownloadVideoQualityLow;
    return 1;
}

- (void)updateDurationLabel
{
    NSTimeInterval played = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"] objectForKey:[NSString stringWithFormat:@"%@", [NSNumber numberWithInt:self.video.videoID]]] doubleValue];
    NSTimeInterval duration = self.video.length;
    
    if (played != 0) {
        self.durationLabel.text = [NSString stringWithFormat:@"Duration: %@ / %@", [NSString stringFromDuration:played], [NSString stringFromDuration:duration]];
    } else {
        self.durationLabel.text = [NSString stringWithFormat:@"Duration: %@", [NSString stringFromDuration:duration]];
    }
}

- (NSString *)bylineLabelText {
    static NSDictionary *users;

    if (users == nil) {
        users = @{@"jeff": @"Jeff Gerstmann",
                  @"ryan": @"Ryan Davis",
                  @"brad": @"Brad Shoemaker",
                  @"vinny": @"Vinny Caravella",
                  @"patrickklepek": @"Patrick Klepek",
                  @"drewbert": @"Drew Scanlon",
                  @"alex": @"Alex Navarro",
                  @"snide": @"Dave Snider",
                  @"mattbodega": @"Matthew Kessler",
                  @"marino": @"Marino",
                  @"rorie": @"Matt Rorie",
                  @"abauman": @"Andy Bauman",
                  @"danielcomfort": @"Daniel Comfort"};
    }
    
    if (users[self.video.user]) {
        return users[self.video.user];
    }

    return self.video.user;
}

#pragma mark - UITableViewDelegate protocol methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == kQualityCell) {
        self.pickerVisible = !self.pickerVisible;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // height for quality picker cell - hidden or visible
    if (indexPath.row == kQualityPickerCell) {
        if (self.pickerVisible)
            return 90;
        else
            return 0;
    } else if (indexPath.row == kVideoBylineCell) {
        return 40;
    } else if (indexPath.row == kVideoDetailCell) {
        return [self.descriptionLabel sizeThatFits:self.descriptionLabel.frame.size].height + 10;
    }

    return 44;
}

#pragma mark - UIScrollViewDelegate protocol methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.imagePulldownView scrollViewDidScroll:scrollView];
}

#pragma mark - UIPickerViewDelegate protocol methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
#warning constantize/enumerate
    NSArray *qualities = @[@"Mobile", @"Low", @"High", @"HD"];

    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:qualities[row]
                                                                    attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    return attString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self refreshViews];
}

#pragma mark - UIPickerViewDataSource protocol methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([self isPremium]) {
        return 4;
    }

    return 3;
}

- (BOOL)isPremium
{
//    return ![[self.video.videoHDURL absoluteString] isEqual:GiantBombVideoEmptyURL];
    return false;
}

#pragma mark - Video player control

- (IBAction)playButtonPressed:(id)sender {
    self.player = [[BWVideoPlayerViewController alloc] initWithVideo:self.video
                                                             quality:[self.qualityPicker selectedRowInComponent:0]
                                                           downloads:nil];
    self.player.delegate = self;
    [self presentMoviePlayerViewControllerAnimated:self.player];
    [self.player play];
}

#pragma mark - BWVideoPlayerDelegate protocol methods

- (void)videoDidFinishPlaying
{
    [self updateWatchedButton];
    [self updateDurationLabel];
}

#pragma mark - Action sheet

- (IBAction)actionButtonPressed:(id)sender
{
    NSArray *activityItems = @[self.video, self.video.siteDetailURL];
    NSArray *applicationActivities;

    PocketAPIActivity *pocketActivity = [[PocketAPIActivity alloc] init];
    OpenOnGBActivity *gbActivity = [[OpenOnGBActivity alloc] init];
    applicationActivities = @[gbActivity, pocketActivity];
    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:activityItems
                                                    applicationActivities:applicationActivities];

    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Favorites

- (IBAction)favoriteButtonPressed:(id)sender
{
    // TODO: show image with status
    [SVProgressHUD showSuccessWithStatus:@"Favorited"];
}

#pragma mark - Downloads

- (IBAction)downloadButtonPressed:(id)sender
{
    [SVProgressHUD showSuccessWithStatus:@"Downloading"];
}

- (void)updateDownloadButton
{
    BOOL enabled = YES; // lol

    if (enabled) {
        self.downloadButton.image = [UIImage imageNamed:@"ToolbarDownload"];
    }
    
    self.downloadButton.enabled = enabled;
}

#pragma mark - Watched status

- (IBAction)watchedButtonPressed:(id)sender
{
    // TODO: show image with status
//    if (![self.video isWatched]) {
//        [self.video setWatched];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(dismiss)
//                                                     name:SVProgressHUDDidDisappearNotification
//                                                   object:nil];
//        [SVProgressHUD showSuccessWithStatus:@"Watched"];
//    } else {
//        [self.video setUnwatched];
//        [SVProgressHUD showSuccessWithStatus:@"Unwatched"];
//    }

    [self updateWatchedButton];
}

- (void)updateWatchedButton
{
    if ([self.video isWatched]) {
        self.watchedButton.image = [UIImage imageNamed:@"ToolbarCheckFull"];
    } else {
        self.watchedButton.image = [UIImage imageNamed:@"ToolbarCheck"];
    }
}

#pragma mark - Utility

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SVProgressHUDDidDisappearNotification
                                                  object:nil];
}

- (void)refreshViews
{
    [self updateDownloadButton];
    [self updateWatchedButton];
    [self.qualityPicker reloadAllComponents];
    self.qualityLabel.text = [[self pickerView:self.qualityPicker
                         attributedTitleForRow:[self.qualityPicker selectedRowInComponent:0]
                                  forComponent:0] string];

    [self.tableView reloadData];
}

@end