SFSCollectionMenu
=================

An open-source menu control for iOS utilizing UICollectionView layout.

SFSCollectionMenu is an open-source control for a UICollectionView-based menu. SFSCollectionMenu is designed for iOS 7, and is ARC-compliant. It works by utilizing a delegate pattern to allow you, the developer, the implement it easily and add your own code to customize its appearance and behavior. SFSCollectionMenuController's designated initializer is -initWithDelegate, as the delegate is required for operation.

####Accessibility
This menu control is written to be accessible by blind/low-vision users. The delegate protocol has required methods to implement this. The menu control will check if Voice Over is on, and if so, it will implement a close button in the center of the control so that when swiping through the controls using Voice Over, the user has an obvious opportunity to cancel the menu if not wanting to choose a button.

####Contact:
If you use this framework, I'd love to hear from you! Here's how to contact me:
* Twitter: @bjmillerltd
* App.net: @bjmiller
* Website: http://sixfivesoftware.com

####To use:  
1. Add the following files to your project:
 * SFSCollectionMenuController (.h/.m)
 * SFSCircleLayout (.h/.m)
 * SFSMenuCell (.h/.m)
 * UIImage+ImageEffects (.h/.m) 
2. Import SFSCollectionMenuController.h to your controller  
3. Adhere to the SFSCollectionMenuDelegate protocol  
4. Create an instance of the menu controller by [[SFSCollectionMenuController alloc] initWithDelegate:self], or whatever object you designate as the delegate  
5. Implement the required methods, and any optional methods you wish  
6. Call -showMenu on your instance of SFSCollectionMenuController  

####Screenshots:  
![iPad portrait](https://raw.github.com/SixFiveSoftware/SFSCollectionMenu/master/iPad.png) ![iPhone 4 inch portrait](https://raw.github.com/SixFiveSoftware/SFSCollectionMenu/master/iPhone.png)

####To do:  
* Create CocoaPod

