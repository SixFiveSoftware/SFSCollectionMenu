//
//  SFSCollectionMenuController.h
//  SFSCollectionMenu
//
//  Created by BJ Miller on 9/7/13.
//  Copyright (c) 2013 Six Five Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFSCollectionMenuController;

@protocol SFSCollectionMenuDelegate <NSObject>

@required
- (void)controller:(SFSCollectionMenuController *)controller didTapButtonAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfButtonsInMenuController:(SFSCollectionMenuController *)controller;
- (UIImage *)imageForButtonAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)viewForMenu;

@optional
- (UIImage *)backgroundImageForButtonAtIndexPath:(NSIndexPath *)indexPath;
- (UIColor *)backgroundColorForButtonAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface SFSCollectionMenuController : UICollectionViewController

@property (nonatomic, weak, readonly) id<SFSCollectionMenuDelegate> delegate;

- (instancetype)initWithDelegate:(id<SFSCollectionMenuDelegate>)delegate;
- (void)showInView:(UIView *)view;
- (void)dismissMenu;

@end
