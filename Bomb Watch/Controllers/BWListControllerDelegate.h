//
//  BWListControllerDelegate.h
//  Bomb Watch
//
//  Created by Paul Friedman on 11/29/13.
//  Copyright (c) 2013 Laika Cosmonautics. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GBVideo;

@protocol BWListControllerDelegate <NSObject>
@optional

- (void)videoSelected:(GBVideo *)video;

@end