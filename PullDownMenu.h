//
//  PullDownMenu.h
//  Example
//
//  Created by llwang on 13-11-18.
//  Copyright (c) 2013年 Toursprung. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPullDownKey @"ID"
#define kPullDownValue @"Title"
#define kPullDownChildren @"Children"

@class PullDownMenu;

@protocol PullDownMenuDelegate<NSObject>

@optional
-(void)pullDownMenu:(PullDownMenu*)pullDownMenu didSelectedCell:(NSDictionary*)info selectedMenuIndex:(NSInteger)tag;
-(void)pullDownMenuWillDismiss:(PullDownMenu*)pullDownMenu;
-(void)pullDownMenuDidDismiss:(PullDownMenu*)pullDownMenu;

@end

@interface PullDownMenu : NSObject

@property (assign, nonatomic) id<PullDownMenuDelegate> delegate;

+ (instancetype)sharedMenu;

/** Shows a notification message in a specific view controller
 @param viewController The view controller to show the notification in.
 @param title The title of the notification view
 @param subtitle The message that is displayed underneath the title (optional)
 @param image A custom icon image (optional)
 @param type The notification type (Message, Warning, Error, Success)
 @param duration The duration of the notification being displayed
 @param callback The block that should be executed, when the user tapped on the message
 @param buttonTitle The title for button (optional)
 @param buttonCallback The block that should be executed, when the user tapped on the button
 @param messagePosition The position of the message on the screen
 @param dismissingEnabled Should the message be dismissed when the user taps/swipes it
 */
+ (void)showMenuBelowView:(UIView *)filterView
                    array:(NSArray *)array
        selectedMenuIndex:(NSInteger)tag
           selectedDetail:(NSDictionary*)selectedDetail
                 delegate:(id<PullDownMenuDelegate>)delegate;


/** Fades out the currently displayed notification. If another notification is in the queue,
 the next one will be displayed automatically
 @return YES if the currently displayed notification was successfully dismissed. NO if no notification
 was currently displayed.
 */
+ (void)dismissActiveMenu:(void (^)(BOOL finished))completion;
+ (void)dismissActiveMenu;

/** Use this method to set a default view controller to display the messages in */
//+ (void)setDefaultViewController:(UIViewController *)defaultViewController;

/** Indicates whether a notification is currently active. */
+ (BOOL)isMenuActive;

/** Indicates whether currently the iOS 7 style of TSMessages is used
 This depends on the Base SDK and the currently used device */
//+ (BOOL)iOS7StyleEnabled;

@end
