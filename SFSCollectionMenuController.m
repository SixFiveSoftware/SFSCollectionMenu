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

#define CELL_REUSE_ID @"Cell Reuse ID"

@interface SFSCollectionMenuController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView *viewDisplayingMenu;
@property (nonatomic, strong) SFSCircleLayout *circleLayout;
@property (nonatomic, assign, getter = isVisible) BOOL visible;

@end


@implementation SFSCollectionMenuController

@synthesize collectionView = _collectionView;

- (instancetype)initWithDelegate:(id<SFSCollectionMenuDelegate>)delegate {
    self = [self initWithCollectionViewLayout:[self circleLayout]];
    if (self) {
        _delegate = delegate;
        UIView *view = ([delegate respondsToSelector:@selector(viewForMenu)] ? [delegate viewForMenu] : self.view);
        _collectionView = [[UICollectionView alloc] initWithFrame:view.frame collectionViewLayout:[self circleLayout]];
        [self.collectionView setDelegate:self];
        [self.collectionView setDataSource:self];
        [self.collectionView registerClass:[SFSMenuCell class] forCellWithReuseIdentifier:CELL_REUSE_ID];
        [self.collectionView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.45]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];
        [tapGesture addTarget:self action:@selector(handleSingleTap:)];
        [self.collectionView addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.isVisible) {
        CGPoint touch = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touch];
        if (indexPath) {
            [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
        } else {
            [self dismissMenu];
        }
    }
}

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

- (void)showInView:(UIView *)view {
    self.viewDisplayingMenu = view;
    [view.window setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
    [self resetCells];
    [view addSubview:self.collectionView];
    self.visible = YES;
}

- (void)dismissMenu {
    [self.collectionView removeFromSuperview];
    [self.viewDisplayingMenu.window setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    self.viewDisplayingMenu = nil;
    self.visible = NO;
}


#pragma mark - UICollectionView delegate methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfButtonsInMenuController:)]) {
        return [self.delegate numberOfButtonsInMenuController:self];
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
