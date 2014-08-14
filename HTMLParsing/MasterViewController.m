//
//  MasterViewController.m
//  HTMLParsing
//
//  Created by Kyle Liu on 8/12/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "MasterViewController.h"
#import "TFHpple.h"
#import "Meal.h"
#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_meals;
    NSMutableArray *_objects; 
}
@end

@implementation MasterViewController

/*
 We use this method to parse the webpage for meal transactions
 */
-(void)loadMeals {
    //obtain the url
    NSURL *mealsUrl = [NSURL URLWithString:@"http://students.cec.wustl.edu/~kyleliu/mealpointstest.html"];
    
    //convert url to data
    NSData *mealsHtmlData = [NSData dataWithContentsOfURL:mealsUrl];
    
    //parse the information
    TFHpple *mealsParser = [TFHpple hppleWithHTMLData:mealsHtmlData];
    
    NSString *mealsXpathQueryString = @"//tr[@style='background-color:SeaShell;font-family:Arial;font-size:Smaller;']/td";
    NSArray *mealsNodes = [mealsParser searchWithXPathQuery:mealsXpathQueryString];
    //create a mutable array for us to add our relevant info
    NSMutableArray *newMeals = [[NSMutableArray alloc] initWithCapacity:0];
    
    //iterate through the table, adding td elements as various components for a transaction
    int runningCount = 0; int index = 0;
    for (TFHppleElement *element in mealsNodes) {
        Meal *meal;
        
        //create a new element only on certain tds
        if (runningCount == 0) {
            meal = [[Meal alloc] init];
            [newMeals addObject:meal];
        }
        else {
            meal = newMeals[index];
        }
        
        switch (runningCount) {
            case 0:
                meal.date = [[element firstChild] content];
                runningCount++;
                break;
            case 1:
                meal.location = [[element firstChild] content];
                runningCount++;
                break;
            case 2:
                meal.transaction = [[element firstChild] content];
                runningCount++;
                break;
            case 3:
                meal.tenderUsed = [[element firstChild] content];
                runningCount++;
                break;
            case 4:
                meal.amountOfSale = [[element firstChild] content];
                runningCount++;
                break;
            case 5:
                meal.currentBalance = [[element firstChild] content];
                runningCount = 0;
                index++;
                break;
        }
        
    }
    _meals = newMeals;
    [self.tableView reloadData];
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self loadMeals];
    //[self loadTutorials];
    //[self loadContributors];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender
//{
//    if (!_objects) {
//        _objects = [[NSMutableArray alloc] init];
//    }
//    [_objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark - Table View

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Meals";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _meals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Meal *thisMeal = [_meals objectAtIndex:indexPath.row];
    cell.textLabel.text = thisMeal.date;
    cell.detailTextLabel.text = thisMeal.location;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
