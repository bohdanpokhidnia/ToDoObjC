//
//  MainTableViewController.m
//  ToDoObjC
//
//  Created by Bogdan Pohidnya on 26.05.2021.
//

#import <UserNotifications/UserNotifications.h>
#import "MainViewController.h"
#import "DetailViewController.h"

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIBarButtonItem *addTaskButton;

@end

@implementation MainViewController

// MARK: - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupConstraints];
    [self setupNotifications];
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
    NSString *title = [dict objectForKey:@"textFieldString"];
    NSString *body = [dict objectForKey:@"dateString"];
    NSMutableString *info = [[NSMutableString alloc] initWithString:title];
    [info appendString:@" - "];
    [info appendString:body];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
//    cell.textLabel.text = [dict objectForKey:@"textFieldString"];
    cell.textLabel.text = info;
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

// MARK: - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    UNNotificationPresentationOptions presentationOptions = (UNNotificationPresentationOptionBadge + UNNotificationPresentationOptionSound + UNNotificationPresentationOptionBanner);
    completionHandler(presentationOptions);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    completionHandler();
}

// MARK: - User interactions

- (void) tapAddTask {
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

// MARK: - Private

- (void) setupNotifications {
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        self.arrayEvents = [[NSMutableArray alloc] initWithArray:requests];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewWithNewEvent) name:@"NewEvent" object:nil];
    [notificationCenter setDelegate:self];
}

- (void) setupView {
    self.addTaskButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(tapAddTask)];
    [self.navigationItem setRightBarButtonItem:self.addTaskButton];
    
    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.tableView];
}

- (void) setupConstraints {
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

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
