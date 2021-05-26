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
    
    self.arrayEvents = [[NSMutableArray alloc] initWithObjects:@"AAA", @"BBB", @"CCC", nil];
    
}

// MARK: - DataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayEvents.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"Cell";
    NSString *value = [self.arrayEvents objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.textLabel.text = value;
    return cell;
}

@end
