//
//  MineVC.m
//  LianZhiTeacher
//
//  Created by jslsxu on 15/8/12.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "MineVC.h"
#import "PersonalInfoVC.h"
#import "ContactServiceVC.h"
#import "RelatedInfoVC.h"
#import "PersonalSettingVC.h"
#import "AboutVC.h"
#define kUserInfoCellHeight                     75

@implementation UserInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _avatarView = [[AvatarView alloc] initWithFrame:CGRectMake(16, 10, 55, 55)];
        [self addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setTextColor:[UIColor colorWithHexString:@"2c2c2c"]];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_nameLabel];
        
        _genderView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_genderView setContentMode:UIViewContentModeCenter];
        [self addSubview:_genderView];
        
        _idLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_idLabel setTextColor:[UIColor lightGrayColor]];
        [_idLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:_idLabel];
    }
    return self;
}

- (void)refresh
{
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:[UserCenter sharedInstance].userInfo.avatar]];
    [_nameLabel setText:[UserCenter sharedInstance].userInfo.name];
    [_nameLabel sizeToFit];
    [_nameLabel setOrigin:CGPointMake(_avatarView.right + 10, 18)];
    
    GenderType gender = [UserCenter sharedInstance].userInfo.sex;
    if(gender == GenderFemale)
        [_genderView setImage:[UIImage imageNamed:(@"GenderFemale")]];
    else
        [_genderView setImage:[UIImage imageNamed:(@"GenderMale")]];
    [_genderView setFrame:CGRectMake(_nameLabel.right + 5, _nameLabel.y, 16, 16)];
    
    [_idLabel setText:[NSString stringWithFormat:@"连枝号:%@",[UserCenter sharedInstance].userInfo.uid]];
    [_idLabel sizeToFit];
    [_idLabel setOrigin:CGPointMake(_avatarView.right + 10, kUserInfoCellHeight - 18 - _idLabel.height)];

}
@end

@interface MineCell ()
@property (nonatomic, strong)UIImageView* logoView;
@property (nonatomic, strong)UILabel*       titleLabel;
@property (nonatomic, strong)UILabel*       newlabel;
@end

@implementation MineCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.logoView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.titleLabel setTextColor:[UIColor colorWithHexString:@"2c2c2c"]];
        [self addSubview:self.titleLabel];
        
        [self addSubview:[self newlabel]];
        
        [self setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow"]]];
    }
    return self;
}

- (void)setimage:(UIImage *)image title:(NSString *)title{
    [self.logoView setImage:image];
    [self.logoView sizeToFit];
    [self.logoView setOrigin:CGPointMake(20, (self.height - self.logoView.height) / 2)];
    
    [self.titleLabel setText:title];
    [self.titleLabel sizeToFit];
    [self.titleLabel setOrigin:CGPointMake(self.logoView.right + 15, (self.height - self.titleLabel.height) / 2)];
}

- (UILabel *)newlabel{
    if(_newlabel == nil){
        _newlabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_newlabel setBackgroundColor:[UIColor colorWithHexString:@"F0003A"]];
        [_newlabel setTextColor:[UIColor whiteColor]];
        [_newlabel setText:@"new"];
        [_newlabel setFont:[UIFont systemFontOfSize:12]];
        [_newlabel setTextAlignment:NSTextAlignmentCenter];
        [_newlabel sizeToFit];
        [_newlabel setSize:CGSizeMake(_newlabel.width + 10, (int)_newlabel.height + 4)];
        [_newlabel.layer setCornerRadius:_newlabel.height / 2];
        [_newlabel.layer setMasksToBounds:YES];
    }
    return _newlabel;
}

- (void)setHasNew:(BOOL)hasNew{
    _hasNew = hasNew;
    [self.newlabel setHidden:!_hasNew];
    [self.newlabel setOrigin:CGPointMake(self.titleLabel.right + 10, (self.height - self.titleLabel.height) / 2)];
}

@end

@interface MineVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)NSArray *titleArray;
@property (nonatomic, strong)NSArray *imageArray;
@property (nonatomic, strong)NSArray *actionArray;
@end

@implementation MineVC

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.titleArray = @[@[@"我的学校",@"系统设置"],@[@"关于连枝",@"联系客服"]];
        self.imageArray = @[@[@"IconMySchool",@"IconSetting"],@[@"IconAbout",@"IconContact"]];
        self.actionArray = @[@[@"RelatedInfoVC",@"PersonalSettingVC"],@[@"AboutVC",@"ContactServiceVC"]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kUserInfoChangedNotification object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    self.navigationItem.leftBarButtonItems = [ApplicationDelegate.homeVC commonLeftBarButtonItems];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationItem.leftBarButtonItems = nil;
}

- (void)setTitle:(NSString *)title{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [titleLabel setFont:[UIFont systemFontOfSize:18]];
    [titleLabel setTextColor:[UIColor colorWithHexString:@"252525"]];
    [titleLabel setText:title];
    [titleLabel setSize:CGSizeMake(kScreenWidth / 2, 30)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.navigationItem setTitleView:titleLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我";
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView setSeparatorColor:kCommonSeparatorColor];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:_tableView];
    
    //加载设置
    [[UserCenter sharedInstance] requestNoDisturbingTime];
}

- (void)reloadData{
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    else
    {
        NSArray *titleArray = self.titleArray[section - 1];
        return titleArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return kUserInfoCellHeight;
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSString *reuseID = nil;
    if(section == 0)
    {
        reuseID = @"UserInfoCell";
        UserInfoCell *cell = (UserInfoCell *)[tableView dequeueReusableCellWithIdentifier:reuseID];
        if(cell == nil)
        {
            cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow"]]];
        }
        [cell refresh];
        return cell;
    }
    else
    {
        reuseID = @"PersonalCell";
        MineCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
        if(cell == nil)
        {
            cell = [[MineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
        }

        NSInteger row = indexPath.row;
        if(section > 0)
        {
            [cell setimage:[UIImage imageNamed:self.imageArray[section - 1][row]] title:self.titleArray[section - 1][row]];
            [cell setHasNew:indexPath.row == 0 && indexPath.section == 2 && ApplicationDelegate.needUpdate];
            [cell setHasNew:indexPath.row == 0 && indexPath.section == 2 && ApplicationDelegate.needUpdate];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(section == 0)
    {
        PersonalInfoVC *personalInfoVC = [[PersonalInfoVC alloc] init];
        [CurrentROOTNavigationVC pushViewController:personalInfoVC animated:YES];
    }
    else
    {
        if(indexPath.row == 0 && indexPath.section == 2 && ApplicationDelegate.needUpdate){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTeacherClientAppStoreUrl]];
        }
        else{
            TNBaseViewController *actionVC = [[NSClassFromString(self.actionArray[section - 1][row]) alloc] init];
            [CurrentROOTNavigationVC pushViewController:actionVC animated:YES];
        }
    }
}
@end
