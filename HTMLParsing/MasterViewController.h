//
//  MasterViewController.h
//  HTMLParsing
//
//  Created by Kyle Liu on 8/12/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController
@property(weak, nonatomic) IBOutlet UITextField *user;
@property(weak, nonatomic) IBOutlet UITextField *pass;
@property(strong, nonatomic) IBOutlet UIWebView *logInPage;
-(IBAction)logInAction:(id)sender;
-(IBAction)viewMealPointsAction:(id)sender;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) NSString *innerHTML;
@end
