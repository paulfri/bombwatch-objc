//
//  BWListViewController.m
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "BWListViewController.h"
#import "BWVideoDetailViewController.h"
#import "BWVideo.h"
#import "SVProgressHUD.h"

@interface BWListViewController ()

@property (strong, nonatomic) UIView *disableOverlay;

@end

@implementation BWListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.category;
    self.listController = [[BWListController alloc] initWithTableView:self.tableView
                                                             category:self.category];
    self.listController.delegate = self;
    self.tableView.separatorColor = [UIColor darkGrayColor];
    
    CGRect f = self.tableView.frame;
    CGRect frame = CGRectMake(f.origin.x, f.origin.y + 44, f.size.width, f.size.height - 44);
    self.disableOverlay = [[UIView alloc] initWithFrame:frame];
    self.disableOverlay.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTapped)];
    [self.disableOverlay addGestureRecognizer:tapGesture];

    [self.tableView setContentOffset:CGPointMake(0,44) animated:YES];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // hack to get rid of 1px black line under search bar
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [[UIColor colorWithRed:34.0/255 green:34.0/255 blue:34.0/255 alpha:1.0] CGColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"kBWVideoDetailSegue"]) {
        BWVideoDetailViewController *controller = [segue destinationViewController];
        controller.video = sender;
    }
}

#pragma mark - BWListControllerDelegate

- (void)videoSelected:(BWVideo *)video
{
    [self performSegueWithIdentifier:@"kBWVideoDetailSegue" sender:video];
}

- (void)tableViewContentsReset
{
    self.title = self.category;
}

- (void)searchDidCompleteWithSuccess
{
    self.title = self.searchBar.text;
    [SVProgressHUD dismiss];
    [self searchBar:self.searchBar setActive:NO];
}

- (void)searchDidCompleteWithFailure
{
    [SVProgressHUD showErrorWithStatus:@"Error"];
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self searchBar:searchBar setActive:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [SVProgressHUD show];
    [self.listController search:searchBar.text];
}

#pragma mark - util

- (void)searchBar:(UISearchBar *)searchBar setActive:(BOOL)active
{
    self.tableView.scrollEnabled = !active;
    self.tableView.allowsSelection = !active;
    
    if (!active) {
        [self.searchBar resignFirstResponder];
        [self.disableOverlay removeFromSuperview];
    } else {
        self.disableOverlay.alpha = 0;
        [self.tableView addSubview:self.disableOverlay];
        
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        self.disableOverlay.alpha = 0.6;
        [UIView commitAnimations]; // clean up this syntax
    }
}

- (void)overlayTapped
{
    [self searchBar:self.searchBar setActive:NO];
    NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([self.tableView numberOfRowsInSection:0]) {
        [self.tableView scrollToRowAtIndexPath:top
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
}

@end
