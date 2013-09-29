//
//  SFSCollectionMenuController.h
//  SFSCollectionMenu
//
//  Created by BJ Miller on 9/7/13.
//  Copyright (c) 2013 Six Five Software, LLC. All rights reserved.
//
//  SFSCollectionMenuController is an open-source control for a UICollectionView-based menu. It works by utilizing a delegate pattern
//   to allow you, the developer, the implement it easily and add your own code to customize its appearance and behavior.
//  SFSCollectionMenuController's designated initializer is -initWithDelegate, as the delegate is required for operation.
//  SFSCollectionMenuController is modal, meaning that the user cannot interact with their app unless the menu is dismissed. The controller has a tap
//      gesture recognizer to handle taps inside and outside of the menu. Tapping outside of any cell/button will dismiss the menu.
//
//  To use:
//   1. Add SFSCollectionMenuController.h/.m, SFSCircleLayout.h/.m, and SFSMenuCell.h/.m to your project.
//   2. Import SFSCollectionMenuController.h to your controller
//   3. Adhere to the SFSCollectionMenuDelegate protocol
//   4. Create an instance of the menu controller by [[SFSCollectionMenu alloc] initWithDelegate:self], or whatever object you designate
//      as the delegate
//   5. Implement the required methods, and any optional methods you wish
//   6. call -showMenu on your instance of SFSCollectionMenu

#import <UIKit/UIKit.h>

@class SFSCollectionMenuController;


// Protocol for SFSCollectionMenu
//
// This protocol defines behavior the menu must adhere to, and can optionally adhere to,
//  to shape the way it is presented and behaves.
@protocol SFSCollectionMenuDelegate <NSObject>

@required

// -controller:didTapButtonAtIndex: is what your controller must implement to tell the menu what action(s) to take
//  upon tapping a particular cell in the collectionView
// -numberOfButtonsInMenuController: is what your controller must implement to tell the menu how many buttons (cells)
//  you wish the menu to have. Current max is 6.
// -imageForButtonAtIndexPath: is what your controller must implement to tell the menu what images to place on the buttons
//  (cells) for display. The cells are 70 points in diameter, so images smaller than that will work well.
// -viewForMenu is what your controller must implement to tell the collectionView what from what view to display the menu
- (void)controller:(SFSCollectionMenuController *)controller didTapButtonAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfButtonsInMenuController:(SFSCollectionMenuController *)controller;
- (UIImage *)imageForButtonAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)viewForMenu;

// Accessibility methods
//  -accessibilityLabelForButtonAtIndexPath: you must provide a short label which VoiceOver will read aloud, quickly telling low-vision users what the control is.
//  -accessibilityHintForButtonAtIndexPath: you must provide a brief sentence which VoiceOver will read aloud, after a short pause from reading the accessibility label. This is to further explain what the control does.
//  -imageForCloseButton is added to the Accessibility section because it is necessary for proper Accessibility navigation. You can provide an image that matches your theme.
- (NSString *)accessibilityLabelForButtonAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)accessibilityHintForButtonAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)imageForCloseButton;

@optional

// -backgroundImageForButtonAtIndexPath: and -backgroundColorForButtonAtIndexPath: are optional, and your controller can implement
//  them to change the display of the buttons (cells).
//  If -backgroundImageForButtonAtIndexPath: is implemented in your controller, it will place whatever image is returned into the
//   cell's contentView's backgroundImage property.
//  If -backgroundColorForButtonAtIndexPath: is implemented in your controller, it will remove any background image and set the cell's
//   contentView's backgroundColor property.
//  If neither is implemented, a standard grey color will be used for the background color of the cells.
- (UIImage *)backgroundImageForButtonAtIndexPath:(NSIndexPath *)indexPath;
- (UIColor *)backgroundColorForButtonAtIndexPath:(NSIndexPath *)indexPath;

@end


// Public interface for SFSCollectionMenuController
//
// Declares:
//  properties:
//      delegate - your controller must set itself, or another object, as the delegate, and adopt the SFSCollectionMenuDelegate protocol
//
//  methods:
//
//      -initWithDelegate: - this is the designated initializer for this class, and you should call this from your controller to initialize the menu
//      -showMenu - call this on the instance of SFSCollectionMenuController to make the menu visible to the user
//      -dismissMenu - call this on the instance of SFSCollectionMenuController to dismiss the menu and return normal control back to the user
//      -dismissMenuWithCompletion:(void (^)(void))completion - call this on the instance of SFSCollectionMenuController to dismiss the menu,
//          run any custom code you wish upon completion (WARNING: this is still in background thread. Any UI manipulation must dispatch
//          back to the main thread), and then return normal control back to the user.
//      -isVisible - this will return YES or NO depending on if the menu controller is visible or not
//  Under normal circumstances, you shouldn't need to call -dismissMenu or -dismissMenuWithCompletion:; the menu will dismiss automatically
//      upon choosing a cell or tapping outside the menu.
@interface SFSCollectionMenuController : UICollectionViewController

@property (nonatomic, weak, readonly) id<SFSCollectionMenuDelegate> delegate;

- (instancetype)initWithDelegate:(id<SFSCollectionMenuDelegate>)delegate;
- (void)showMenu;
- (void)dismissMenu;
- (void)dismissMenuWithCompletion:(void (^)(void))completion;
- (BOOL)isVisible;

@end
