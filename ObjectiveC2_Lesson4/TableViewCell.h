//
//  TableViewCell.h
//  ObjectiveC2_Lesson4
//
//  Created by Admin on 16.05.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label_City;
@property (weak, nonatomic) IBOutlet UILabel *label_Street;
@property (weak, nonatomic) IBOutlet UILabel *label_ZIP;

@end
