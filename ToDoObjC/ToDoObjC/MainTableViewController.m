//
//  MainTableViewController.m
//  ToDoObjC
//
//  Created by Bogdan Pohidnya on 26.05.2021.
//

#import "MainTableViewController.h"

@interface MainTableViewController ()

@property (nonatomic, strong) NSMutableArray *arrayEvents;

@end

@implementation MainTableViewController

// MARK: - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    self.arrayEvents = [[NSMutableArray alloc] initWithArray:notificationArray];
}

// MARK: - DataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayEvents.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"Cell";
    NSNotification *notification = [self.arrayEvents objectAtIndex:indexPath.row];
    NSDictionary *dict = notification.userInfo;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = [dict objectForKey:@"textFieldString"];
    cell.detailTextLabel.text = [dict objectForKey:@"dateString"];
    return cell;
}

@end
