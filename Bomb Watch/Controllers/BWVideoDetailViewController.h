//
//  BWVideoDetailViewController.h
//  Bomb Watch
//
//  Created by Paul Friedman on 8/27/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GBVideo;
@class EVCircularProgressView;

@interface BWVideoDetailViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) GBVideo *video;
@property (strong, nonatomic) UIImageView *imageView;
@property CGRect cachedImageViewSize;

@property (strong, nonatomic) IBOutlet UIPickerView *qualityPicker;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bylineLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

// ?
@property (weak, nonatomic) IBOutlet EVCircularProgressView *progressView;

- (IBAction)actionButtonPressed:(id)sender;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)downloadButtonPressed:(id)sender;
- (IBAction)favoriteButtonPressed:(id)sender;
- (IBAction)watchedButtonPressed:(id)sender;

@end
