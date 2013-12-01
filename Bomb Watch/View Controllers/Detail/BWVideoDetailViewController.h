//
//  BWVideoDetailViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWVideoPlayerDelegate.h"
@class BWImagePulldownView;
@class BWVideo;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BWVideoDetailViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, BWVideoPlayerDelegate>

@property (strong, nonatomic) BWVideo *video;

@property (strong, nonatomic) BWImagePulldownView *imagePulldownView;

@property (weak, nonatomic) IBOutlet UITableViewCell *qualityCell;
@property (strong, nonatomic) IBOutlet UIPickerView *qualityPicker;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bylineLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *watchedButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *downloadButton;

- (IBAction)actionButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)downloadButtonPressed:(id)sender;
- (IBAction)favoriteButtonPressed:(id)sender;
- (IBAction)watchedButtonPressed:(id)sender;

@end