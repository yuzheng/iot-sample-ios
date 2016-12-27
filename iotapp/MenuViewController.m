//
//  MenuViewController.m
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#import "MenuViewController.h"
#import "ViewController.h"

#import "SWRevealViewController.h"


#define IOT_KEY @"IOT_KEY"

@implementation SWUITableViewCell
@end

@implementation MenuViewController {
    NSArray *menu;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //2016.03.18 依據deviceType, CompNo產生選單
    menu = [self createMenu];
    
    self.tableView.tableFooterView = [UIView new];
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    menu = [self createMenu];
    
    [self.tableView reloadData];
}

- (NSArray *)createMenu
{
    NSArray *cMenu;
    
    // read plist
    NSString *plistPickPath = [[NSBundle mainBundle] pathForResource:@"iot" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPickPath];
    if([plistDictionary objectForKey:IOT_KEY] != NULL){
        if([NSString stringWithFormat:@"%@",[plistDictionary objectForKey:IOT_KEY]].length == 0){
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if([userDefaults stringForKey:IOT_KEY] == NULL) {
                cMenu = @[@"home",@"devices", @"registry"];
            }else{
                cMenu = @[@"home",@"devices", @"registry",@"remove"];
            }

        }else{
            cMenu = @[@"home",@"devices", @"registry"];
        }
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if([userDefaults stringForKey:IOT_KEY] == NULL) {
            cMenu = @[@"home",@"devices", @"registry"];
        }else{
            cMenu = @[@"home",@"devices", @"registry",@"remove"];
        }
    }
    
    return cMenu;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // configure the destination view controller:
    if ( [sender isKindOfClass:[UITableViewCell class]] )
    {
        //UILabel* c = [(SWUITableViewCell *)sender label];
        //UINavigationController *navController = segue.destinationViewController;
        
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CellIdentifier = [menu objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"didSelectRowAtIndexPath: %ld",(long)indexPath.row);
    
    if([[menu objectAtIndex:indexPath.row] isEqualToString:@"remove"]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:IOT_KEY];
        [userDefaults synchronize];
        
        [self backHome];
    }
}

- (void)backHome
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"rootViewController"];
    SWRevealViewController *revealViewController = (SWRevealViewController*) self.parentViewController;
    UINavigationController* navController = (UINavigationController*)revealViewController.frontViewController;
    [navController setViewControllers: @[viewController] animated: YES];
    [revealViewController setFrontViewController:navController];
    [revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];

}

#pragma mark state preservation / restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO save what you need here
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO restore what you need here
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)applicationFinishedRestoringState {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO call whatever function you need to visually restore
}

@end
