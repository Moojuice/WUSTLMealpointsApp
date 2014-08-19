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

-(IBAction)logInAction:(id)sender {
    [self logIn];
}

-(IBAction)viewMealPointsAction:(id)sender {
    [self loadMeals];
}

-(void) logIn {
    _logInPage = [[UIWebView alloc] initWithFrame:CGRectMake(0, 45, 320, 554)];
    [self.view addSubview:_logInPage];
    
    NSURL* url = [NSURL URLWithString: @"https://acadinfo.wustl.edu/CBORD/MealPlan/"];

    NSString* username = @"a";
    NSString* password = @"b";
    NSString* body = [NSString stringWithFormat:@"appName=ridgefield&username=%@&password=%@", username, password];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [body dataUsingEncoding:NSStringEncodingConversionAllowLossy];
    
    [_logInPage loadRequest:request];
}
/*
 We use this method to parse the webpage for meal transactions
 */
-(void)loadMeals {
    
    _innerHTML = [_logInPage stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    [_logInPage setHidden:TRUE];

    //NSLog(_innerHTML);
    
    NSData* mealsHtmlData = [_innerHTML dataUsingEncoding:NSUTF8StringEncoding];
    
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

//Post request information taken from tampering with the log-in data
//    __VIEWSTATE = %2FwEPDwULLTEwMDEyOTc2MTgPFiIeHl9fUGFnZVdVTG9naW4uX3NXS0xpdGVQYXNzd29yZGQeE19fUGFnZVdVTG9naW4uX3ZpZXcLKWVXVUxvZ2luV2ViVUkuV1VMb2dpbitWaWV3LCBXVUxvZ2luV2ViVUksIFZlcnNpb249Mi4xLjUyNTUuMjQyOTIsIEN1bHR1cmU9bmV1dHJhbCwgUHVibGljS2V5VG9rZW49bnVsbAEeIl9fUGFnZVdVTG9naW4uX2JGb3JjZVBhc3N3b3JkUmVzZXRoHiBfX1BhZ2VXVUxvZ2luLl9jcmVhdGluZ0xvZ2luVHlwZQspcldVTG9naW5XZWJVSS5XVUxvZ2luK0NyZWF0aW5nTG9naW5UeXBlLCBXVUxvZ2luV2ViVUksIFZlcnNpb249Mi4xLjUyNTUuMjQyOTIsIEN1bHR1cmU9bmV1dHJhbCwgUHVibGljS2V5VG9rZW49bnVsbAAeIV9fUGFnZVdVTG9naW4uX2JGb3JjZUdvQWN0aXZhdGlvbmgeGF9fUGFnZVdVTG9naW4uX2JJc1NoaWJIUmgeI19fUGFnZVdVTG9naW4uX3NFbWFpbEFjdGl2YXRpb25Db2RlZB4eX19QYWdlV1VMb2dpbi5fc0xvZ2luRXJyb3JIVE1MBbkBPHNwYW4gc3R5bGU9ImZvbnQtZmFtaWx5OiAnQXJpYWwgTmFycm93JzsKICAgIGZvbnQtc2l6ZTogMTRweDsKICAgIGxpbmUtaGVpZ2h0OiBub3JtYWw7CiAgICBmb250LXdlaWdodDogYm9sZDsKICAgIGNvbG9yOiAjOTkwMDAwOyI%2BCkludmFsaWQgTG9naW4gSUQvUGFzc3dvcmQuIFBsZWFzZSB0cnkgYWdhaW4uCjwvc3Bhbj4eFF9fUGFnZVdVTG9naW4uX2JJc0hSaB4gX19QYWdlV1VMb2dpbi5fc1dVU1RMS2V5VXNlcm5hbWVkHiNfX1BhZ2VXVUxvZ2luLl9iRm9yY2VXVVNUTEtleUNoYW5nZWgeIF9fUGFnZVdVTG9naW4uX3NXVVNUTEtleVBhc3N3b3JkZB4qX19QYWdlV1VMb2dpbi5fc0F0dGVtcHRzUmVtYWluaW5nRXJyb3JIVE1MBbcCPHNwYW4gc3R5bGU9ImNvbG9yOiByZ2IoMTUzLCAwLCAwKTsgZm9udC1mYW1pbHk6ICdBcmlhbCBOYXJyb3cnOyBmb250LXNpemU6IDE0cHg7IGZvbnQtd2VpZ2h0OiBib2xkOyI%2BSW52YWxpZCBMb2dpbiBJRC9QYXNzd29yZC4gUGxlYXNlIHRyeSBhZ2Fpbi4gWW91IGhhdmUgb25seSAjIG1vcmUmbmJzcDs8L3NwYW4%2BPGRpdj48c3BhbiBzdHlsZT0iY29sb3I6IHJnYigxNTMsIDAsIDApOyBmb250LWZhbWlseTogJ0FyaWFsIE5hcnJvdyc7IGZvbnQtc2l6ZTogMTRweDsgZm9udC13ZWlnaHQ6IGJvbGQ7Ij5hdHRlbXB0KHMpLjwvc3Bhbj48L2Rpdj4eIl9fUGFnZVdVTG9naW4uX2JBc2tTZWNyZXRRdWVzdGlvbnNoHhlfX1BhZ2VXVUxvZ2luLl9zUmV0dXJuVVJMZB4mX19QYWdlV1VMb2dpbi5fc0FjY291bnRMb2NrZWRFcnJvckhUTUwFzQI8c3BhbiBzdHlsZT0iZm9udC1mYW1pbHk6ICdBcmlhbCBOYXJyb3cnOyBsaW5lLWhlaWdodDogbm9ybWFsOyBjb2xvcjogcmdiKDE1MywgMCwgMCk7IGZvbnQtc2l6ZTogMTJweDsiPllvdXIgYWNjb3VudCBpcyB0ZW1wb3JhcmlseSBsb2NrZWQuIElmIHRoZSBwcm9ibGVtIHBlcnNpc3RzLCBwbGVhc2UgY29udGFjdCB0aGUKPGEgaHJlZj0iaHR0cDovL2Nvbm5lY3RoZWxwLnd1c3RsLmVkdS9QYWdlcy9zdXBwb3J0LmFzcHgiIHRhcmdldD0iX2JsYW5rIiBzdHlsZT0iY29sb3I6ICM5OTAwMDA7IHRleHQtZGVjb3JhdGlvbjogdW5kZXJsaW5lOyI%2BCmhlbHAgZGVzay4KPC9hPjwvc3Bhbj4eHF9fUGFnZVdVTG9naW4uX3NSZWZlcmVuY2VVUkxkFgICAw9kFiYCAw9kFgQCAQ8WAh4Fc3R5bGUFN2JhY2tncm91bmQ6dXJsKGltYWdlcy9XVVNUTC1Db25uZWN0LW1lZC5qcGcpIG5vLXJlcGVhdDtkAgMPFgIeB1Zpc2libGVoFgQCAQ8WAh4JaW5uZXJodG1sBQxTZWN1cmUgTG9naW5kAgMPFgIfEwUhRW50ZXIgeW91ciBsb2dpbiBJRCBhbmQgcGFzc3dvcmQuZAIHDxYCHxJnFgICAQ8PFgIfEmdkFgICAQ8WAh8SZxYCAgEPFgIeBWNsYXNzBRlkaXZXVVNUTEtleUxvZ2luRm9ybVNtYWxsFgICAQ9kFgQCAQ8PFgIeB0VuYWJsZWRnZGQCAg8PFgIfFWdkZAIJDw8WAh8SaGQWCGYPFgIfEwUMQ29uZmlybWF0aW9uZAICDxYCHxMFKllvdXIgYWNjb3VudCBoYXMgYmVlbiBzdWNjZXNzZnVsbHkgY3JlYXRlZGQCBA8WAh8TBS1XaGVuIHlvdSBjbGljayBPSywgeW91IHdpbGwgYmUgcmVkaXJlY3RlZCB0byBkAgoPFgIeBGhyZWYFL2h0dHA6Ly9jb25uZWN0aGVscC53dXN0bC5lZHUvUGFnZXMvc3VwcG9ydC5hc3B4ZAILD2QWCmYPFgIfEmcWBAIDD2QWAgIBD2QWAgIBD2QWAgIBDxYCHxJnZAIFD2QWAgIBD2QWAgIBD2QWAgICDxYCHxYFbGh0dHBzOi8vc29jbG9naW4ud3VzdGwuZWR1L29wZW5pZC92Mi9zaWduaW4%2FdG9rZW5fdXJsPWh0dHBzJTNBJTJGJTJGY29ubmVjdC53dXN0bC5lZHUlMkZsb2dpbiUyRldVTG9naW4uYXNweGQCAQ9kFgICAQ9kFgICAQ9kFgICAQ8WAh8SZ2QCAg8WAh4FdmFsdWUFGkxvZ2luIHVzaW5nIHlvdXIgV1VTVEwgS0VZZAIDDxYCHxcFJUxvZ2luIHVzaW5nIHlvdXIgU29jaWFsIExvZ2luIEFjY291bnRkAgQPFgIfFwUeTG9naW4gdXNpbmcgeW91ciBFbWFpbCBBZGRyZXNzZAIND2QWBAICDxYCHxJnFgQCAQ8PFgIfEmhkZAIDD2QWAgIBD2QWAgIBDxBkZBYAZAIDD2QWAgIBD2QWAmYPZBYCAgMPZBYCZg8QZGQWAGQCDw9kFgYCAQ8WAh8SZ2QCAg8WAh8SZxYGAgMPEGRkFgBkAgcPEGRkFgBkAg0PEGRkFgBkAgMPZBYGAgUPZBYCZg8QZGQWAGQCBw9kFgJmDxBkZBYAZAIJD2QWAmYPEGRkFgBkAhEPZBYEAgIPFgIfEmcWAgIJDxBkZBYBZmQCAw9kFgICCQ8QZGQWAWZkAhMPZBYCAgIPFgIfEmdkAhUPZBYCAgQPFgIfEmdkAhcPZBYCAgIPFgIfEmcWAgIBDw8WAh8SaGRkAhkPZBYMZg8WAh8TBRlBY3RpdmF0ZSB5b3VyIGFzc29jaWF0aW9uZAIBDxYCHxMFJ1BsZWFzZSB2YWxpZGF0ZSB5b3VyIGFzc29jaWF0aW9uIGJlbG93LmQCBQ8WAh8TBUQ8Yj5JcyB0aGlzIHlvdT88L2I%2BIAo8YnI%2BIApJZiBzbywgY2xpY2sgb25lIG9mIHRoZSBsaW5rcyBiZWxvdy4gPGJyPmQCBg9kFgQCAQ8PFgIeB1Rvb2xUaXAFiAFJZiB5b3UgYWxyZWFkeSBoYXZlIGEgV1VTVEwgS2V5LCBFbWFpbCwgb3IgU29jaWFsIExvZ2luIGFjY291bnQgcmVnaXN0ZXJlZCB3aXRoIFdVU1RMIENvbm5lY3QsIHBsZWFzZSBjbGljayBoZXJlIHRvIGdvIHRvIHRoZSBsb2dpbiBwYWdlZGQCAw8PFgIfGAUyU2lnbiB1cCBmb3IgYSBTb2NpYWwgTG9naW4gb3IgRW1haWwgTG9naW4gYWNjb3VudC5kZAIHDxYCHxMFvgJJZiBub3QsIHBsZWFzZSBjb250YWN0IFN1cHBvcnQgdmlhIG9uZSBvZiB0aGUgZm9sbG93aW5nIG1ldGhvZHM6PGJyIC8%2BPHVsPjxsaT48Yj5FbWFpbCBTdXBwb3J0PC9iPiAtLSBTZW5kIGFuIDxhIGhyZWY9Imh0dHBzOi8vY29ubmVjdHRlc3Qud3VzdGwuZWR1L2NvbnRhY3RzdXBwb3J0Ij5lbWFpbCB0byBTdXBwb3J0LjwvYT48L2xpPjxsaT48Yj5QaG9uZSBTdXBwb3J0PC9iPiAtLSBQaG9uZSBzdXBwb3J0IGlzIGF2YWlsYWJsZSBNb25kYXkgdGhyb3VnaCBGcmlkYXksIDg6MzAgYS5tLi01OjAwIHAubS4gQ1NUIGF0IDxiPigzMTQpIDkzNS01NzA3PC9iPi5kAggPFgIfFgUvaHR0cDovL2Nvbm5lY3RoZWxwLnd1c3RsLmVkdS9QYWdlcy9zdXBwb3J0LmFzcHhkAhsPZBYGZg8WAh8TBRhDb25maXJtIHlvdXIgaW5mb3JtYXRpb25kAgIPFgIfEwVEUGxlYXNlIGNvbmZpcm0geW91ciBpbmZvcm1hdGlvbiBiZWxvdywgbWFraW5nIGFueSBuZWNlc3NhcnkgdXBkYXRlcy5kAgQPFgIfEmcWBAIDD2QWBAIBD2QWAgIBD2QWAgIDDxYEHxYFbGh0dHBzOi8vc29jbG9naW4ud3VzdGwuZWR1L29wZW5pZC92Mi9zaWduaW4%2FdG9rZW5fdXJsPWh0dHBzJTNBJTJGJTJGY29ubmVjdC53dXN0bC5lZHUlMkZsb2dpbiUyRldVTG9naW4uYXNweB4IZGlzYWJsZWQFCGRpc2FibGVkFgICAQ8PFgIfGAWAAUlmIHlvdSBoYXZlIGFuIGFjY291bnQgd2l0aCBvbmUgb2YgdGhlc2Ugc29jaWFsIGFjY291bnQgcHJvdmlkZXJzLCB5b3UgY2FuIGFzc29jaWF0ZSB0aGF0IGFjY291bnQgdG8gYSBuZXcgV1VTVEwgQ29ubmVjdCBhY2NvdW50ZGQCAw9kFgICAQ9kFgICAw8PFgIfGAVLSWYgeW91IGhhdmUgYW4gZXhpc3RpbmcgZW1haWwgYWRkcmVzcywgeW91IGNhbiB1c2UgaXQgdG8gY3JlYXRlIGFuIGFjY291bnQuZGQCBQ8WAh8WBS9odHRwOi8vY29ubmVjdGhlbHAud3VzdGwuZWR1L1BhZ2VzL3N1cHBvcnQuYXNweGQCHQ9kFgICAQ8WAh8SZxYGAgIPDxYCHhRWYWxpZGF0aW9uRXhwcmVzc2lvbgVTXlstYS16QS1aMC05X11bLS5hLXpBLVowLTlfXSpAWy0uYS16QS1aMC05X10rKFwuWy0uYS16QS1aMC05X10rKSpcLihbYS16QS1aXXsyLDZ9KSRkZAIPDxYCHxYFPWh0dHA6Ly9jb25uZWN0aGVscC53dXN0bC5lZHUvRkFRcy9QYWdlcy9QYXNzd29yZFN0cmVuZ3RoLmFzcHhkAhIPFgIfFgUvaHR0cDovL2Nvbm5lY3RoZWxwLnd1c3RsLmVkdS9QYWdlcy9zdXBwb3J0LmFzcHhkAh8PZBYGZg8WAh8TBQ5WYWxpZGF0ZSBFbWFpbGQCAQ8WAh8TBUtBIHZhbGlkYXRpb24gY29kZSBoYXMgYmVlbiBzZW50IHRvIHlvdXIgZW1haWwuIFBsZWFzZSBlbnRlciB0aGUgY29kZSBiZWxvdy5kAgUPFgIfFgUvaHR0cDovL2Nvbm5lY3RoZWxwLnd1c3RsLmVkdS9QYWdlcy9zdXBwb3J0LmFzcHhkAiEPZBYCAgIPFgIfEmdkAiMPZBYCAgIPFgIfEmdkAiUPDxYEHgRUZXh0BQRQcm9kHxJoZGQCKw9kFgQCAQ8WAh8TBYoCVGhpcyBpcyBhIHByaXZhdGUgbmV0d29yayBvZiBXYXNoaW5ndG9uIFVuaXZlcnNpdHkgaW4gU3QuIExvdWlzLiBVbmF1dGhvcml6ZWQgYWNjZXNzCgkJCWlzIHByb2hpYml0ZWQuIFVzZSBvZiB0aGlzIHdlYnNpdGUgY29uc3RpdHV0ZXMgYWdyZWVtZW50IHRvIHRoaXMgPGEgaHJlZj0iaHR0cHM6Ly93d3cud3VzdGwuZWR1L3BvbGljaWVzL2NvbXB1dGluZy5odG1sIiB0YXJnZXQ9Il9ibGFuayIgY2xhc3M9ImlubGluZUxpbmsiPlByaXZhY3kgU3RhdGVtZW50PC9hPi5kAgMPDxYCHxsFEVYgMi4xIEJVSUxEIDI0MjkyZGQCLQ9kFgICAw8WAh8TBYoCVGhpcyBpcyBhIHByaXZhdGUgbmV0d29yayBvZiBXYXNoaW5ndG9uIFVuaXZlcnNpdHkgaW4gU3QuIExvdWlzLiBVbmF1dGhvcml6ZWQgYWNjZXNzCgkJCWlzIHByb2hpYml0ZWQuIFVzZSBvZiB0aGlzIHdlYnNpdGUgY29uc3RpdHV0ZXMgYWdyZWVtZW50IHRvIHRoaXMgPGEgaHJlZj0iaHR0cHM6Ly93d3cud3VzdGwuZWR1L3BvbGljaWVzL2NvbXB1dGluZy5odG1sIiB0YXJnZXQ9Il9ibGFuayIgY2xhc3M9ImlubGluZUxpbmsiPlByaXZhY3kgU3RhdGVtZW50PC9hPi5kZM%2BwAsMIHpUPGoDfYmdVjz2BrWGuSL85fjkUpaJCD51l
//    __EVENTVALIDATION = %2FwEWBgLn%2Bd6AAgLAmpeSAgK%2B9PGbDQKwh5VfAsu%2F2KwMAoaEsd0PbahXhgke0LpXh9z6zeNylVNRQpeOrcJpeVnJ4YBhGZA%3D
//
//    ucWUSTLKeyLogin%24txtUsername = USERNAME;
//    ucWUSTLKeyLogin%24txtPassword = PASSWORD;
//    ucWUSTLKeyLogin%24btnLogin = Login+%E2%86%B5
//    hdnOverrideMobile = false;
//
//    https://login.wustl.edu/idp/Authn/UserPassword
//    j_username = USERNAME;
//    j_password = PASS;

@end
