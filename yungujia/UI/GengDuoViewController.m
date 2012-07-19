//
//  GengDuoViewController.m
//  yungujia
//
//  Created by lijinxin on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GengDuoViewController.h"
#import "AppDelegate.h"

@interface GengDuoViewController ()
-(void)buildDataSource;
@end

@implementation GengDuoViewController
@synthesize datasource;
@synthesize navigation;
-(void)buildDataSource
{
    self.datasource = [[NSMutableArray alloc] initWithObjects:@"我的询价记录",@"修改密码",@"个人认证",@"邀请好友",@"意见反馈",@"关于",@"系统消息",@"检查新版本",@"银行可贷额计算公式与说明",nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"更多";
        //self.tabBarItem.image = [UIImage imageNamed:@"second"];
        [self buildDataSource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    [self.datasource release];
    [super dealloc];
}

#pragma mark -tabledatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* dequeueIdentifer = @"UITableViewCell";
    UITableViewCell* cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:dequeueIdentifer];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dequeueIdentifer] autorelease];
    }
    cell.textLabel.text = [self.datasource objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}

#pragma mark - tabledelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
}

-(IBAction)actionLogout:(id)sender
{
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] ShowLoginView]; 
}

@end
