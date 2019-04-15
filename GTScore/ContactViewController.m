//
//  ContactViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 4/1/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactTableCell.h"
#import "SendInvitationViewController.h"
#import "AddContactViewController.h"

@import Firebase;

@interface ContactViewController ()
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *contacts;
@property (strong, nonatomic) NSMutableArray<NSString *> *listUid;
@property (weak, nonatomic) NSString *userID;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *name;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userID = [FIRAuth auth].currentUser.uid;
    [self configureDatabase];
    _contacts = [[NSMutableArray alloc] init];
    _listUid = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

- (void) configureDatabase {
    _ref = [[FIRDatabase database] reference];
    _refHandleChanged = [[[[_ref child:@"Users"] child:self.userID] child:@"friends"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.contacts removeAllObjects];
        if (![snapshot.value isEqual:[NSNull null]]) {
            NSLog(@"Contact changed: %@", snapshot);
            NSDictionary<NSString *, NSDictionary*> *value = snapshot.value;
            for (NSString *key in value) {
                [self.listUid addObject:key];
                [self.contacts addObject:value[key]];
            }
            [self.tableView reloadData];
        }
    }];
    [[FIRDatabase database] reference];_refHandleChanged = [[[[_ref child:@"Users"] child:self.userID] child:@"name"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"changed: %@", snapshot);
        if (![snapshot.value isEqual:[NSNull null]]) {
            _name = snapshot.value;
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"PushToInvite"]) {
        SendInvitationViewController *vc = [segue destinationViewController];
        long selectedRow = self.tableView.indexPathForSelectedRow.row;
        NSDictionary *matchingDict = self.contacts[selectedRow];
        vc.data = matchingDict;
        vc.name = _name;
    }
    if ([[segue identifier] isEqualToString:@"AddContact"]) {
        AddContactViewController *vc = [segue destinationViewController];
        vc.currentContact = self.listUid;
        vc.name = _name;
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UILabel *name = (UILabel *)[cell viewWithTag:100];
    NSDictionary<NSString *, NSObject *> *contact = self.contacts[indexPath.row];
    [name setText:[NSString stringWithFormat:@"%@", contact[@"name"]]];
    return (UITableViewCell *)cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}
@end
