//
//  SearchViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SearchViewController.h"
#import "SpotSession.h"
#import "SpotArtist.h"
#import "SpotTrack.h"
#import "SpotSearch.h"

#import "AlbumBrowseViewController.h"
#import "ArtistBrowseViewController.h"
#import "PlayViewController.h"

@implementation SearchViewController

#pragma mark 
#pragma mark Memory and init

- (id)init;
{
    if ( ! [super initWithNibName:nil bundle:nil]) return nil;
	
	self.title = @"Search";
	self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease];
	
    return self;
}

- (void)dealloc {
    [super dealloc];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark 
#pragma mark Transitions
-(void)viewWillAppear:(BOOL)animated;
{
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated;
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark 
#pragma mark Table view callbacks
enum {
  SuggestionSection,
	ArtistsSection,
	AlbumsSection,
  TracksSection
};

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_;
{
	[searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return 1;
	return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return 0;
	
	switch (section) {
    case SuggestionSection: return searchResults.suggestion ? 1 : 0;
		case ArtistsSection: return searchResults.artists.count;
		case TracksSection:  return searchResults.tracks.count;
		case AlbumsSection:  return searchResults.albums.count;
	}
	return 0;	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return @"Search results";
	
	switch (section) {
    case SuggestionSection: return @"Did you mean";
		case ArtistsSection: return @"Artists";
		case TracksSection: return @"Tracks";
		case AlbumsSection: return @"Albums";
	}
	return @"???";
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

	switch([indexPath indexAtPosition:0]) {
    case SuggestionSection:{			
			//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
		cell.text = searchResults.suggestion;
    } break;
		case ArtistsSection: {
			SpotArtist *artist = [searchResults.artists objectAtIndex:idx];
			
			//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.text = artist.name;
		} break;
		case TracksSection: {
			SpotTrack *track = [searchResults.tracks objectAtIndex:idx];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.text = [NSString stringWithFormat:@"%@", track.title];
		} break;
		case AlbumsSection: {
			SpotAlbum *album = [searchResults.albums objectAtIndex:idx];
			//cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.text = [NSString stringWithFormat:@"%@ by %@", album.name, album.artistName];
		} break;
	}
	
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int idx = [indexPath indexAtPosition:1];
	switch([indexPath indexAtPosition:0]) {
    case SuggestionSection:{
      [searchBar setText:searchResults.suggestion];
      [self doSearch];
    } break;
		case TracksSection: {
			SpotTrack *track = [searchResults.tracks objectAtIndex:idx];
			[[SpotSession defaultSession].player playPlaylist:nil firstTrack:track];
			[self.navigationController pushViewController:[PlayViewController defaultController] animated:YES];
		} break;
		case ArtistsSection: {
			SpotArtist *artist = [searchResults.artists objectAtIndex:idx];
			
			[[self navigationController] pushViewController:[[[ArtistBrowseViewController alloc] initBrowsingArtist:artist] autorelease] animated:YES];
		} break;
		case AlbumsSection: {
			SpotAlbum *album = [searchResults.albums objectAtIndex:idx];
			[[self navigationController] pushViewController:[[[AlbumBrowseViewController alloc] initBrowsingAlbum:album] autorelease] animated:YES];
			break;
		}
	}
}

#pragma mark 
#pragma mark Search bar callbacks
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
{
	return [SpotSession defaultSession].loggedIn == YES;
}
- (void)searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText;
{
	// Do short search maybe
}

-(void)doSearch;
{
  // Do extensive search
	[searchBar resignFirstResponder];
	self.searchResults = nil;
  //NSLog(@"searching");
	self.searchResults = [SpotSearch searchFor:searchBar.text maxResults:50];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_;  
{
  [self doSearch];
}


#pragma mark 
#pragma mark Accessors
@synthesize searchResults;
-(void)setSearchResults:(SpotSearch*)searchResults_;
{
	[searchResults_ retain];
  [searchResults release];
  searchResults = searchResults_;
  NSLog(@"SearchResults: %@", searchResults);
	[tableView reloadData];
}
@end
