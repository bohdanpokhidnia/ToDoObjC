//
//  MainTableViewController.m
//  ToDoObjC
//
//  Created by Bogdan Pohidnya on 26.05.2021.
//

#import <UserNotifications/UserNotifications.h>
#import "MainTableViewController.h"
#import "DetailViewController.h"

@interface MainTableViewController ()<UNUserNotificationCenterDelegate>

@end

@implementation MainTableViewController

// MARK: - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        self.arrayEvents = [[NSMutableArray alloc] initWithArray:requests];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewWithNewEvent) name:@"NewEvent" object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: - DataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayEvents.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"Cell";
    
    UNNotificationRequest *notificationRequst = [self.arrayEvents objectAtIndex: indexPath.row];
    NSDictionary *dict = notificationRequst.content.userInfo;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = [dict objectForKey:@"textFieldString"];
    cell.detailTextLabel.text = [dict objectForKey:@"dateString"];
    return cell;
}

// MARK: - Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [self.arrayEvents count]) {
        return;
    }
 
    UNNotificationRequest *notificationRequst = [self.arrayEvents objectAtIndex: indexPath.row];
    NSDictionary *dict = notificationRequst.content.userInfo;
    
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm dd.MMMM.yyyy";
    NSDate *date = [dateFormatter dateFromString:[dict objectForKey:@"dateString"]];

    detailViewController.eventInfo = [dict objectForKey:@"textFieldString"];
    detailViewController.eventDate = date;
    detailViewController.isDetail = YES;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [self.arrayEvents count]) {
        return;
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        UNNotificationRequest *notificationRequest = [self.arrayEvents objectAtIndex:indexPath.row];
        NSLog(@"%@", [notificationRequest identifier]);
        [notificationCenter removeDeliveredNotificationsWithIdentifiers:@[[notificationRequest identifier]]];
        [self.arrayEvents removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// MARK: - Private

- (void) reloadTableViewWithNewEvent {
    [self.arrayEvents removeAllObjects];
    
    [UIView animateWithDuration:0 animations:^{
        UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        [notificationCenter getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            self.arrayEvents = [[NSMutableArray alloc] initWithArray:requests];
        }];
    } completion:^(BOOL finished) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

@end
