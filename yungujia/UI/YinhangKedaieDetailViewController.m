//
//  YinhangKedaieDetailViewController.m
//  yungujia
//
//  Created by Justin Lee on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YinhangKedaieDetailViewController.h"

@interface YinhangKedaieDetailViewController ()

@end

@implementation YinhangKedaieDetailViewController

@synthesize scrollView = _scrollView;
@synthesize contentView = _contentView;
@synthesize picker = _picker;
@synthesize btn = _btn;

//part1
@synthesize keaijineCell;
@synthesize pinggujiaCell;
@synthesize jingzhiCell;
@synthesize daikuangchengshuCell;
@synthesize shuifeiCell;

//part2
@synthesize daikuanfangshiCell;
@synthesize huankuanfangshiCell;
@synthesize daikuannianxianCell;
@synthesize nianlilvCell;
@synthesize yuegongCell;

//part3
@synthesize kehujingliCell;

//controller
@synthesize yuegongCtrl = _yuegongCtrl;
@synthesize kehujingliCtrl = _kehujingliCtrl;
@synthesize rengonggujiaCtrl = _rengonggujiaCtrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _scrollView.contentSize = _contentView.frame.size;
    self.kehujingliCtrl = [[[PinggujigouyinhangLV2ViewController alloc] initWithNibName:@"PinggujigouyinhangLV2ViewController" bundle:nil] autorelease];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    UIImage* btn_img = nil;
    
    btn_img = [UIImage imageNamed:@"btnGray"];
    btn_img = [btn_img stretchableImageWithLeftCapWidth:14 topCapHeight:23];
    [self.btn setBackgroundImage:btn_img forState:UIControlStateNormal];
    
    _section0Titles = [[NSArray arrayWithObjects:@"可贷金额",@"评估价",@"净值",@"税费",@"贷款成数",nil] retain];
    _section0Values = [[NSArray arrayWithObjects:@"234万",@"320万",@"298万",@"23万",@"七成",nil] retain];
    
    _section1Titles = [[NSArray arrayWithObjects:@"贷款方式",@"还款方式",@"贷款年限",@"年利率",@"月供",nil] retain];
    _section1Values = [[NSArray arrayWithObjects:@"商业贷款",@"等额",@"20年",@"2012/5/21基准6.80%",@"7.633.40",nil] retain];
    
    _section2Titles = [[NSArray arrayWithObjects:@"联系本行客户经理",nil] retain];
    _section2Values = [[NSArray arrayWithObjects:@"3位",nil] retain];
    
    _section0Cells = [[NSArray alloc] initWithObjects:keaijineCell,pinggujiaCell,jingzhiCell,shuifeiCell,daikuangchengshuCell, nil ];
    
    _section1Cells = [[NSArray alloc] initWithObjects:daikuanfangshiCell,huankuanfangshiCell,daikuannianxianCell,nianlilvCell,yuegongCell, nil ];
    
    _section2Cells = [[NSArray alloc] initWithObjects:kehujingliCell, nil ];
    
    _daikuanfangshiarray = [[NSArray alloc] initWithObjects:@"商业贷款",@"公积金贷款",nil];
    
    _daikuanchengshuarray = [[NSArray alloc] initWithObjects:@"9成",@"8成",@"7成",@"6成",@"5成",@"4成",@"3成",@"2成",@"1成",nil];
    
    _nianlilvarray = [[NSArray alloc] initWithObjects:@"上浮30%（7.40%）",@"上浮25%（6.20%）",@"上浮20%（5.20%）",@"2012/5/21基准6.80%",nil];
    
    _daikuannianxianarray = [[NSArray alloc] initWithObjects:@"1年",@"5年",@"10年",@"15年",@"20年",@"25年",@"30年",nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.kehujingliCtrl = nil;
    
    [_daikuanfangshiarray release];
    [_daikuanchengshuarray release];
    [_nianlilvarray release];
    [_daikuannianxianarray release];
    
    [_section0Titles release];
    [_section1Titles release];
    [_section2Titles release];
    
    [_section0Values release];
    [_section1Values release];
    [_section2Values release];
    
    [_section0Cells release];
    [_section1Cells release];
    [_section2Cells release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)OnClikedRngonggujia:(id)sender
{
    UIViewController* ctrl = nil;
    NSString* title = @"向估价师人工询价";
    for (int i = 0; i < [self.navigationController.viewControllers count]; ++i) 
    {
        ctrl = [self.navigationController.viewControllers objectAtIndex:i];
        if ([ctrl isKindOfClass:[RengongxunjiaViewController class]])
        {
            self.rengonggujiaCtrl = (RengongxunjiaViewController*)ctrl;
            self.rengonggujiaCtrl.title = title;
            [self.navigationController popToViewController:ctrl animated:YES];
            return;
        }
    }
    
    self.rengonggujiaCtrl = [[RengongxunjiaViewController alloc] initWithNibName:@"RengongxunjiaViewController" bundle:nil];
    self.rengonggujiaCtrl.title = title;
    [self.navigationController pushViewController:self.rengonggujiaCtrl animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    if (section == 1)
    {
        return @"按揭与还款";
    }
    if (section == 2)
    {
        return nil;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    else if(section == 1)
    {
        return 5;
    }
    else if(section == 2)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    if (indexPath.section == 0) {
        YinhangkedaieDetailCell* cell = [_section0Cells objectAtIndex:row];
        cell.lblTitle.text = [_section0Titles objectAtIndex:row];
        cell.lblValue.text = [_section0Values objectAtIndex:row];
        return cell;
    }
    else if (indexPath.section == 1)
    {
        YinhangkedaieDetailCell* cell = [_section1Cells objectAtIndex:row];
        cell.lblTitle.text = [_section1Titles objectAtIndex:row];
        if (row == 1)
        {
            CGRect rect = cell.seg.frame;
            rect.size.height = 34;
            cell.seg.frame = rect;
        }
        else if (row == 4)
        {
            cell.lblSubValue.text = [_section1Values objectAtIndex:row];
        }
        else
        {
            cell.lblValue.text = [_section1Values objectAtIndex:row];
        }
        return cell;
    }
    else if (indexPath.section == 2)
    {
        YinhangkedaieDetailCell* cell = [_section2Cells objectAtIndex:row];
        cell.lblTitle.text = [_section2Titles objectAtIndex:row];
        cell.lblValue.text = [_section2Values objectAtIndex:row];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == 0 && indexPath.row == 4)
    {
        _curPicker = eDaikuanchengshu;
        [_picker reloadAllComponents];
        _picker.hidden = NO;
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        _curPicker = eDaikuanfangshi;
        [_picker reloadAllComponents];
        _picker.hidden = NO;
    }
    else if(indexPath.section == 1 && indexPath.row == 2)
    {
        _curPicker = eDaikuannianxian;
        [_picker reloadAllComponents];
        _picker.hidden = NO;
    }
    else if(indexPath.section == 1 && indexPath.row == 3)
    {
        _curPicker = eNianlilv;
        [_picker reloadAllComponents];
        _picker.hidden = NO;
    }
    else if(indexPath.section == 1 && indexPath.row == 4)
    {
        _yuegongCtrl.title = @"月供清单";
        [self.navigationController pushViewController:_yuegongCtrl animated:YES];
    }
    else if(indexPath.section == 2 && indexPath.row == 0)
    {
        _kehujingliCtrl.title = @"中国银行";
        [self.navigationController pushViewController:_kehujingliCtrl animated:YES];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark -pickdelegate 
// returns width of column and height of row for each component. 
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 320.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}
// these methods return either a plain UIString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse. 
// If you return back a different object, the old one will be released. the view will be centered in the row rect  
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_curPicker == eDaikuanchengshu)
    {
        return [_daikuanchengshuarray objectAtIndex:row];
    }
    else if (_curPicker == eNianlilv)
    {
        return [_nianlilvarray objectAtIndex:row];
    }
    else if (_curPicker == eDaikuannianxian)
    {
        return [_daikuannianxianarray objectAtIndex:row];
    }
    else if (_curPicker == eDaikuanfangshi)
    {
        return [_daikuanfangshiarray objectAtIndex:row];
    }
    return @"";
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"%d",row);
//    [self.lblUserStyle setText:[self.arrayUserStyle objectAtIndex:row]];
//    [self.pickUserStyle setHidden:true];
}

#pragma mark -pickdatasource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark UIPickerWithToolBarViewDelegate
-(void)onPushedToolBarDoneButton:(UIPickerWithToolBarView*)pickerView
{
    //[self.lblUserStyle setText:[self.arrayUserStyle objectAtIndex:[pickerView selectedRowInComponent:0]]];
    _picker.hidden = YES;
}


// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_curPicker == eDaikuanchengshu)
    {
        return [_daikuanchengshuarray count];
    }
    else if (_curPicker == eNianlilv)
    {
        return [_nianlilvarray count];
    }
    else if (_curPicker == eDaikuannianxian)
    {
        return [_daikuannianxianarray count];
    }
    else if (_curPicker == eDaikuanfangshi)
    {
        return [_daikuanfangshiarray count];
    }
    return 1;
}

@end
