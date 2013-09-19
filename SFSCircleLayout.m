//
//  SFSCircleLayout.m
//  SFSCollectionMenu
//
//  Created by BJ Miller on 9/7/13.
//  Copyright (c) 2013 Six Five Software, LLC. All rights reserved.
//

#import "SFSCircleLayout.h"

#define CIRCLE_DIAMETER 70
#define IPAD_SCALE      6.0
#define IPHONE_SCALE    3.0

@implementation SFSCircleLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    CGSize size = self.collectionView.frame.size;
    _cellCount = [self.collectionView numberOfItemsInSection:0];
    _center = CGPointMake(size.width / 2.0, size.height / 2.0);
    _radius = MIN(size.width, size.height) / (([self isPhone]) ? IPHONE_SCALE : IPAD_SCALE); //3.0;
}

- (BOOL)isPhone {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
}

- (CGSize)collectionViewContentSize {
    return self.collectionView.frame.size;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = CGSizeMake(CIRCLE_DIAMETER, CIRCLE_DIAMETER);
    attributes.center = CGPointMake(CGRectGetMaxX(self.collectionView.frame), CGRectGetMaxY(self.collectionView.frame));
    [UIView animateWithDuration:2 animations:^{
        attributes.center = CGPointMake(self.center.x - self.radius * sinf(2 * indexPath.item * M_PI / self.cellCount),
                                        self.center.y - self.radius * cosf(2 * indexPath.item * M_PI / self.cellCount));
    } completion:^(BOOL finished) {
//        NSLog(@"done animating cell at indexPath: %@", indexPath);
    }];
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger i = 0; i < self.cellCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//    attributes.alpha = 0.0;
//    attributes.center = CGPointMake(CGRectGetMaxX(self.collectionView.frame), CGRectGetMaxY(self.collectionView.frame));
////    attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
//    return attributes;
//}

@end
