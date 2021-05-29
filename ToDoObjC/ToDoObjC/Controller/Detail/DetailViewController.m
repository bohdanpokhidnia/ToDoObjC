//
//  ViewController.m
//  ToDoObjC
//
//  Created by Bogdan Pohidnya on 26.05.2021.
//

#import <UserNotifications/UserNotifications.h>
#import "DetailViewController.h"

UIKIT_EXTERN NSString *const UILocalNotificationDefaultSoundName;

@interface DetailViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIStackView *contentStack;

@end

@implementation DetailViewController

// MARK: - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupConstraints];
    
    if (self.isDetail) {
        self.textField.text = self.eventInfo;
        self.textField.userInteractionEnabled = NO;
        
        [self performSelector:@selector(setDatePickerValueWithAnimated) withObject:nil afterDelay:0.5];
        self.datePicker.userInteractionEnabled = NO;
        
        self.saveButton.hidden = YES;
        
        [self.navigationItem setTitle:@"Detail task"];
    } else {
        self.saveButton.userInteractionEnabled = NO;
        [self.saveButton addTarget:self action:@selector(tapSaveTask) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEndEditing)];
        [self.view addGestureRecognizer:tapGesture];
        
        [self.datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    }
}

// MARK: - Setup

- (void) setupView {
    self.textField = [[UITextField alloc] init];
    [self.textField setPlaceholder:@"Input text"];
    [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [self.textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker setMinimumDate:[NSDate date]];
    [self.datePicker setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    [self.datePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIView *emptyView = [[UIView alloc] init];
    
    self.saveButton = [[UIButton alloc] init];
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    [self.saveButton setBackgroundColor:UIColor.systemGray6Color];
    [self.saveButton.layer setCornerRadius:10];
    [self.saveButton setClipsToBounds:YES];
    [self.saveButton addTarget:self action:@selector(addNotification) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.contentStack = [[UIStackView alloc] init];
    [self.contentStack setAxis:UILayoutConstraintAxisVertical];
    [self.contentStack setDistribution:UIStackViewDistributionFill];
    [self.contentStack setAlignment:UIStackViewAlignmentFill];
    [self.contentStack setSpacing:16];
    [self.contentStack addArrangedSubview:self.textField];
    [self.contentStack addArrangedSubview:self.datePicker];
    [self.contentStack addArrangedSubview:emptyView];
    [self.contentStack addArrangedSubview:self.saveButton];
    [self.contentStack setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.contentStack];
}

- (void) setupConstraints {
    [self.saveButton.heightAnchor constraintEqualToConstant:40].active = YES;
    
    [self.contentStack.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:16].active = YES;
    [self.contentStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16].active = YES;
    [self.contentStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16].active = YES;
    [self.contentStack.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor].active = YES;
}

// MARK: - textFieldShouldReturn

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.textField]) {
        if ([self.textField.text length] != 0) {
            [self.textField resignFirstResponder];
            self.saveButton.userInteractionEnabled = YES;
            return YES;
        } else {
            [self showAlertWithMessage: @"For save task, enter value to text field"];
        }
    }
    
    return NO;
}

// MARK: - User interactions

- (void) tapSaveTask {
    if (self.eventDate) {
        switch ([self.eventDate compare:[NSDate date]]) {
            case NSOrderedSame:
                [self showAlertWithMessage:@"For save task, changed date in picker"];
                break;
            
            case NSOrderedAscending:
                [self showAlertWithMessage:@"For save task, changed date in picker"];
                break;
                
            case NSOrderedDescending:
                [self addNotification];
                [self.navigationController popViewControllerAnimated:YES];
                break;
        }
    } else {
        [self showAlertWithMessage:@"For save task, changed date in picker"];
    }
}

- (void) handleEndEditing {
    if ([self.textField.text length] != 0) {
        [self.view endEditing:YES];
        self.saveButton.userInteractionEnabled = YES;
    } else {
        [self showAlertWithMessage: @"For save task, enter value to text field"];
    }
}

- (void) datePickerValueChanged {
    self.eventDate = self.datePicker.date;
}

// MARK: - Private

- (void) addNotification {
    NSString *textFieldString = self.textField.text;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm dd.MMMM.yyyy";
    
    NSString *dateString = [dateFormatter stringFromDate:self.eventDate];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          textFieldString, @"textFieldString",
                          dateString, @"dateString",
                          nil];
    
    UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
    notificationContent.userInfo = dict;
    notificationContent.title = textFieldString;
    notificationContent.body = dateString;
    notificationContent.badge = @1;
    notificationContent.sound = [UNNotificationSound defaultSound];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitYear + NSCalendarUnitMonth + NSCalendarUnitDay + NSCalendarUnitHour + NSCalendarUnitMinute;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:calendarUnit fromDate:self.eventDate];
    [dateComponents setTimeZone:[NSTimeZone defaultTimeZone]];
    UNCalendarNotificationTrigger *notificationTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];
    
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"Notification" content:notificationContent trigger:notificationTrigger];
    [notificationCenter addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"error: %@", error);
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewEvent" object:nil];
}

- (void) showAlertWithMessage : (NSString *) message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Attention!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dissmissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler: ^(UIAlertAction *_Nonnull action) {
        NSLog(@"Dissmiss alert");
    }];

    [alertController addAction:dissmissAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) setDatePickerValueWithAnimated {
    [self.datePicker setDate:self.eventDate animated:YES];
}

@end
