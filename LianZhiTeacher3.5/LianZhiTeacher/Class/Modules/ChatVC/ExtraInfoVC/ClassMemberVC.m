//
//  ClassMemberVC.m
//  LianZhiParent
//
//  Created by jslsxu on 15/9/14.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "ClassMemberVC.h"
#import "JSMessagesViewController.h"
#import "StudentParentsVC.h"
#import "ChatTeacherInfoVC.h"
#import "ChatParentInfoVC.h"

@implementation MemberItem


@end

@implementation SectionGroup

- (void)addGroup:(SectionGroup *)sectionGroup{
    NSMutableArray *memberArray = [NSMutableArray arrayWithArray:self.memberArray];
    [memberArray addObjectsFromArray:sectionGroup.memberArray];
    self.memberArray = memberArray;
}

@end
@implementation MemberSectionHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if(self){
        [self setSize:CGSizeMake(kScreenWidth, 20)];
        [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"ebebeb"]];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.width - 10 * 2, self.height)];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_titleLabel setTextColor:[UIColor colorWithHexString:@"999999"]];
        [_titleLabel setFont:[UIFont systemFontOfSize:13]];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = [title copy];
    [_titleLabel setText:_title];
}
@end


@implementation MemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setSize:CGSizeMake(kScreenWidth, 45)];
        _avatarView = [[AvatarView alloc] initWithFrame:CGRectMake(10, (self.height - 32) / 2, 32, 32)];
        [self addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 180, self.height)];
        [_nameLabel setTextColor:[UIColor colorWithHexString:@"2c2c2c"]];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_nameLabel];
        
        _sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kLineHeight, self.width, kLineHeight)];
        [_sepLine setBackgroundColor:kSepLineColor];
        [self addSubview:_sepLine];
    }
    return self;
}
- (void)setUserInfo:(UserInfo *)userInfo
{
    _userInfo = userInfo;
    [_nameLabel setText:_userInfo.name];
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:_userInfo.avatar]];
    [_avatarView setStatus:_userInfo.actived ? nil : @"未下载"];
}

- (void)setLabel:(NSString *)label{
    if(label.length > 0){
        _label = [label copy];
        [_nameLabel setText:_label];
    }
}

@end

@interface ClassMemberVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *sourceArray;
@property (nonatomic, strong)UITableView*   tableView;
@end

@implementation ClassMemberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.atCallback && self.cancelCallback){
        self.title = @"选择提醒的人";
        self.navigationItem.leftBarButtonItem  =[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    }
    else{
        self.title = @"群成员";
    }
    
    self.sourceArray = [NSMutableArray array];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [_tableView setSectionIndexColor:[UIColor colorWithHexString:@"666666"]];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    
    [self loadData];
}

- (void)dismiss{
    if(self.cancelCallback){
        self.cancelCallback();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadData{
    @weakify(self)
    if(self.classID)
    {
        void (^parse)(TNDataWrapper *responseObject) = ^(TNDataWrapper *responseObject){
            [self.sourceArray removeAllObjects];
            @strongify(self)
            TNDataWrapper *classWrapper = [responseObject getDataWrapperForKey:@"class"];
            NSArray *teacherArray = [TeacherInfo nh_modelArrayWithJson:[classWrapper getDataWrapperForKey:@"teachers"].data];
            NSArray *studentArray = [StudentInfo nh_modelArrayWithJson:[classWrapper getDataWrapperForKey:@"students"].data];
            
            SectionGroup *teacherGroup = [[SectionGroup alloc] init];
            [teacherGroup setTitle:@"教师"];
            [teacherGroup setIndexkey:@"师"];
            NSMutableArray *memberArray = [NSMutableArray array];
            for (TeacherInfo *teacherInfo in teacherArray) {
                MemberItem *item = [[MemberItem alloc] init];
                [item setToObjid:[UserCenter sharedInstance].curSchool.schoolID];
                [item setUserInfo:teacherInfo];
                [memberArray addObject:item];
            }
            [teacherGroup setMemberArray:memberArray];
            [self.sourceArray addObject:teacherGroup];
            
            NSMutableArray *studentGroupArray = [NSMutableArray array];
            for (StudentInfo *childInfo in studentArray) {
                SectionGroup *sectionGroup = [[SectionGroup alloc] init];
                [sectionGroup setTitle:childInfo.first_letter];
                [sectionGroup setIndexkey:childInfo.first_letter];
                
                NSMutableArray *memberArray = [NSMutableArray array];
                for (FamilyInfo *familyInfo in childInfo.family) {
                    MemberItem *item = [[MemberItem alloc] init];
                    [item setUserInfo:familyInfo];
                    [item setToObjid:childInfo.uid];
                    [item setLabel:[NSString stringWithFormat:@"%@的%@",childInfo.name, familyInfo.relation]];
                    [memberArray addObject:item];
                }
                [sectionGroup setMemberArray:memberArray];
                [studentGroupArray addObject:sectionGroup];
            }
            [studentGroupArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                SectionGroup *firstGroup = (SectionGroup *)obj1;
                SectionGroup *secondGroup = (SectionGroup *)obj2;
                return [firstGroup.title compare:secondGroup.title];
            }];
            SectionGroup *preGroup = nil;
            NSMutableArray *deleteArray = [NSMutableArray array];
            for (SectionGroup *userGroup in studentGroupArray) {
                if([userGroup.indexkey isEqualToString:preGroup.indexkey]){
                    [preGroup addGroup:userGroup];
                    [deleteArray addObject:userGroup];
                }
                else{
                    preGroup = userGroup;
                }
            }
            if(deleteArray.count > 0){
                [studentGroupArray removeObjectsInArray:deleteArray];
            }
            [self.sourceArray addObjectsFromArray:studentGroupArray];
            [self.tableView reloadData];
        };
        TNDataWrapper *dataWrapper = [[LZKVStorage userKVStorage] storageValueForKey:[self cacheKey]];
        if(dataWrapper && [dataWrapper isKindOfClass:[TNDataWrapper class]]){
            parse(dataWrapper);
        }
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:self.classID forKey:@"class_id"];
        [[HttpRequestEngine sharedInstance] makeRequestFromUrl:@"app/contact_of_class" method:REQUEST_GET type:REQUEST_REFRESH withParams:params observer:self completion:^(AFHTTPRequestOperation *operation, TNDataWrapper *responseObject) {
            if(responseObject){
                [[LZKVStorage userKVStorage] saveStorageValue:responseObject forKey:[self cacheKey]];
            }
            parse(responseObject);
        } fail:^(NSString *errMsg) {
            
        }];
    }
    else if(self.groupID)
    {
        for (TeacherGroup *teacherGroup in [UserCenter sharedInstance].curSchool.groups) {
            if([teacherGroup.groupID isEqualToString:self.groupID]){
                NSMutableDictionary *groupDic = [NSMutableDictionary dictionary];
                for (TeacherInfo *teacherInfo in teacherGroup.teachers) {
                    NSString *indexKey = teacherInfo.first_letter;
                    SectionGroup *group = groupDic[indexKey];
                    if(!group){
                        group = [[SectionGroup alloc] init];
                        [group setTitle:teacherInfo.first_letter];
                        [group setIndexkey:teacherInfo.first_letter];
                        [groupDic setValue:group forKey:indexKey];
                    }
                    NSMutableArray *memberArray = [NSMutableArray arrayWithArray:group.memberArray];
                    MemberItem *item = [[MemberItem alloc] init];
                    [item setUserInfo:teacherInfo];
                    [item setToObjid:[UserCenter sharedInstance].curSchool.schoolID];
                    [memberArray addObject:item];
                    [group setMemberArray:memberArray];
                }
                NSArray *allKeys = [groupDic allKeys];
                for (NSString *key in allKeys) {
                    [self.sourceArray addObject:groupDic[key]];
                }
                [self.sourceArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    SectionGroup *firstGroup = (SectionGroup *)obj1;
                    SectionGroup *secondGroup = (SectionGroup *)obj2;
                    return [firstGroup.indexkey compare:secondGroup.indexkey];
                }];
            }
        }
        [self.tableView reloadData];
    }

}

- (NSString *)cacheKey{
    if(self.classID.length > 0){
        return [NSString stringWithFormat:@"classMember_%@",self.classID] ;
    }
    return nil;
}

#pragma mark


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sourceArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionGroup *group = self.sourceArray[section];
    return [group.memberArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *titleArray = [NSMutableArray array];
    for (SectionGroup *group in self.sourceArray) {
        if(group.indexkey)
            [titleArray addObject:group.indexkey];
        else{
            [titleArray addObject:@""];
        }
    }
    return titleArray;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *reuseID = @"Memberheader";
    MemberSectionHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseID];
    if(headerView == nil){
        headerView = [[MemberSectionHeader alloc] initWithReuseIdentifier:reuseID];
    }
    SectionGroup *group = self.sourceArray[section];
    [headerView setTitle:group.title];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseID = @"MemberCell";
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if(nil == cell)
    {
        cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    SectionGroup *group = self.sourceArray[indexPath.section];
    MemberItem *item = group.memberArray[indexPath.row];
    [cell setUserInfo:item.userInfo];
    [cell setLabel:item.label];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SectionGroup *group = self.sourceArray[indexPath.section];
    MemberItem *item = group.memberArray[indexPath.row];
    UserInfo *userInfo = item.userInfo;
    NSString *label = item.label;
    if(self.atCallback){
        if(label.length > 0){
            userInfo.name = label;
        }
        self.atCallback(userInfo);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        if([userInfo isKindOfClass:[TeacherInfo class]]){
            ChatTeacherInfoVC *teacherVC = [[ChatTeacherInfoVC alloc] init];
            [teacherVC setUid:userInfo.uid];
            [self.navigationController pushViewController:teacherVC animated:YES];
        }
        else{
            ChatParentInfoVC *parentVC = [[ChatParentInfoVC alloc] init];
            [parentVC setLabel:label];
            [parentVC setUid:userInfo.uid];
            [parentVC setChildID:item.toObjid];
            [self.navigationController pushViewController:parentVC animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
