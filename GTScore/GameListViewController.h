//
//  GameListViewController.h
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
NS_ASSUME_NONNULL_BEGIN

@interface GameListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    FIRDatabaseHandle _refHandleAdded;
    FIRDatabaseHandle _refHandleEdit;
}
@end

NS_ASSUME_NONNULL_END
