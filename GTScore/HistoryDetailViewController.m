//
//  HistoryDetailViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 4/1/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "HistoryDetailViewController.h"

@interface HistoryDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UITextField *player1Score;
@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UITextField *player2Score;

@end

@implementation HistoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _gameNameLabel.text = [NSString stringWithFormat:@"%@",[_data valueForKey:@"name"]];
    _player1Label.text = [NSString stringWithFormat:@"%@",[_data valueForKey:@"player1Name"]];
    _player2Label.text = [NSString stringWithFormat:@"%@",[_data valueForKey:@"player2Name"]];
    _player1Score.text = [NSString stringWithFormat:@"%@",[_data valueForKey:@"score1"]];
    _player2Score.text = [NSString stringWithFormat:@"%@",[_data valueForKey:@"score2"]];
    // Do any additional setup after loading the view.
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
