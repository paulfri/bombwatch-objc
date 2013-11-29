//
//  BWListController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWListController.h"
#import "GiantBombAPIClient.h"
#import "GBVideo.h"
#import "BWVideoFetcher.h"
#import "UIImageView+AFNetworking.h"

static NSString *cellIdentifier = @"kBWVideoListCellIdentifier";

#define kBWLeftSwipeFraction 0.01
#define kBWFarLeftSwipeFraction 0.6
#define kBWRightSwipeFraction 0.01
#define kBWFarRightSwipeFraction 0.6

@implementation BWListController

- (id)initWithTableView:(PDGesturedTableView *)tableView
{
    return [self initWithTableView:tableView category:nil];
}

- (id)initWithTableView:(PDGesturedTableView *)tableView category:(NSString *)category
{
    self = [super init];

    if (self) {
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        self.page = 1;
        self.category = category;
        self.videos = [[NSMutableArray alloc] init];
        
        UITableViewController *tableViewController = [[UITableViewController alloc] init];
        tableViewController.tableView = self.tableView;
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshControlActivated) forControlEvents:UIControlEventValueChanged];
        tableViewController.refreshControl = self.refreshControl;
        
        [self loadVideosForPage:1];
    }

    return self;
}

- (GBVideo *)videoAtIndexPath:(NSIndexPath *)indexPath
{
    return self.videos[indexPath.row];
}

- (void)refreshControlActivated
{
    self.page = 1;
    [self loadVideosForPage:1];
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videos.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(PDGesturedTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDGesturedTableViewCell *cell = (PDGesturedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [self initializeCell];
    }
    
    GBVideo *video = (GBVideo *)self.videos[indexPath.row];
    cell.textLabel.text = video.name;
    [cell.imageView setImageWithURL:video.imageIconURL
                   placeholderImage:[UIImage imageNamed:@"VideoListPlaceholder"]];
    
    return cell;
}

- (void)loadVideosForPage:(NSInteger)page
{
    [[BWVideoFetcher defaultFetcher] fetchVideosForCategory:self.category
                                                       page:page
                                                    success:^(NSArray *results)
    {
        if (page == 1) {
            self.videos = [results copy];
        } else {
            self.videos = [[self.videos arrayByAddingObjectsFromArray:results] mutableCopy];
        }
        
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
                                                    failure:nil];
}

#pragma mark - table view delegate

- (void)tableView:(PDGesturedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GBVideo *video = [self videoAtIndexPath:indexPath];
    
    if (video && self.delegate && [self.delegate respondsToSelector:@selector(videoSelected:)]) {
        [self.delegate videoSelected:video];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffsetY = scrollView.contentOffset.y + [[UIScreen mainScreen] bounds].size.height;
    CGFloat contentHeight = scrollView.contentSize.height;
    
    if (currentOffsetY > ((contentHeight * 3)/ 4.0)) {
        // if it's >=, we're all caught up and can load the next page
        // if it's < , then there should already be a load in progress
        if(self.videos.count >= (self.page * kBWVideosPerPage)) {
            self.page++;
            [self loadVideosForPage:self.page];
        }
    }
}

#pragma mark - cell

- (PDGesturedTableViewCell *)initializeCell
{
    PDGesturedTableViewCell *cell = [[PDGesturedTableViewCell alloc] init];
    
    void (^completionForReleaseBlocks)(PDGesturedTableView *, PDGesturedTableViewCell *) = ^(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell)
    {
        
        cell.textLabel.textColor = [UIColor grayColor];
        [gesturedTableView updateAnimatedly:YES];
    };
    
    cell = [[PDGesturedTableViewCell alloc] initForGesturedTableView:self.tableView
                                                               style:UITableViewCellStyleDefault
                                                     reuseIdentifier:cellIdentifier];
    
    PDGesturedTableViewCellSlidingFraction * greenSlidingFraction =
        [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"]
                                                                  color:[UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1]
                                                     activationFraction:kBWLeftSwipeFraction];
    
    [greenSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
    [cell addSlidingFraction:greenSlidingFraction];
    
    PDGesturedTableViewCellSlidingFraction *redSlidingFraction =
        [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"square.png"]
                                                                  color:[UIColor redColor]
                                                     activationFraction:kBWFarLeftSwipeFraction];
    
    [redSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
    [cell addSlidingFraction:redSlidingFraction];
    
    PDGesturedTableViewCellSlidingFraction * yellowSlidingFraction =
        [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"]
                                                                  color:[UIColor colorWithRed:239.0/255.0 green:222.0/255 blue:24.0/255 alpha:1]
                                                     activationFraction:-kBWRightSwipeFraction];
    
    [yellowSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
    [cell addSlidingFraction:yellowSlidingFraction];
    
    PDGesturedTableViewCellSlidingFraction * brownSlidingFraction =
        [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"square.png"]
                                                                  color:[UIColor brownColor]
                                                     activationFraction:-kBWFarRightSwipeFraction];
    
    [brownSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
    [cell addSlidingFraction:brownSlidingFraction];
    
    
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    
    return cell;
}

@end
