//
//  GengDuoViewController.h
//  yungujia
//
//  Created by lijinxin on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GengDuoViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray* datasource;
}

@property (nonatomic,retain) NSMutableArray* datasource;
-(IBAction)actionLogout:(id)sender;
@end
