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
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *matches;
@property (strong, nonatomic) NSMutableDictionary<FIRDataSnapshot *, NSString *> *dictionary;
@end

@implementation GameListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userID = [FIRAuth auth].currentUser.uid;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _matches = [[NSMutableArray alloc] init];
    _dictionary = [[NSMutableDictionary alloc] init];
    [self configureDatabase];
}

- (void) configureDatabase {
    _ref = [[FIRDatabase database] reference];
    _refHandleAdded = [[[[_ref child:@"Users"] child:self.userID] child:@"Matches"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary<NSString *, NSString *> *match = snapshot.value;
        [_matches addObject:snapshot];
        [self.dictionary setValue:[NSString stringWithFormat:@"%lu", [_matches count]]  forKey:match[@"Name"]];
        [self.tableView reloadData];
        
    }];
    _refHandleEdit = [[[[_ref child:@"User"] child:self.userID] child:@"Matches"] observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary<NSString *, NSString *> *match = snapshot.value;
        NSInteger index = self.dictionary[match[@"Name"]];
        [_matches replaceObjectAtIndex:index withObject:snapshot];
        [self.tableView reloadData];
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
    NSDictionary<NSString *, NSString *> *match = _matches[row].value;
    detail.data = match;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self performSegueWithIdentifier:@"GameListRowSegue" sender:self];
//}
//

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameRowCell"];
    NSDictionary<NSString *, NSString *> *match = _matches[indexPath.row].value;
    cell.textLabel.text = match[@"Name"];
    return (UITableViewCell *)cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.matches.count;
}

@end
