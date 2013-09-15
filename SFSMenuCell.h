//
//  SFSMenuCell.h
//  SFSCollectionMenu
//
//  Created by BJ Miller on 9/7/13.
//  Copyright (c) 2013 Six Five Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFSMenuCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *imageView;

- (void)setBackgroundColorForCell:(UIColor *)color;
- (void)setBackgroundImageForCell:(UIImage *)image;
- (void)setImageForCell:(UIImage *)image;

@end
