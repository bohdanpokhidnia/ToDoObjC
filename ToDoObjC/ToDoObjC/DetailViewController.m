//
//  ViewController.m
//  ToDoObjC
//
//  Created by Bogdan Pohidnya on 26.05.2021.
//

#import "DetailViewController.h"

UIKIT_EXTERN NSString *const UILocalNotificationDefaultSoundName;

@interface DetailViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation DetailViewController

// MARK: - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEndEditing)];
    [self.view addGestureRecognizer:tapGesture];
    
    self.datePicker.minimumDate = [NSDate date];
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
}

// MARK: - textFieldShouldReturn

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.textField]) {
        [self.textField resignFirstResponder];
    }
    
    return YES;
}

// MARK: - User interactions

- (void) saveButtonAction {
    NSString *textFieldString = self.textField.text;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm DD.MMMM.yyyy";
    
    NSString *dateString = [dateFormatter stringFromDate:self.eventDate];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          textFieldString, @"textFieldString",
                          dateString, @"dateString",
                          nil];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.userInfo = dict;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.fireDate = self.eventDate;
    notification.alertBody = textFieldString;
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    NSLog(@"Save button");
}

- (void) handleEndEditing {
    [self.view endEditing:YES];
}

- (void) datePickerValueChanged {
    self.eventDate = self.datePicker.date;
    NSLog(@"self.eventDate = %@", self.eventDate);
}

@end
