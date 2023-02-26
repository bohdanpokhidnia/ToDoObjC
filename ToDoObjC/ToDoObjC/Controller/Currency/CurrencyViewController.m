//
//  CurrencyViewController.m
//  ToDoObjC
//
//  Created by Bohdan Pokhidnia on 25.02.2023.
//

#import "CurrencyViewController.h"

@interface CurrencyViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *currenciesTableView;

@end

typedef struct {
    NSString *name;
    NSString *buy;
    NSString *sale;
} Currency;

typedef NS_ENUM(int, CurrencyType) {
    CashCurrency,
    NoCashCurrency
};

@implementation CurrencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cashCurrencies = [[NSMutableArray alloc] init];
    self.noCashCurrencies = [[NSMutableArray alloc] init];
    
    [self setupNavigationBar];
    [self setupViews];
    
    [self fetchCurrencies:(CashCurrency)];
    [self fetchCurrencies:(NoCashCurrency)];
}

- (void)setupNavigationBar {
    self.navigationItem.title = @"Privat API";
    self.navigationController.navigationBar.topItem.backButtonTitle = @"Back";
}

- (void)setupViews {
    [self.view setBackgroundColor: UIColor.systemBackgroundColor];
    
    self.currenciesTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.currenciesTableView.translatesAutoresizingMaskIntoConstraints = false;
    self.currenciesTableView.dataSource = self;
    self.currenciesTableView.delegate = self;
    [self.currenciesTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [self.view addSubview:self.currenciesTableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.currenciesTableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.currenciesTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.currenciesTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.currenciesTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *currencies = [[NSArray alloc] initWithObjects:self.cashCurrencies, self.noCashCurrencies, nil];
    int count = 0;
    
    for (NSArray *currency in currencies) {
        count += (currency.count > 0) ? 1 : 0;
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.cashCurrencies.count;
            
        case 1:
            return self.noCashCurrencies.count;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *array;
    
    switch (indexPath.section) {
        case 0:
            array = [self.cashCurrencies mutableCopy];
            break;
            
        case 1:
            array = [self.noCashCurrencies mutableCopy];
            break;
            
        default:
            return [[UITableViewCell alloc] init];
    }
    
    Currency currency;
    NSValue *value = [array objectAtIndex:indexPath.row];
    [value getValue:&currency];
    NSString *cellTitle = [NSString stringWithFormat:@"%@ - buy: %@, sale: %@", currency.name, currency.buy, currency.sale];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell.textLabel setText: cellTitle];
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Cash currencies";
            
        case 1:
            return @"No cash currencies";
            
        default:
            return @"Unknown";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - Private methods

- (void)fetchCurrencies: (CurrencyType) currencyType {
    NSString *stringUrl;
    NSMutableArray *array;
    NSURLSession *session = [NSURLSession sharedSession];
    
    switch (currencyType) {
        case CashCurrency:
            stringUrl = @"https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5";
            array = self.cashCurrencies;
            break;
            
        case NoCashCurrency:
            stringUrl = @"https://api.privatbank.ua/p24api/pubinfo?exchange&coursid=11";
            array = self.noCashCurrencies;
            break;
    }
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error %@", error);
            return;
        }
        
        __weak typeof (self) weakSelf = self;
        [weakSelf parseCurrencies:data forArray:array];
    }];
    
    [task resume];
}

- (void)parseCurrencies:(NSData *) data forArray:(NSMutableArray *) array {
    NSError *error = nil;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error) {
        NSLog(@"Failed parse JSON: %@", error);
        return;
    }
    
    for (NSDictionary *rate in jsonResponse) {
        Currency currency;
        currency.name = rate[@"ccy"];
        currency.buy = rate[@"buy"];
        currency.sale = rate[@"sale"];
        
        [array addObject:[NSValue valueWithBytes:&currency objCType:@encode(Currency)]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.currenciesTableView reloadData];
    });
}

@end
