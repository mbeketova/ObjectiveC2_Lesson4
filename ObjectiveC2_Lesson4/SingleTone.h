//
//  SingleTone.h
//  ObjectiveC2_Lesson4
//
//  Created by Admin on 16.05.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleTone : NSObject

+ (SingleTone*) sharedSingleTone;

@property (nonatomic, strong) NSMutableArray * arrayAdress;



@end
