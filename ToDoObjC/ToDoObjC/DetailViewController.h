//
//  ViewController.h
//  ToDoObjC
//
//  Created by Bogdan Pohidnya on 26.05.2021.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic, strong) NSDate *eventDate;
@property (nonatomic, strong) NSString *eventInfo;
@property (nonatomic, assign) BOOL isDetail;

@end

