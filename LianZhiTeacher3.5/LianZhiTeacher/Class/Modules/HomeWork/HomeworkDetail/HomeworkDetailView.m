//
//  HomeworkDetailView.m
//  LianZhiTeacher
//
//  Created by qingxu zhou on 16/10/10.
//  Copyright © 2016年 jslsxu. All rights reserved.
//

#import "HomeworkDetailView.h"
#import "HomeworkItemAnswerView.h"
#import "NotificationVoiceView.h"
#import "HomeworkPhotoView.h"
@interface HomeworkDetailView ()
@property (nonatomic, strong)HomeworkItemAnswerView*    answerView;
@end

@implementation HomeworkDetailView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setBackgroundColor:[UIColor whiteColor]];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setAlwaysBounceVertical:YES];
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)setHomeworkItem:(HomeworkItem *)homeworkItem{
    _homeworkItem = homeworkItem;
    [self setupScrollView];
}

- (void)setupScrollView{
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(self.homeworkItem){
        NSInteger margin = 10;
        NSInteger spaceYStart = 0;
        AvatarView* avatarView = [[AvatarView alloc] initWithRadius:20];
        [avatarView setOrigin:CGPointMake(margin, margin)];
        [avatarView sd_setImageWithURL:[NSURL URLWithString:[UserCenter sharedInstance].userInfo.avatar] placeholderImage:nil];
        [_scrollView addSubview:avatarView];
        
        UILabel*    nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [nameLabel setTextColor:[UIColor colorWithHexString:@"666666"]];
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        [nameLabel setText:[UserCenter sharedInstance].userInfo.name];
        [nameLabel sizeToFit];
        [nameLabel setOrigin:CGPointMake(avatarView.right + margin, avatarView.top)];
        [_scrollView addSubview:nameLabel];
        
        UILabel*    courseLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [courseLabel setTextColor:[UIColor colorWithHexString:@"999999"]];
        [courseLabel setFont:[UIFont systemFontOfSize:13]];
        [courseLabel setText:[NSString stringWithFormat:@"%@作业",self.homeworkItem.course_name]];
        [courseLabel sizeToFit];
        [courseLabel setOrigin:CGPointMake(avatarView.right + margin, avatarView.bottom - courseLabel.height)];
        [_scrollView addSubview:courseLabel];
        
        if([self.homeworkItem.ctime length] > 0){
            UILabel*    publishTimelabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [publishTimelabel setTextColor:[UIColor colorWithHexString:@"999999"]];
            [publishTimelabel setFont:[UIFont systemFontOfSize:13]];
            [publishTimelabel setText:[NSString stringWithFormat:@"发布时间:%@",self.homeworkItem.ctime]];
            [publishTimelabel sizeToFit];
            [publishTimelabel setOrigin:CGPointMake(_scrollView.width - margin - publishTimelabel.width, avatarView.top + 2)];
            [_scrollView addSubview:publishTimelabel];
        }
        
        if(self.homeworkItem.reply_close_ctime.length > 0 && self.homeworkItem.reply_close){
            UILabel*    endTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [endTimeLabel setTextColor:kCommonTeacherTintColor];
            [endTimeLabel setFont:[UIFont systemFontOfSize:13]];
            [endTimeLabel setText:[NSString stringWithFormat:@"截止时间:%@",self.homeworkItem.reply_close_ctime]];
            [endTimeLabel sizeToFit];
            [endTimeLabel setOrigin:CGPointMake(_scrollView.width - margin - endTimeLabel.width, avatarView.bottom - endTimeLabel.height - 2)];
            [_scrollView addSubview:endTimeLabel];
        }
        
        spaceYStart = avatarView.bottom + margin;
        if([self.homeworkItem.words length] > 0){
            UILabel *wordsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [wordsLabel setWidth:self.width - margin * 2];
            [wordsLabel setTextColor:[UIColor colorWithHexString:@"333333"]];
            [wordsLabel setFont:[UIFont systemFontOfSize:14]];
            [wordsLabel setNumberOfLines:0];
            [wordsLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [wordsLabel setText:self.homeworkItem.words];
            [wordsLabel sizeToFit];
            [wordsLabel setOrigin:CGPointMake(margin, spaceYStart)];
            [_scrollView addSubview:wordsLabel];
            
            spaceYStart = wordsLabel.bottom + margin;
        }
        
        if([self.homeworkItem hasAudio]){
            AudioContentView*   audioContentView = [[AudioContentView alloc] initWithMaxWidth:_scrollView.width - margin * 2];
            [audioContentView setAudioItem:self.homeworkItem.voice];
            [audioContentView setOrigin:CGPointMake(margin, spaceYStart)];
            [_scrollView addSubview:audioContentView];
            
            spaceYStart = audioContentView.bottom + margin;
        }
        
        if([self.homeworkItem hasImage]){
            HomeworkPhotoView *photoView = [[HomeworkPhotoView alloc] initWithFrame:CGRectMake(0, spaceYStart, _scrollView.width, 0)];
            [photoView setPhotoArray:self.homeworkItem.pics];
            [_scrollView addSubview:photoView];
            spaceYStart = photoView.bottom;
        }
        
        if(self.homeworkItem.answer){
            self.answerView = [[HomeworkItemAnswerView alloc] initWithFrame:CGRectMake(0, spaceYStart, _scrollView.width, 0)];
            [self.answerView setAnswer:self.homeworkItem.answer];
            [_scrollView addSubview:self.answerView];
            spaceYStart = self.answerView.bottom;
        }
        
        [_scrollView setContentSize:CGSizeMake(self.width, spaceYStart)];
    }
}


@end
