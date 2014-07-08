//
//  FilterView.h
//  IFlying
//
//  Created by llwang on 13-11-21.
//  Copyright (c) 2013年 com.iflying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullDownMenu.h"

@class FilterView;

@protocol FilterViewDelegate <NSObject>

@optional
-(void)filterView:(FilterView*)filterView didSelectedCell:(NSDictionary*)info selectedMenuIndex:(NSInteger)tag;
//-(void)filterViewWillDismiss;
@end

@interface FilterView : UIView

@property (strong, nonatomic) NSArray *dataArray;

@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL selected;

@property (assign, nonatomic) id<FilterViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
   buttonTitleArray:(NSArray*)titleArray
    dataSourceArray:(NSArray*)dataArray
           delegate:(id<FilterViewDelegate>)delegate;

@end
