//
//  GongshiController.m
//  yungujia
//
//  Created by 波 徐 on 12-7-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GongshiController.h"

@interface GongshiInfo : NSObject 
{
    NSString* title;
    NSString* text;
}
@property (nonatomic,retain) NSString* title;
@property (retain,nonatomic) NSString* text;
@end

@implementation GongshiInfo
@synthesize title;
@synthesize text;

-(void)dealloc
{
    [title release];
    [text release];
    [super dealloc];
}
@end


@interface GongshiController ()

@end

@implementation GongshiController
@synthesize tableView = _tableView;

-(void)buildgongshilist
{
    for (int i = 0; i < 10; i++) {
        GongshiInfo* gongshi = [[GongshiInfo alloc] init];
        gongshi.title = i%2 ==0?[NSString stringWithFormat:@"银行可贷额说明%d",i]:[NSString stringWithFormat:@"银行可贷额计算公式%d",i];
        gongshi.text = i%2 ==0?[NSString stringWithFormat:@"银行可贷额说明银行可行可贷额说贷额说明银行可贷额说明银行可贷额说明%d",i]:[NSString stringWithFormat:@"银行可贷额计算公式银行可贷额计算公式银行行可贷额说行可贷额说行可贷额说可贷额计算公式银行可贷额计算公式银行可贷额计算公式银行可贷额计算公式%d",i];
        [gongshilist addObject:gongshi];
        [gongshi release];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"可贷额计算公式与说明";
        gongshilist = [[NSMutableArray alloc] init];
        [self buildgongshilist];
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
    [gongshilist release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [gongshilist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* dequeueIdentifer = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:dequeueIdentifer];
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] init]autorelease];
        UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 30)];
        lblTitle.text = ((GongshiInfo*)[gongshilist objectAtIndex:indexPath.row]).title;
        [cell addSubview:lblTitle];
//        [lblTitle setBackgroundColor:[UIColor redColor]];
        [lblTitle release];
        
        UITextView* lblText = [[UITextView alloc] initWithFrame:CGRectMake(5, 20, 285, 90)];
        lblText.text = ((GongshiInfo*)[gongshilist objectAtIndex:indexPath.row]).text;
        lblText.textColor =[UIColor grayColor];
        [lblText setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:lblText];
        lblText.userInteractionEnabled = FALSE;
        [lblText setFont:[UIFont systemFontOfSize:14]];
        
        [lblText release];
    }
    else {
        
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}
@end