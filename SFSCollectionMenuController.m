//
//  SFSCollectionMenuController.m
//  SFSCollectionMenu
//
//  Created by BJ Miller on 9/7/13.
//  Copyright (c) 2013 Six Five Software, LLC. All rights reserved.
//

#import "SFSCollectionMenuController.h"
#import "SFSMenuCell.h"
#import "SFSCircleLayout.h"
#import "UIImage+ImageEffects.h"

#define CELL_REUSE_ID @"Cell Reuse ID"
#define MAX_CELLS 6

@interface SFSCollectionMenuController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView *viewDisplayingMenu;
@property (nonatomic, strong) SFSCircleLayout *circleLayout;
@property (nonatomic, assign, getter = isVisible) BOOL visible;
@property (nonatomic, strong) UIImageView *collectionViewBackgroundImageView;
@property (nonatomic) UIInterfaceOrientation currentOrientation;

@end


@implementation SFSCollectionMenuController

@synthesize collectionView = _collectionView;

#pragma mark - Initializer method
- (instancetype)initWithDelegate:(id<SFSCollectionMenuDelegate>)delegate {
    self = [self initWithCollectionViewLayout:[self circleLayout]];
    if (self) {
        _delegate = delegate;
        self.visible = NO;
    }
    
    return self;
}

- (void)setupCollectionView {
    self.viewDisplayingMenu = ([self.delegate respondsToSelector:@selector(viewForMenu)] ? [self.delegate viewForMenu] : self.view );
    if (_collectionView) {
        [self.collectionView setFrame:[self frameForViewForCurrentOrientation]];
    } else {
        _collectionView = [[UICollectionView alloc] initWithFrame:[self frameForViewForCurrentOrientation] collectionViewLayout:[self circleLayout]];
        [self.collectionView setDelegate:self];
        [self.collectionView setDataSource:self];
        [self.collectionView registerClass:[SFSMenuCell class] forCellWithReuseIdentifier:CELL_REUSE_ID];
        
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];
        [tapGesture addTarget:self action:@selector(handleSingleTap:)];
        [self.collectionView addGestureRecognizer:tapGesture];
    }
}

#pragma mark - Orientation
- (void)orientationChanged:(NSNotification *)notification {
    NSLog(@"notification: %@", [notification userInfo]);
    UIInterfaceOrientation newOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (self.isVisible && (newOrientation != self.currentOrientation)) {
        [self dismissMenuWithCompletion:^ {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMenu];
                [self.collectionView reloadData];
                self.currentOrientation = newOrientation;
            });
        }];
    }
}

- (CGRect)frameForViewForCurrentOrientation {
    CGRect frame = CGRectZero;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        frame = self.viewDisplayingMenu.frame;
    } else if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        frame = CGRectMake(self.viewDisplayingMenu.frame.origin.x,
                           self.viewDisplayingMenu.frame.origin.y,
                           self.viewDisplayingMenu.frame.size.height,
                           self.viewDisplayingMenu.frame.size.width);
    }
    
    return frame;
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.isVisible) {
        CGPoint touch = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touch];
        if (indexPath) {
            [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
        } else {
            [self dismissMenuWithCompletion:^{
                NSLog(@"dismissed menu from handleSingleTap:");
            }];
        }
    }
}


#pragma mark - Menu methods
- (SFSCircleLayout *)circleLayout {
    if (_circleLayout) return _circleLayout;
    
    _circleLayout = [[SFSCircleLayout alloc] init];
    return _circleLayout;
}

- (void)resetCells {
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setAlpha:1.0];
    }];
}

- (UIImage *)blurredImageFromContext {
    CGRect bounds = [self frameForViewForCurrentOrientation];
    CGSize size = bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self.viewDisplayingMenu drawViewHierarchyInRect:CGRectMake(0, 0, size.width, size.height) afterScreenUpdates:YES];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // apply effect
    UIImage *lightImage = [newImage applyLightEffect];
    return lightImage;
}

- (void)setBackgroundViewForCollectionWithImage:(UIImage *)image {
    if (!_collectionViewBackgroundImageView) {
        _collectionViewBackgroundImageView = [[UIImageView alloc] initWithImage:image];
    } else {
        [self.collectionViewBackgroundImageView setFrame:[self frameForViewForCurrentOrientation]];
        [self.collectionViewBackgroundImageView setImage:image];
    }
}

- (void)showMenu {
    if (!self.isVisible) {
        
        [self setupCollectionView];

        [self resetCells];
        
        self.currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];

        // blur background
        //
        // grab view context and set to image
        UIImage *lightImage = [self blurredImageFromContext];
        
        // set blurred image to custom image view
        [self setBackgroundViewForCollectionWithImage:lightImage];
        
        // animate display of blur and menu
        [self.collectionViewBackgroundImageView setAlpha:0.0];
        [self.collectionView setAlpha:0.0];
        
        [self.viewDisplayingMenu addSubview:self.collectionViewBackgroundImageView];
        [self.viewDisplayingMenu addSubview:self.collectionView];
        
        [UIView animateWithDuration:0.1 animations:^{
            [self.collectionViewBackgroundImageView setAlpha:1.0];
            [self.collectionView setAlpha:1.0];
        } completion:^(BOOL finished) {
            self.visible = YES;
            [self.collectionView reloadData];
        }];
    }
}

- (void)dismissMenu {
    [self dismissMenuWithCompletion:^{
        NSLog(@"dismissed menu.");
    }];
}

- (void)dismissMenuWithCompletion:(void (^)(void))completion {
    if (self.isVisible) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.collectionView setAlpha:0.0];
            [self.collectionViewBackgroundImageView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.collectionView removeFromSuperview];
            [self.collectionViewBackgroundImageView removeFromSuperview];
            [self.viewDisplayingMenu.window setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
            self.collectionViewBackgroundImageView = nil;
            self.visible = NO;
            if (completion) completion();
        }];
    }
}


#pragma mark - UICollectionView delegate methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(numberOfButtonsInMenuController:)]) {
            NSInteger numCells = [self.delegate numberOfButtonsInMenuController:self];
            if (numCells > MAX_CELLS) {
                numCells = MAX_CELLS;
            }
            return numCells;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SFSMenuCell *cell = (SFSMenuCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_ID forIndexPath:indexPath];
    if (self.delegate) {
        //background image
        if ([self.delegate respondsToSelector:@selector(backgroundImageForButtonAtIndexPath:)]) {
            [cell setBackgroundImageForCell:[self.delegate backgroundImageForButtonAtIndexPath:indexPath]];
        }
        
        if ([self.delegate respondsToSelector:@selector(backgroundColorForButtonAtIndexPath:)]) {
            [cell setBackgroundImageForCell:nil];
            [cell setBackgroundColorForCell:[self.delegate backgroundColorForButtonAtIndexPath:indexPath]];
        }
        
        // foreground image
        if ([self.delegate respondsToSelector:@selector(imageForButtonAtIndexPath:)]) {
            [cell setImageForCell:[self.delegate imageForButtonAtIndexPath:indexPath]];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *indexPathsForButtons = [[self.collectionView indexPathsForVisibleItems] mutableCopy];
    [indexPathsForButtons removeObject:indexPath];
    SFSMenuCell *selectedCell = (SFSMenuCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSMutableArray *unselectedCells = [[self.collectionView visibleCells] mutableCopy];
    [unselectedCells removeObject:selectedCell];
    CGRect selectedCellOriginalRect = selectedCell.frame;
    
    [UIView animateWithDuration:0.2 animations:^{
        selectedCell.center = self.collectionView.center;
        [unselectedCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setAlpha:0.0];
        }];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.05 delay:0.15 options:UIViewAnimationOptionCurveLinear animations:^{
            [selectedCell setAlpha:0.25];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [selectedCell setAlpha:1.0];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [selectedCell setAlpha:0.0];
                } completion:^(BOOL finished) {
                    if ([self.delegate respondsToSelector:@selector(controller:didTapButtonAtIndexPath:)]) {
                        [self.delegate controller:self didTapButtonAtIndexPath:indexPath];
                    }
                    [self dismissMenu];
                    [selectedCell setFrame:selectedCellOriginalRect];
                }];
            }];
        }];
    }];
    
}


@end
