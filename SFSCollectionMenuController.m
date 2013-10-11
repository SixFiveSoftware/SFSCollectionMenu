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
#import <AVFoundation/AVSpeechSynthesis.h>
#import "UIImage+ImageEffects.h"

#define CELL_REUSE_ID @"Cell Reuse ID"
#define MAX_CELLS 6
#define IPHONE_LABEL_OFFSET 200
#define IPAD_LABEL_OFFSET   275

@interface SFSCollectionMenuController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView *viewDisplayingMenu;
@property (nonatomic, strong) SFSCircleLayout *circleLayout;
@property (nonatomic, assign, getter = isVisible) BOOL visible;
@property (nonatomic, strong) UIImageView *collectionViewBackgroundImageView;
@property (nonatomic) UIInterfaceOrientation currentOrientation;
@property (nonatomic, strong) UIButton *closeButton;

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
        
        // set the Accessibility View to modal so views below it are not read by VoiceOver
        [self.collectionView setAccessibilityViewIsModal:YES];
        
        // set the label
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(labelTextForMenu)]) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = [self.delegate labelTextForMenu];
                [label setFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
                [label sizeToFit];
                if ([self.delegate respondsToSelector:@selector(colorForLabelText)]) {
                    [label setTextColor:[self.delegate colorForLabelText]];
                }
                CGSize labelSize = label.frame.size;
                CGPoint labelOrigin = CGPointZero;
                CGFloat x, y;
                x = self.collectionView.center.x - (labelSize.width / 2);
                y = self.collectionView.center.y - (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? IPHONE_LABEL_OFFSET : IPAD_LABEL_OFFSET);
                labelOrigin.x = x;
                labelOrigin.y = y;
                [label setFrame:CGRectMake(labelOrigin.x, labelOrigin.y, labelSize.width, labelSize.height)];
                
                // set accessibility label and hint for label
                if ([self.delegate respondsToSelector:@selector(accessibilityLabelForMenuLabel)]) {
                    [label setAccessibilityLabel:[self.delegate accessibilityLabelForMenuLabel]];
                }
                if ([self.delegate respondsToSelector:@selector(accessibilityHintForMenuLabel)]) {
                    [label setAccessibilityHint:[self.delegate accessibilityHintForMenuLabel]];
                }
                
                // add to collectionView
                [self.collectionView addSubview:label];
            }
        }
        
        // register for Accessibility notification for changes in VoiceOver
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceOverChanged) name:UIAccessibilityVoiceOverStatusChanged object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];
        [tapGesture addTarget:self action:@selector(handleSingleTap:)];
        [self.collectionView addGestureRecognizer:tapGesture];
    }
}

#pragma mark - Accessibility
- (void)speakSelected {
    if (UIAccessibilityIsVoiceOverRunning()) {
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"button selected"];
        [synthesizer speakUtterance:utterance];
    }
}

- (void)voiceOverChanged {
    [self showCloseButton:UIAccessibilityIsVoiceOverRunning()];
}

- (void)showCloseButton:(BOOL)showButton {
    if (showButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setAccessibilityLabel:@"Close"];
        [self.closeButton setAccessibilityHint:@"Closes the menu"];
        [self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.closeButton setIsAccessibilityElement:YES];
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(imageForCloseButton)]) {
                UIImage *closeImage = [self.delegate imageForCloseButton];
                [self.closeButton setImage:closeImage forState:UIControlStateNormal];
                CGPoint centerPoint = self.collectionView.center;
                [self.closeButton setFrame:CGRectMake(centerPoint.x - (closeImage.size.width / 2.0),
                                                      centerPoint.y - (closeImage.size.height / 2.0),
                                                      closeImage.size.width,
                                                      closeImage.size.height)];
            }
        }
        [self.collectionView addSubview:self.closeButton];
    } else {
        [self.closeButton removeFromSuperview];
        self.closeButton = nil;
    }
}

- (void)closeButtonTapped {
    [self dismissMenuWithCompletion:^{
        AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
        AVSpeechUtterance *utter = [AVSpeechUtterance speechUtteranceWithString:@"Menu closed."];
        [synth speakUtterance:utter];
    }];
}

#pragma mark - Orientation

// check for orientation type. the UIDeviceOrientationDidChangeNotification sends notifications even for accelerometer changes, like tilting.
//  this method makes sure it's only an interface orientation change.
- (void)orientationChanged:(NSNotification *)notification {
    UIInterfaceOrientation newOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (self.isVisible && (newOrientation != self.currentOrientation)) {
        [self dismissMenuWithCompletion:^{
            NSLog(@"dismissed menu from orientationChanged:");
            self.currentOrientation = newOrientation;
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
                self.currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            }];
        }
    }
}


#pragma mark - Menu methods
- (BOOL)isVisible {
    return _visible;
}

- (SFSCircleLayout *)circleLayout {
    if (_circleLayout) return _circleLayout;
    
    _circleLayout = [[SFSCircleLayout alloc] init];
    return _circleLayout;
}

- (UIImage *)blurredImageFromContextWithLightEffect:(SFSLightEffectType)lightEffect {
    CGRect bounds = [self frameForViewForCurrentOrientation];
    CGSize size = bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self.viewDisplayingMenu drawViewHierarchyInRect:CGRectMake(0, 0, size.width, size.height) afterScreenUpdates:YES];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // apply effect
    UIImage *blurredImage = nil;
    switch (lightEffect) {
        case SFSLightEffectTypeDark:
            blurredImage = [newImage applyDarkEffect];
            break;
        case SFSLightEffectTypeExtraLight:
            blurredImage = [newImage applyExtraLightEffect];
            break;
        case SFSLightEffectTypeLight:
            blurredImage = [newImage applyLightEffect];
            break;
        case SFSLightEffectTypeMediumLight:
            blurredImage = [newImage applyMediumLightEffect];
            break;
        default:
            blurredImage = [newImage applyLightEffect];
            break;
    }
    return blurredImage;
}

- (void)setBackgroundViewForCollectionWithImage:(UIImage *)image {
    if (!_collectionViewBackgroundImageView) {
        _collectionViewBackgroundImageView = [[UIImageView alloc] initWithImage:image];
    } else {
        [self.collectionViewBackgroundImageView setFrame:[self frameForViewForCurrentOrientation]];
        [self.collectionViewBackgroundImageView setImage:image];
    }
}

- (void)showMenuWithLightEffect:(SFSLightEffectType)lightEffect {
    if (!self.isVisible) {
        
        [self setupCollectionView];

        self.currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];

        // blur background
        //
        // grab view context and set to image
        UIImage *lightImage = [self blurredImageFromContextWithLightEffect:lightEffect];
        
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
            [self voiceOverChanged];
            self.visible = YES;
            [self.collectionView reloadData];
            [self isAccessibilityElement];
            [self setAccessibilityViewIsModal:YES];
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
            [self voiceOverChanged];
            [self.collectionView removeFromSuperview];
            [self.collectionViewBackgroundImageView removeFromSuperview];
            [self.viewDisplayingMenu.window setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
            self.collectionViewBackgroundImageView = nil;
            self.collectionView = nil;  // this is to make sure menu does not initially draw in previous coordinate then awkwardly shift to right place
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
        
        // Accessibility label
        if ([self.delegate respondsToSelector:@selector(accessibilityLabelForButtonAtIndexPath:)]) {
            [cell setAccessibilityLabel:[self.delegate accessibilityLabelForButtonAtIndexPath:indexPath]];
        }
        
        // Accessibility hint
        if ([self.delegate respondsToSelector:@selector(accessibilityHintForButtonAtIndexPath:)]) {
            [cell setAccessibilityHint:[self.delegate accessibilityHintForButtonAtIndexPath:indexPath]];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // remove close button first so it does not display over top of animated button
    if (self.closeButton.window) {
        [self showCloseButton:NO];
    }
    
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
                    [self speakSelected];
                    [self dismissMenu];
                    [selectedCell setFrame:selectedCellOriginalRect];
                }];
            }];
        }];
    }];
    
}


@end
