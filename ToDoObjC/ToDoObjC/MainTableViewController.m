//
//  MainTableViewController.m
//  ToDoObjC
//
//  Created by Bogdan Pohidnya on 26.05.2021.
//

#import "MainTableViewController.h"
#import "DetailViewController.h"

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
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

// MARK: - DataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayEvents.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"Cell";
    UILocalNotification *notification = [self.arrayEvents objectAtIndex:indexPath.row];
    NSDictionary *dict = notification.userInfo;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = [dict objectForKey:@"textFieldString"];
    cell.detailTextLabel.text = [dict objectForKey:@"dateString"];
    return cell;
}

// MARK: - Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UILocalNotification *notification = [self.arrayEvents objectAtIndex:indexPath.row];
    NSDictionary *dict = notification.userInfo;
    
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
    detailViewController.eventInfo = [dict objectForKey:@"textFieldString"];
    detailViewController.eventDate = notification.fireDate;
    detailViewController.isDetail = YES;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
