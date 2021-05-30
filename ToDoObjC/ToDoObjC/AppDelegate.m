//
//  AppDelegate.m
//  ToDoObjC
//
//  Created by Bogdan Pohidnya on 26.05.2021.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureNotifications];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    MainViewController *mainViewController = [[MainViewController alloc] initWithNibName:nil bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];

    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) configureNotifications {
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions notificationOptions = UNAuthorizationOptionAlert + UNAuthorizationOptionBadge + UNAuthorizationOptionSound;
    
    [notificationCenter requestAuthorizationWithOptions:notificationOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(granted) {
            [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                if ([settings authorizationStatus] != UNAuthorizationStatusAuthorized) {
                    NSLog(@"You dont have authorization %li", [settings authorizationStatus]);
                    return;
                }
            }];
        } else {
            NSLog(@"You don`t have permission");
        }
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
}

@end
