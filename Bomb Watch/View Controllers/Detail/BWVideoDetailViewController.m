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
#import "EVCircularProgressView.h"
#import "BWOpenOnGBActivity.h"
#import "BWVideoPlayerViewController.h"
#import "BWImagePulldownView.h"
#import "BWVideo.h"
#import "NSString+Extensions.h"
#import "BWVideoDownloader.h"
#import "BWDownloadDataStore.h"

#define kQualityCell        1
#define kQualityPickerCell  2
#define kVideoBylineCell    3
#define kVideoDurationCell  4
#define kVideoDetailCell    5

#define kBWToolbarDownloadItemPosition 2

@interface BWVideoDetailViewController ()
@property (strong, nonatomic) BWVideoPlayerViewController *player;
@property BOOL pickerVisible;
@property (strong, nonatomic) BWDownload *download;
@property (strong, nonatomic) EVCircularProgressView *progressView;
@end

@implementation BWVideoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self drawImagePulldown];

    self.descriptionLabel.text = self.video.summary;
    self.bylineCell.textLabel.text = [self bylineLabelText];
    
    self.tableView.backgroundColor = [UIColor darkGrayColor];

    [self selectQuality:[self defaultQuality]];

    self.download = [[BWDownloadDataStore defaultStore] downloadForVideo:self.video quality:[self selectedQuality]];
    
    if (self.download) {
        [self.download addObserver:self
                        forKeyPath:@"progress"
                           options:NSKeyValueObservingOptionNew
                           context:nil];
    }
}

- (void)drawImagePulldown
{
    self.imagePulldownView = [[BWImagePulldownView alloc] initWithTitle:self.video.name
                                                               imageURL:self.video.imageMediumURL];

    self.tableView.tableHeaderView = self.imagePulldownView;
    [self.tableView sendSubviewToBack:self.tableView.tableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self refreshViews];
}

- (void)selectQuality:(int)quality
{
    [self.qualityPicker selectRow:quality inComponent:0 animated:NO];
    [self pickerView:self.qualityPicker didSelectRow:quality inComponent:0];
}

- (NSInteger)defaultQuality
{
    // TODO break this out into the video class
    NSArray *qualities = @[@"Mobile", @"Low", @"High", @"HD"];
    BWVideoQuality qual = [qualities indexOfObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"defaultQuality"]];

    if (qual >= BWVideoQualityMobile && qual <= BWVideoQualityHD) {
        return qual;
    }
    return BWVideoQualityLow;
}

- (void)updateDurationLabel
{
    NSTimeInterval played = [[[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"videoProgress"] objectForKey:[NSString stringWithFormat:@"%@", [NSNumber numberWithInt:self.video.videoID]]] doubleValue];
    NSTimeInterval duration = self.video.length;
    
    if (played != 0) {
        self.durationCell.textLabel.text = [NSString stringWithFormat:@"Duration: %@ / %@", [NSString stringFromDuration:played], [NSString stringFromDuration:duration]];
    } else {
        self.durationCell.textLabel.text = [NSString stringWithFormat:@"Duration: %@", [NSString stringFromDuration:duration]];
    }
}

- (NSString *)bylineLabelText
{
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kQualityCell) {
        self.pickerVisible = !self.pickerVisible;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // height for quality picker cell - hidden or visible
    if (indexPath.row == kQualityPickerCell) {
        if (self.pickerVisible) {
            return 90;
        } else {
            return 0;
        }
    } else if (indexPath.row == kVideoBylineCell || indexPath.row == kVideoDurationCell) {
        return 44;
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
                                                             quality:[self selectedQuality]
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
    PocketAPIActivity *pocket = [[PocketAPIActivity alloc] init];
    BWOpenOnGBActivity *gb = [[BWOpenOnGBActivity alloc] init];

    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:@[self.video, self.video.siteDetailURL]
                                                    applicationActivities:@[gb, pocket]];

    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Favorites

- (IBAction)favoriteButtonPressed:(id)sender
{
    [self.video setFavorited:![self.video isFavorited]];
    [self updateFavoriteButton];

    // TODO: show image with status
    if ([self.video isFavorited]) {
        [SVProgressHUD showSuccessWithStatus:@"Favorited"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"Unfavorited"];
    }
}

- (void)updateFavoriteButton
{
    if ([self.video isFavorited]) {
        [self.favoritedButton setImage:[UIImage imageNamed:@"ToolbarFavoriteFull"]];
    } else {
        [self.favoritedButton setImage:[UIImage imageNamed:@"ToolbarFavorite"]];
    }
}

#pragma mark - Downloads

- (IBAction)downloadButtonPressed:(id)sender
{
    [SVProgressHUD showSuccessWithStatus:@"Downloading"];

    BWDownload *download = [[BWVideoDownloader defaultDownloader] downloadVideo:self.video quality:1];
    [[BWDownloadDataStore defaultStore] addDownload:download];
    self.download = download;
    [self.download addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [self updateDownloadButton];
}

- (void)updateDownloadButton
{
    BWDownload *download = [[BWDownloadDataStore defaultStore] downloadForVideo:self.video quality:[self selectedQuality]];
    
    if (download != self.download) {
        [self.download removeObserver:self forKeyPath:@"progress"];
    }

    NSMutableArray *items = [self.toolbar.items mutableCopy];

    if (download && ![download isComplete]) {
        self.download = download;
        self.progressView = [[EVCircularProgressView alloc] init];
        self.downloadButton = [[UIBarButtonItem alloc] initWithCustomView:self.progressView];
        self.downloadButton.target = self;
        self.downloadButton.action = @selector(downloadButtonPressed:);
        [self.download addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        self.progressView = nil;
        self.download = nil;
        self.downloadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarDownload"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(downloadButtonPressed:)];
        
        if ([download isComplete]) {
            self.downloadButton.enabled = NO;
        }
    }

    items[kBWToolbarDownloadItemPosition] = self.downloadButton;
    self.toolbar.items = items;
}

#pragma mark - Watched status

- (IBAction)watchedButtonPressed:(id)sender
{
    // TODO: show image with status
    [self.video setWatched:![self.video isWatched]];

    if ([self.video isWatched]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dismiss)
                                                     name:SVProgressHUDDidDisappearNotification
                                                   object:nil];
        [SVProgressHUD showSuccessWithStatus:@"Watched"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"Unwatched"];
    }

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

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:BWDownload.class] && [keyPath isEqualToString:@"progress"]) {
        [self updateDownloadButton];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:nil];
    }
}

#pragma mark - Utility

- (void)dealloc
{
    if (self.download) {
        [self.download removeObserver:self forKeyPath:@"progress"];
    }
}

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
    [self updateFavoriteButton];
    [self updateDurationLabel];

    [self.qualityPicker reloadAllComponents];
    self.qualityLabel.text = [[self pickerView:self.qualityPicker
                         attributedTitleForRow:[self selectedQuality]
                                  forComponent:0] string];

    [self.tableView reloadData];
}

- (BWVideoQuality)selectedQuality
{
    return [self.qualityPicker selectedRowInComponent:0];
}

@end
