//
//  PullDownMenu.m
//  Example
//
//  Created by llwang on 13-11-18.
//  Copyright (c) 2013年 Toursprung. All rights reserved.
//

#import "PullDownMenu.h"

#define kPullDownMenuAnimationDuration 0.3
#define TABLEVIEW_HEIGHT (iPhone5?300:250)

@interface PullDownMenu() <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_dataArray;
    NSDictionary *_selectedDetail;
    BOOL _haveSub;

}

//整个界面容器View
@property (nonatomic, strong) UIView *currentMenuView;
//TableView的容器View
@property (strong, nonatomic) UIView *superViewOfTableView;
//filterView下显示PullDownMenu
@property (nonatomic, strong) UIView *filterView;
//点击消失menuView
@property (nonatomic, strong) UIButton *dismissButton;
//两个TableView
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) UITableView *subTableView;

@property (nonatomic, assign) NSInteger selectedMainRow;
@property (nonatomic, assign) NSInteger selectedMenuIndex;

- (void)fadeInCurrentMenu:(UIView *)menuView;
- (void)fadeOutMenu:(void (^)(BOOL finished))completion;
- (void)fadeOutMenu;

@end

@implementation PullDownMenu

//单例模式，获取PullDownMenu
+ (PullDownMenu *)sharedMenu
{
    static PullDownMenu *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)showMenuBelowView:(UIView *)filterView
                    array:(NSArray *)array
        selectedMenuIndex:(NSInteger)tag
           selectedDetail:(NSDictionary*)selectedDetail
                 delegate:(id<PullDownMenuDelegate>)delegate
{
    //创建下拉菜单的View
    UIView *v = [[PullDownMenu sharedMenu] createPullDownMenuView:array//TableView显示数据
                                                selectedMenuIndex:tag
                                                   selectedDetail:selectedDetail//选中Cell数据
                                                         delegate:delegate];
    //设置下拉菜单的坐标
    [PullDownMenu sharedMenu].filterView = filterView;
    //显示View
    [[PullDownMenu sharedMenu] prepareMenuToBeShown:v];
}

- (void)prepareMenuToBeShown:(UIView *)menuView
{
    [[PullDownMenu sharedMenu] fadeInCurrentMenu:menuView];
}

+ (void)dismissActiveMenu:(void (^)(BOOL finished))completion
{
    [[PullDownMenu sharedMenu] fadeOutMenu:completion];
}

+ (void)dismissActiveMenu
{
    [[PullDownMenu sharedMenu] fadeOutMenu];
}

+ (BOOL)isMenuActive
{
    return [PullDownMenu sharedMenu].currentMenuView != nil;
}

- (void)fadeOutMenu
{
    [UIView animateWithDuration:kPullDownMenuAnimationDuration animations:^{
        _currentMenuView.alpha = 0;
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(pullDownMenuWillDismiss:)]) {
            [_delegate pullDownMenuWillDismiss:self];
        }
        [_currentMenuView removeFromSuperview];
        if (_delegate && [_delegate respondsToSelector:@selector(pullDownMenuDidDismiss:)]) {
            [_delegate pullDownMenuDidDismiss:self];
        }
        _currentMenuView = nil;

    }];
}

- (void)fadeOutMenu:(void (^)(BOOL finished))completion
{
    if (_currentMenuView != nil) {
        [_currentMenuView removeFromSuperview];
        _currentMenuView = nil;
    }
}

- (void)hideTableView:(void (^)(void))completion
{
    [UIView animateWithDuration:0.0f
                     animations:^{
                         [_currentMenuView viewWithTag:999].frame = CGRectMake(0, -TABLEVIEW_HEIGHT, 320, TABLEVIEW_HEIGHT);
                     }
                     completion:^(BOOL finished){
                         completion();
                     }];
}

- (void)fadeInCurrentMenu:(UIView*)backView
{
    //当前有下拉菜单，则先设置_currentMenuView = nil
    if ([_currentMenuView viewWithTag:999] && [_currentMenuView viewWithTag:999].frame.origin.y == 44) {
        
        [[PullDownMenu sharedMenu] hideTableView:^(){
            [[PullDownMenu sharedMenu] fadeInCurrentMenu:backView];
        }];
        return;
    }
    
    _currentMenuView = backView;
    __block CGFloat verticalOffset = _filterView.frame.origin.y + _filterView.frame.size.height;
    
    [_filterView.superview insertSubview:backView belowSubview:_filterView];

    //选中的选项的显示
    [self selectRowForSelectedDetail];
    //设置Frame
    CGPoint toPoint = CGPointMake(backView.center.x, verticalOffset + CGRectGetHeight([backView viewWithTag:999].frame) / 2.0);
    dispatch_block_t animationBlock = ^{
        [backView viewWithTag:999].center = toPoint;
        _dismissButton.alpha = 0.6f;
        
    };
    void(^completionBlock)(BOOL) = ^(BOOL finished) {
        
    };
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:animationBlock
                     completion:completionBlock];
}

- (UIView*)createPullDownMenuView:(NSArray *)array
               selectedMenuIndex:(NSInteger)tag
                  selectedDetail:(NSDictionary*)selectedDetail
                        delegate:(id<PullDownMenuDelegate>)delegate
{
    //整个view，包括dismisButton，TableView
    UIView *containerView;
    _dataArray = array;
    _selectedMenuIndex = tag;
    _selectedDetail = selectedDetail;
    _delegate = delegate;
    _haveSub = [[array lastObject] objectForKey:kPullDownChildren]==nil?NO:YES;
    //已经显示PullDownMenu
    if (_currentMenuView == nil) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        containerView.backgroundColor = [UIColor clearColor];//[[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissButton.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
        _dismissButton.backgroundColor = [UIColor blackColor];
        _dismissButton.alpha = 0.0f;
        [_dismissButton addTarget:self
                           action:@selector(fadeOutMenu)
                 forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:_dismissButton];
        
        UIView *backgroundViewTemp = [[UIView alloc] initWithFrame:CGRectMake(0, -TABLEVIEW_HEIGHT, 320, TABLEVIEW_HEIGHT)];
        backgroundViewTemp.tag = 999;
        [containerView addSubview:backgroundViewTemp];
    } else {
        containerView = _currentMenuView;
    }
    UIView *backgroundView = [containerView viewWithTag:999];
    backgroundView.backgroundColor = _haveSub?[UIColor cloudsColor]:[UIColor whiteColor];
    if (_haveSub) {
        [_mainTableView removeFromSuperview];
        _mainTableView = nil;
        
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 120, TABLEVIEW_HEIGHT) style:UITableViewStylePlain];
        _mainTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.showsHorizontalScrollIndicator = NO;
        _mainTableView.showsVerticalScrollIndicator = NO;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.backgroundView = nil;
        [backgroundView addSubview:_mainTableView];
        
        [_subTableView removeFromSuperview];
        _subTableView = nil;
        
        _subTableView = [[UITableView alloc] initWithFrame:CGRectMake(120, 0, 200, TABLEVIEW_HEIGHT) style:UITableViewStylePlain];
        _subTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _subTableView.dataSource = self;
        _subTableView.delegate = self;
        _subTableView.showsHorizontalScrollIndicator = NO;
        _subTableView.showsVerticalScrollIndicator = NO;
        _subTableView.backgroundColor = [UIColor whiteColor];
        _subTableView.backgroundView = nil;
        _subTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [backgroundView addSubview:_subTableView];
        
    } else {
        [_mainTableView removeFromSuperview];
        _mainTableView = nil;
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, TABLEVIEW_HEIGHT) style:UITableViewStylePlain];
        _mainTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.showsHorizontalScrollIndicator = NO;
        _mainTableView.showsVerticalScrollIndicator = NO;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.backgroundView = nil;
        [backgroundView addSubview:_mainTableView];
    }
    return containerView;
}

/**
 *  选中已选择的菜单项
 */
- (void)selectRowForSelectedDetail
{
    if (_haveSub) {
        if ([_selectedDetail isEqualToDictionary:@{}]) {
            _selectedMainRow = 0;
            [_mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                        animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            [_subTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                       animated:NO scrollPosition:UITableViewScrollPositionTop];
            return;
        }
        
        for (int i=0; i<_dataArray.count; i++)
        {
            NSDictionary* mainDetail = [_dataArray objectAtIndex:i];
            NSArray* children = [mainDetail objectForKey:kPullDownChildren];
            BOOL isFoundSub = NO;
            int j = 0;
            for (NSDictionary* childDetail in children)
            {
                if ([_selectedDetail objectForKey:@"Title"] == nil) {
                    break;
                }
                if ([[childDetail objectForKey:@"Title"] isEqualToString:[_selectedDetail objectForKey:@"Title"]]) {
                    isFoundSub = YES;
                    break;
                }
                j++;
            }
            if (isFoundSub) {
                _selectedMainRow = i;
                [_mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                            animated:NO scrollPosition:UITableViewScrollPositionMiddle];
                [_subTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0]
                                           animated:NO scrollPosition:UITableViewScrollPositionTop];
                break;
            }
        }
    } else {
        int i=0;
        for (NSDictionary* detail in _dataArray)
        {
            if ([_selectedDetail objectForKey:@"Title"] == nil) {
                break;
            }
            if ([[detail objectForKey:@"Title"] isEqualToString:[_selectedDetail objectForKey:@"Title"]]) {
                [_mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                            animated:NO scrollPosition:UITableViewScrollPositionMiddle];
                break;
            }
            i++;
        }
        [_mainTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                    animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

#pragma mark - TabelView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _mainTableView) {
        return _dataArray.count;
    } else {
        return [[[_dataArray objectAtIndex:_selectedMainRow] objectForKey:kPullDownChildren]count];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _mainTableView) {
        cell.backgroundColor =  _haveSub?[UIColor clearColor]:[UIColor whiteColor];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _mainTableView) {
        static NSString* mainCellIdentifier = @"mainCellIdentifier";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mainCellIdentifier];
            if (_haveSub) {
                [cell configureFlatCellWithColor:[UIColor clearColor] selectedColor:[UIColor whiteColor] position:FUICellBackgroundViewPositionSingle];
            } else {
                [cell configureFlatCellWithColor:[UIColor clearColor] selectedColor:[UIColor clearColor]
                                       textColor:[UIColor blackColor] highlightTextColor:COLOR_THEME];
            }
            cell.textLabel.font = [UIFont systemFontOfSize:16];
        }
        cell.textLabel.text = [[_dataArray objectAtIndex:indexPath.row] objectForKey:kPullDownValue];
        return cell;
    } else {
        static NSString* subCellIdentifier = @"subCellIdentifier";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:subCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subCellIdentifier];
            [cell configureFlatCellWithColor:[UIColor clearColor] selectedColor:[UIColor clearColor]
                                   textColor:[UIColor blackColor] highlightTextColor:COLOR_THEME];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
        }
        cell.textLabel.text = [[[[_dataArray objectAtIndex:_selectedMainRow] objectForKey:kPullDownChildren]
                                objectAtIndex:indexPath.row] objectForKey:kPullDownValue];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(pullDownMenu:didSelectedCell:selectedMenuIndex:)]) {
        NSDictionary* info = nil;
        if (tableView == _mainTableView) {
            if (_haveSub) {
                _selectedMainRow = indexPath.row;
                [_subTableView reloadData];
                return;
            } else {
                info = [_dataArray objectAtIndex:indexPath.row];
                [_delegate pullDownMenu:nil didSelectedCell:info selectedMenuIndex:_selectedMenuIndex];
            }
        } else {
            info = [[[_dataArray objectAtIndex:_selectedMainRow] objectForKey:kPullDownChildren] objectAtIndex:indexPath.row];
            [_delegate pullDownMenu:nil didSelectedCell:info selectedMenuIndex:_selectedMenuIndex];
        }
        [[PullDownMenu sharedMenu] fadeOutMenu];
    }
}

@end
