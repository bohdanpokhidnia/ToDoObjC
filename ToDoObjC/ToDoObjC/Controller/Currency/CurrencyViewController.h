//
//  CurrencyViewController.h
//  ToDoObjC
//
//  Created by Bohdan Pokhidnia on 25.02.2023.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CurrencyViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *cashCurrencies;
@property (nonatomic, strong) NSMutableArray *noCashCurrencies;

@end

NS_ASSUME_NONNULL_END
