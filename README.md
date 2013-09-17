SFSCollectionMenu
=================

An open-source menu control for iOS utilizing UICollectionView layout.

SFSCollectionMenuController is an open-source control for a UICollectionView-based menu. It works by utilizing a delegate pattern
to allow you, the developer, the implement it easily and add your own code to customize its appearance and behavior.
SFSCollectionMenuController's designated initializer is -initWithDelegate, as the delegate is required for operation.

####To use:  
1. Add SFSCollectionMenuController.h/.m, SFSCircleLayout.h/.m, and SFSMenuCell.h/.m to your project  
2. Import SFSCollectionMenuController.h to your controller  
3. Adhere to the SFSCollectionMenuDelegate protocol  
4. Create an instance of the menu controller by [[SFSCollectionMenuController alloc] initWithDelegate:self], or whatever object you designate as the delegate  
5. Implement the required methods, and any optional methods you wish  
6. Call -showMenu on your instance of SFSCollectionMenuController  

####Screenshots  
![iPad portrait](https://raw.github.com/SixFiveSoftware/SFSCollectionMenu/master/ipad1.png) ![iPhone 4 inch portrait](https://raw.github.com/SixFiveSoftware/SFSCollectionMenu/master/iphone1.png)

