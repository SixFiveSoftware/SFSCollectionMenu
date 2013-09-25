//
//  SFSViewController.m
//  SFSCollectionMenu
//
//  Created by BJ Miller on 9/7/13.
//  Copyright (c) 2013 Six Five Software, LLC. All rights reserved.
//

#import "SFSViewController.h"
#import "SFSCollectionMenuController.h"

@interface SFSViewController () <SFSCollectionMenuDelegate>
@property (nonatomic, strong) SFSCollectionMenuController *collectionMenu;
@property (weak, nonatomic) IBOutlet UILabel *buttonTappedLabel;
- (IBAction)buttonTap:(id)sender;
@end

@implementation SFSViewController

- (IBAction)buttonTap:(id)sender {
    if (!_collectionMenu) {
        _collectionMenu = [[SFSCollectionMenuController alloc] initWithDelegate:self];
    }
    [self.collectionMenu showMenu];
}


#pragma mark - SFSCollectionMenuDelegate methods

- (UIView *)viewForMenu {
    return self.view;
}

- (NSInteger)numberOfButtonsInMenuController:(SFSCollectionMenuController *)controller {
    return 6;
}

- (UIImage *)imageForButtonAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *images = @[[UIImage imageNamed:@"camera"],
                        [UIImage imageNamed:@"chatBubble"],
                        [UIImage imageNamed:@"phone"],
                        [UIImage imageNamed:@"star"],
                        [UIImage imageNamed:@"tag"],
                        [UIImage imageNamed:@"voicemail"]];
    return images[indexPath.row];
}

- (UIColor *)backgroundColorForButtonAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
}

- (void)controller:(SFSCollectionMenuController *)controller didTapButtonAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [NSString stringWithFormat:@"Button %d tapped", indexPath.row];
    self.buttonTappedLabel.text = text;
}

- (NSString *)accessibilityLabelForButtonAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *labels = @[@"Camera",
                        @"Chat",
                        @"Phone",
                        @"Star",
                        @"Tag",
                        @"Voicemail"];
    return labels[indexPath.row];
}

- (NSString *)accessibilityHintForButtonAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *hints = @[@"Opens the camera",
                       @"Starts a chat session",
                       @"Opens the phone app",
                       @"Marks this as a favorite",
                       @"Tags this for later",
                       @"Opens the voicemail interface to listen to voicemails"];
    return hints[indexPath.row];
}

@end
