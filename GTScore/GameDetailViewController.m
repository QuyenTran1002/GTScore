//
//  GameDetailViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "GameDetailViewController.h"

@interface GameDetailViewController ()

@end

@implementation GameDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameNameLabel.text = self.gameName;
    NSArray *array = [self.gameName componentsSeparatedByString:@" vs. "];
    self.player1Label.text = array[0];
    self.player2Label.text = array[1];
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
