//
//  YinhangkedaichaxunViewController.h
//  yungujia
//
//  Created by Justin Lee on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeyinhangkedaieViewController.h"
#import "UIPickerWithToolBarView.h"

@interface YinhangkedaichaxunViewController : UIViewController <UIPickerViewDataSource, UIPickerWithToolBarViewDelegate,UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource>

{
    NSMutableArray* _pickerContents;
}

//views
@property (nonatomic,retain) IBOutlet UIView* contentView;
@property (nonatomic,retain) IBOutlet UINavigationBar* navbar;
@property (nonatomic,retain) IBOutlet UIPickerWithToolBarView* pickerView;
@property (nonatomic,retain) IBOutlet UITextField* textField;
@property (nonatomic,retain) IBOutlet UIButton* btn;
@property (nonatomic,retain) IBOutlet UISegmentedControl* goumainianxianSeg;
@property (nonatomic,retain) IBOutlet UISegmentedControl* wuyeleixingSeg;
@property (nonatomic,retain) IBOutlet UISegmentedControl* chanquanguishuSeg;

//controllers
@property (nonatomic,retain) IBOutlet UINavigationController* navctrl;
@property (nonatomic,retain) IBOutlet GeyinhangkedaieViewController* gyhkdectrl;


@property (nonatomic,retain) NSMutableArray* pickerContents;

- (IBAction)push_Kaishijisuan:(id)sender;
- (IBAction)push_Pinggujia:(id)sender;

@end
