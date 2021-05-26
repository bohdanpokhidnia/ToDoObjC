//
//  ViewController.m
//  ToDoObjC
//
//  Created by Bogdan Pohidnya on 26.05.2021.
//

#import "DetailViewController.h"

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
    NSLog(@"Save button");
}

- (void) handleEndEditing {
    [self.view endEditing:YES];
}

@end
