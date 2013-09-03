//
//  OpenOnGBActivity.m
//  Bomb Watch
//
//  Created by Paul Friedman on 9/3/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import "OpenOnGBActivity.h"
#import "GBVideo.h"
#import "SVProgressHUD.h"

@interface OpenOnGBActivity ()

@property (strong, nonatomic) NSURL *theURL;

@end

@implementation OpenOnGBActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
	return @"OpenOnGB";
}

- (NSString *)activityTitle {
	return NSLocalizedString(@"View on Giant Bomb", nil);
}

- (UIImage *)activityImage {
	return [UIImage imageNamed:@"BombTableHeader"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) return YES;
	}
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			self.theURL = activityItem;
            return;
		}
	}
}

- (void)performActivity {
    if (self.theURL != nil && [self.theURL isKindOfClass:[NSURL class]]) {
        [[UIApplication sharedApplication] openURL:self.theURL];
        [self activityDidFinish:YES];
    }
    [self activityDidFinish:NO];
}

@end