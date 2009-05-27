//
//  SpotAppDelegate.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import "SpotAppDelegate.h"
#import "CoSpotify.h"

#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "PlaylistsViewController.h"
#import "SearchViewController.h"
#import  "PlayViewController.h"
@implementation SpotAppDelegate

@synthesize window, loginNav, tabs;

#import "SpotURI.h"

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {   
	
	///// Prepare the main UI
	// Warm it up
	[[PlayViewController defaultController] view];

	self.tabs = [[[UITabBarController alloc] init] autorelease];
	
	// Profile page
	UINavigationController *profilePage;
	{
		profilePage = [[[UINavigationController alloc] init] autorelease];
		profilePage.title = @"Profile";
		
		ProfileViewController *profile = [[[ProfileViewController alloc] init] autorelease];
		[profilePage pushViewController:profile animated:NO];
	}
	
	// Playlists
	UINavigationController *playlistPage;
	{
		playlistPage = [[[UINavigationController alloc] init] autorelease];
		
		PlaylistsViewController *playlists = [[[PlaylistsViewController alloc] init] autorelease];
		[playlistPage pushViewController:playlists animated:NO];
	}
	
	// Search
	UINavigationController *searchPage;
	{
		searchPage = [[[UINavigationController alloc] init] autorelease];
		
		SearchViewController *search = [[[SearchViewController alloc] init] autorelease];
		[searchPage pushViewController:search animated:NO];
	}
	
	NSArray *pages = [NSArray arrayWithObjects:
					  profilePage,
					  searchPage,
					  playlistPage,
					  nil];
	
	// Add it to the root
	[tabs setViewControllers:pages animated:NO];
	
	[tabs viewWillAppear:NO];
	[window addSubview:tabs.view];
	[tabs viewDidAppear:NO];
	
	///// Prepare to login
	LoginViewController *login = [[[LoginViewController alloc] init] autorelease];
	self.loginNav = [[[UINavigationController alloc] initWithRootViewController:login] autorelease];
	
	[self.tabs presentModalViewController:self.loginNav animated:NO];
	
	/// Display it!
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	//[[SpotSession defaultSession] cleanup];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	self.loginNav = nil;
	self.tabs = nil;
	self.window = nil;
	[super dealloc];
}


@end

