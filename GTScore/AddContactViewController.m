//
//  AddContactViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 4/14/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "AddContactViewController.h"
#import "AddContactActionViewController.h"

@import Firebase;
@interface AddContactViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *contacts;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _ref = [[FIRDatabase database] reference];
    _contacts = [[NSMutableArray alloc] init];
    [_currentContact addObject:[FIRAuth auth].currentUser.uid];
    [self configureDatabase];
    // Do any additional setup after loading the view.
}

- (void) configureDatabase {
    [[_ref child:@"Users"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"History changed: %@", snapshot);
        [self.contacts removeAllObjects];
        if (![snapshot.value isEqual:[NSNull null]]) {
            NSDictionary<NSString *, NSDictionary*> *value = snapshot.value;
            for (NSString *key in value) {
                if (![_currentContact containsObject:key]) {
                    [self.contacts addObject:value[key]];
                }
            }
            [self.tableView reloadData];
        }
        
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    AddContactActionViewController *detail = segue.destinationViewController;
    NSDictionary<NSString *, NSObject *> *match = self.contacts[row];
    detail.data = match;
    detail.name = _name;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary<NSString *, NSObject *> *cont = self.contacts[indexPath.row];
    cell.textLabel.text =[NSString stringWithFormat:@"%@", cont[@"name"]];
    return (UITableViewCell *)cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
