//
//  main.m
//  ImageStretchTest
//
//  Created by Lee Justin on 13-3-19.
//  Copyright (c) 2013年 Lee Justin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.name);
            NSLog(@"%@",exception.reason);
        }
        @finally {
            //
        }
        
    }
}
