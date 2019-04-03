//
//  GameListViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "GameListViewController.h"
#import "GameDetailViewController.h"
@import Firebase;

@interface GameListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<NSString *> *tableItems;
@property (weak, nonatomic) NSString *userID;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *matches;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *contacts;

@end

@implementation GameListViewController

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
    _refHandleChanged = [[[[_ref child:@"Users"] child:self.userID] child:@"Matches"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"changed: %@", snapshot);
        [self.matches removeAllObjects];
        NSDictionary<NSString *, NSDictionary*> *value = snapshot.value;
        for (NSString *key in value) {
            [self.matches addObject:value[key]];
        }
        [self.tableView reloadData];
    }];
    [[[[_ref child:@"Users"] child:self.userID] child:@"Friends"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.contacts removeAllObjects];
    }];
    
}
- (IBAction)addNewListItem:(id)sender {
    [self.tableItems addObject:[NSString stringWithFormat:@"You vs. %@", [NSDate date]]];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    GameDetailViewController *detail = segue.destinationViewController;
    NSDictionary<NSString *, NSString *> *match = self.matches[row];
    detail.data = match;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameRowCell"];
    NSDictionary<NSString *, NSString *> *match = self.matches[indexPath.row];
    cell.textLabel.text = match[@"Name"];
    return (UITableViewCell *)cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.matches.count;
}

@end
