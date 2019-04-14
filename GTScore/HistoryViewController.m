//
//  HistoryViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 4/1/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryDetailViewController.h"


@import Firebase;

@interface HistoryViewController ()
@property (strong, nonatomic) NSMutableArray<NSString *> *tableItems;
@property (weak, nonatomic) NSString *userID;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *matches;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *contacts;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userID = [FIRAuth auth].currentUser.uid;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.matches = [[NSMutableArray alloc] init];
    self.contacts = [[NSMutableArray alloc] init];
    [self configureDatabase];
}

- (void) configureDatabase {
    _ref = [[FIRDatabase database] reference];
    _refHandleChanged = [[[[_ref child:@"Users"] child:self.userID] child:@"games"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"History changed: %@", snapshot);
        [self.matches removeAllObjects];
        if (![snapshot.value isEqual:[NSNull null]]) {
            NSDictionary<NSString *, NSDictionary*> *value = snapshot.value;
            for (NSString *key in value) {
                NSDictionary<NSString *, NSObject *> *game = value[key];
                BOOL b = [game valueForKey:@"played"];
                if (b) {
                    [self.matches addObject:value[key]];
                }
            }
            [self.tableView reloadData];
        }
        
    }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    HistoryDetailViewController *detail = segue.destinationViewController;
    NSDictionary<NSString *, NSObject *> *match = self.matches[row];
    detail.data = match;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameRowCell"];
    NSDictionary<NSString *, NSObject *> *match = self.matches[indexPath.row];
    cell.textLabel.text =[NSString stringWithFormat:@"%@", match[@"name"]];
    return (UITableViewCell *)cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.matches.count;
}

@end
