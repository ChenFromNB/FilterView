//
//  FilterView.m
//  IFlying
//
//  Created by llwang on 13-11-21.
//  Copyright (c) 2013年 com.iflying. All rights reserved.
//
#import "FilterView.h"

@interface FilterView() <PullDownMenuDelegate>
{
    NSMutableArray *_selectedArray;
}
@end

@implementation FilterView

- (id)initWithFrame:(CGRect)frame
   buttonTitleArray:(NSArray*)titleArray
    dataSourceArray:(NSArray*)dataArray
           delegate:(id<FilterViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
        _dataArray = dataArray;
        _selectedArray = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        int count = titleArray.count;
        for (int i = 0; i<count ;i++) {
            UIButton* b = [UIButton buttonWithType:UIButtonTypeCustom];
            b.imageEdgeInsets = UIEdgeInsetsMake(0, self.frame.size.width/count - 20, 0, 0);
            b.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 15);
            b.backgroundColor = [UIColor whiteColor];
            b.adjustsImageWhenHighlighted = NO;
            [b setTag:i];
            [b.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [b setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [b setImage:[UIImage imageNamed:@"filter_top"] forState:UIControlStateNormal];
            [b setImage:[UIImage imageNamed:@"filter_down"] forState:UIControlStateSelected];
            NSString* selectedName = [NSString stringWithFormat:@"filter_btn_bg_selected%d",count];
            [b setBackgroundImage:[[UIImage imageNamed:selectedName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 10, 0)]
                         forState:UIControlStateSelected];
            [b setBackgroundImage:[[UIImage imageNamed:@"filter_btn_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 2, 0)]
                         forState:UIControlStateNormal];
            [b setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor] cornerRadius:0]
                         forState:UIControlStateHighlighted];
            [b setFrame:CGRectMake(i*self.frame.size.width/count, 0, self.frame.size.width/count, self.frame.size.height)];
            [b setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
            [b addTarget:self
                  action:@selector(__showTableView:)
        forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:b];
            //每个button对应_selectedArray的一项
            [_selectedArray addObject:@{}];
        }
        
        for (int i=1; i<count; i++) {
            UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(i*self.frame.size.width/count, 0, 0.5, self.frame.size.height)];
            separator.contentMode = UIViewContentModeScaleAspectFit;
            separator.image = [UIImage imageNamed:@"filter_separator"];
            [self addSubview:separator];
        }
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
}

- (void)setEnabled:(BOOL)enable
{
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            ((UIButton *)v).enabled = enable;
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            ((UIButton *)v).selected = selected;
        }
    }
}

#pragma mark - PullDownMenud Delegate

- (void)pullDownMenu:(PullDownMenu *)pullDownMenu didSelectedCell:(NSDictionary *)info selectedMenuIndex:(NSInteger)tag
{
    if (_delegate && [_delegate respondsToSelector:@selector(filterView:didSelectedCell:selectedMenuIndex:)]) {
        self.selected = NO;
        //替换选中项
        [_selectedArray replaceObjectAtIndex:tag withObject:info];
        //实现代理，刷新Controller界面
        [_delegate filterView:self didSelectedCell:info selectedMenuIndex:tag];
    }
}

- (void)pullDownMenuWillDismiss:(PullDownMenu *)pullDownMenu
{
    self.selected = NO;
}

#pragma mark - Private

-(void)__showTableView:(UIButton*)sender
{
    if (_dataArray == nil) {
        return;
    }
    //已经显示下拉菜单
    if (sender.isSelected) {
        [PullDownMenu dismissActiveMenu:nil];
        sender.selected = NO;
        return;
    }
    self.selected = NO;

    [PullDownMenu showMenuBelowView:self
                              array:[_dataArray objectAtIndex:sender.tag]
                  selectedMenuIndex:sender.tag
                     selectedDetail:[_selectedArray objectAtIndex:sender.tag]
                           delegate:self];
    sender.selected = YES;
}

@end
