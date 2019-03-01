//
//  GameDetailViewController.h
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (nonatomic, strong) NSString *gameName;
@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;

@end

NS_ASSUME_NONNULL_END
