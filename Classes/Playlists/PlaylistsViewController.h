//
//  RootViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright Third Cog Software 2009. All rights reserved.
//

@interface PlaylistsViewController : UIViewController 
	<UITableViewDelegate, UITableViewDataSource>
{
	NSArray *playlists;
  
  UITableView *tableView;
}

@end
