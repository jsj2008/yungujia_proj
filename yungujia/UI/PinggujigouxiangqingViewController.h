//
//  PinggujigouxiangqingViewController.h
//  yungujia
//
//  Created by Justin Lee on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinggujigouyinhangViewController.h"
#import "PinggujigouyinhangCellViewController.h"
#import "PinggujigoujianjieViewController.h"
#import "YinhangkedaichaxunViewController.h"

@interface PinggujigouxiangqingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
}

//views
@property (nonatomic,retain) IBOutlet UIView* contentView;
@property (nonatomic,retain) IBOutlet UIImageView* logo;
@property (nonatomic,retain) IBOutlet UILabel* xiangqing;

//controllers
@property (nonatomic,retain) IBOutlet UINavigationController* navctrl;
@property (nonatomic,retain) IBOutlet PinggujigouyinhangViewController* yinhangctrl;
@property (nonatomic,retain) IBOutlet PinggujigoujianjieViewController* jianjiectrl;
@property (nonatomic,retain) IBOutlet YinhangkedaichaxunViewController* yhkdectrl;

@end
