//
//  ArtistBrowseViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "ArtistBrowseViewController.h"
#import "SpotSession.h"
#import "SpotAlbum.h"
#import "AlbumBrowseViewController.h"
#import "SpotNavigationController.h"
#import "ArtistDetailViewController.h"

@implementation ArtistBrowseViewController
-(id)initBrowsingArtist:(SpotArtist*)artist_;
{
	if( ! [super initWithNibName:@"ArtistBrowseView" bundle:nil])
		return nil;
  
	artist = [artist_ retain];
  [artist loadMoreInfo];
  
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = artist.name;
  if(artist.portraitId){
    portrait.artId = artist.portraitId;
  }


  artistName.text = artist.name;
  yearsActive.text = artist.yearsActive;
  popularity.progress = artist.popularity;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [artist release];
  [super dealloc];
}

#pragma mark Table view callbacks

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
  return [artist.albums count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
	return @"Albums";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
  }
  
  int idx = [indexPath indexAtPosition:1];
  if(idx % 2 == 0) {
  	cell.textLabel.textColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.2 alpha:0.8]; 
  } else {
	cell.textLabel.textColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.1 alpha:0.9]; 
  }
	
  SpotAlbum *album = [artist.albums objectAtIndex:idx];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  NSString *yearString = [NSString stringWithFormat:@" (%d)", album.year];
  cell.textLabel.text = [NSString stringWithFormat:@"%@%@", album.name, album.year ? yearString : @""];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int idx = [indexPath indexAtPosition:1];

  SpotAlbum *album = [artist.albums objectAtIndex:idx];
  [[self navigationController] pushViewController:[[[AlbumBrowseViewController alloc] initBrowsingAlbum:album] autorelease] animated:YES];
}

-(IBAction)showDetail:(id)sender;
{
  ArtistDetailViewController *detailView = [[ArtistDetailViewController alloc] initWithArtist:artist];
  [self.navigationController pushViewController:detailView animated:YES];
  [detailView release];
}

@end
