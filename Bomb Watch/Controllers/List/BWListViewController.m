//
//  BWListViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWListViewController.h"
#import "GiantBombAPIClient.h"
#import "GBVideo.h"
#import "BWVideoDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@implementation BWListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor grayColor]];
    [self.tableView setRowHeight:65.0];
    [self.tableView setAllowsSelection:YES];
    [self.tableView setEnabled:YES];
    [self loadVideos];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videos.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(PDGesturedTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"kBWVideoListCellIdentifier";
    PDGesturedTableViewCell *cell = (PDGesturedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        void (^completionForReleaseBlocks)(PDGesturedTableView *, PDGesturedTableViewCell *) = ^(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell){
            
            cell.textLabel.textColor = [UIColor grayColor];
            [gesturedTableView updateAnimatedly:YES];
        };
        
        cell = [[PDGesturedTableViewCell alloc] initForGesturedTableView:tableView
                                                                   style:UITableViewCellStyleDefault
                                                         reuseIdentifier:cellIdentifier];
        
        PDGesturedTableViewCellSlidingFraction * greenSlidingFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"]
                                                                      color:[UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1]
                                                         activationFraction:0.25];
        
        [greenSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
        [cell addSlidingFraction:greenSlidingFraction];

        PDGesturedTableViewCellSlidingFraction *redSlidingFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"square.png"]
                                                                      color:[UIColor redColor]
                                                         activationFraction:0.75];

        [redSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
        [cell addSlidingFraction:redSlidingFraction];
        
        PDGesturedTableViewCellSlidingFraction * yellowSlidingFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"]
                                                                      color:[UIColor colorWithRed:239.0/255.0 green:222.0/255 blue:24.0/255 alpha:1]
                                                         activationFraction:-0.25];
        
        [yellowSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
        [cell addSlidingFraction:yellowSlidingFraction];
        
        PDGesturedTableViewCellSlidingFraction * brownSlidingFraction =
            [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"square.png"]
                                                                      color:[UIColor brownColor]
                                                         activationFraction:-0.75];

        [brownSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
        [cell addSlidingFraction:brownSlidingFraction];
        
        
//        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    }
    
    GBVideo *video = (GBVideo *)self.videos[indexPath.row];
    cell.textLabel.text = video.name;
    [cell.imageView setImageWithURL:video.imageIconURL placeholderImage:[UIImage imageNamed:@"VideoListPlaceholder"]];

    return cell;
}

- (void)loadVideos
{
    [[GiantBombAPIClient defaultClient] GET:@"videos"
                                 parameters:nil
                                    success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSMutableArray *results = [NSMutableArray array];
        for (id gameDictionary in [responseObject valueForKey:@"results"]) {
            GBVideo *video = [[GBVideo alloc] initWithDictionary:gameDictionary];
            [results addObject:video];
        }
        self.videos = results;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }
                                    failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        NSLog(@"%@", error);
    }];
}

- (void)tableView:(PDGesturedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GBVideo *video = self.videos[indexPath.row];
    if (video) {
        [self performSegueWithIdentifier:@"kBWVideoDetailSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"kBWVideoDetailSegue"]) {
        BWVideoDetailViewController *controller = [segue destinationViewController];
        controller.video = self.videos[[self.tableView indexPathForSelectedRow].row];
    }
}

@end
