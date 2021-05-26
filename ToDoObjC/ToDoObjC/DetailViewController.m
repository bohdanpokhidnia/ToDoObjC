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

    self.saveButton.userInteractionEnabled = NO;
    [self.saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEndEditing)];
    [self.view addGestureRecognizer:tapGesture];
    
    self.datePicker.minimumDate = [NSDate date];
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
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

- (void) saveButtonAction {
    if (self.eventDate) {
        switch ([self.eventDate compare:[NSDate date]]) {
            case NSOrderedSame:
                [self showAlertWithMessage:@"For save task, changed date in picker"];
                break;
            
            case NSOrderedAscending:
                [self showAlertWithMessage:@"For save task, changed date in picker"];
                break;
                
            case NSOrderedDescending:
                [self setNotification];
                [self.navigationController popViewControllerAnimated:YES];
                NSLog(@"set notification success");
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
    NSLog(@"self.eventDate = %@", self.eventDate);
}

// MARK: - Private

- (void) setNotification {
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
}

- (void) showAlertWithMessage : (NSString *) message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Attention!" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dissmissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler: ^(UIAlertAction *_Nonnull action) {
        NSLog(@"Dissmiss alert");
    }];

    [alertController addAction:dissmissAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
