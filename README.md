SFSCollectionMenu
=================

An open-source menu control for iOS utilizing UICollectionView layout.

SFSMenuController is an open-source control for a UICollectionView-based menu. It works by utilizing a delegate pattern
to allow you, the developer, the implement it easily and add your own code to customize its appearance and behavior.
SFSMenuController's designated initializer is -initWithDelegate, as the delegate is required for operation.

To use:
1. Add SFSCollectionMenuController.h/.m, SFSCircleLayout.h/.m, and SFSMenuCell.h/.m to your project.
2. Import SFSCollectionMenuController.h to your controller
3. Adhere to the SFSCollectionMenuDelegate protocol
4. Create an instance of the menu controller by [[SFSCollectionMenu alloc] initWithDelegate:self], or whatever object you designate
as the delegate
5. Implement the required methods, and any optional methods you wish
6. call -show on your instance of SFSCollectionMenu
