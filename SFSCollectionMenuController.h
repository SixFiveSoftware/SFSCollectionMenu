//
//  SFSCollectionMenuController.h
//  SFSCollectionMenu
//
//  Created by BJ Miller on 9/7/13.
//  Copyright (c) 2013 Six Five Software, LLC. All rights reserved.
//
//  SFSMenuController is an open-source control for a UICollectionView-based menu. It works by utilizing a delegate pattern
//   to allow you, the developer, the implement it easily and add your own code to customize its appearance and behavior.
//  SFSMenuController's designated initializer is -initWithDelegate, as the delegate is required for operation.
//
//  To use:
//   1. Add SFSCollectionMenuController.h/.m, SFSCircleLayout.h/.m, and SFSMenuCell.h/.m to your project.
//   2. Import SFSCollectionMenuController.h to your controller
//   3. Adhere to the SFSCollectionMenuDelegate protocol
//   4. Create an instance of the menu controller by [[SFSCollectionMenu alloc] initWithDelegate:self], or whatever object you designate
//      as the delegate
//   5. Implement the required methods, and any optional methods you wish
//   6. call -show on your instance of SFSCollectionMenu

#import <UIKit/UIKit.h>

@class SFSCollectionMenuController;


// Protocol for SFSCollectionMenu
//
// This protocol defines behavior the menu must adhere to, and can optionally adhere to,
//  to shape the way it is presented and behaves.
@protocol SFSCollectionMenuDelegate <NSObject>

@required

// controller:didTapButtonAtIndex: is what your controller must implement to tell the menu what action(s) to take
//  upon tapping a particular cell in the collectionView
- (void)controller:(SFSCollectionMenuController *)controller didTapButtonAtIndexPath:(NSIndexPath *)indexPath;

// numberOfButtonsInMenuController: is what your controller must implement to tell the menu how many buttons (cells)
//  you wish the menu to have
- (NSInteger)numberOfButtonsInMenuController:(SFSCollectionMenuController *)controller;

// imageForButtonAtIndexPath: is what your controller must implement to tell the menu what images to place on the buttons
//  (cells) for display. The cells are 70 points in diameter, so images smaller than that will work well.
- (UIImage *)imageForButtonAtIndexPath:(NSIndexPath *)indexPath;

// viewForMenu is what your controller must implement to tell the collectionView what from what view to display the menu
- (UIView *)viewForMenu;


@optional

// backgroundImageForButtonAtIndexPath: and backgroundColorForButtonAtIndexPath: are optional, and your controller can implement
//  them to change the display of the buttons (cells).
//  If backgroundImageForButtonAtIndexPath: is implemented in your controller, it will place whatever image is returned into the
//   cell's contentView's backgroundImage property.
//  If backgroundColorForButtonAtIndexPath: is implemented in your controller, it will remove any background image and set the cell's
//   contentView's backgroundColor property.
//  If neither is implemented, a standard grey color will be used for the background color of the cells.
- (UIImage *)backgroundImageForButtonAtIndexPath:(NSIndexPath *)indexPath;
- (UIColor *)backgroundColorForButtonAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface SFSCollectionMenuController : UICollectionViewController

@property (nonatomic, weak, readonly) id<SFSCollectionMenuDelegate> delegate;

- (instancetype)initWithDelegate:(id<SFSCollectionMenuDelegate>)delegate;
- (void)showMenu;
- (void)dismissMenu;

@end
