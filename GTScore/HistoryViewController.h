//
//  HistoryViewController.h
//  GTScore
//
//  Created by Hai-Dang Dam on 4/1/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
NS_ASSUME_NONNULL_BEGIN

@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    FIRDatabaseHandle _refHandleChanged;
}

@end

NS_ASSUME_NONNULL_END
