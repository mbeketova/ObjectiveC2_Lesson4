//
//  SingleTone.m
//  ObjectiveC2_Lesson4
//
//  Created by Admin on 16.05.15.
//  Copyright (c) 2015 Mariya Beketova. All rights reserved.
//

#import "SingleTone.h"

@implementation SingleTone

+ (SingleTone*) sharedSingleTone {
    
    static SingleTone * singleToneObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^ {
        
        singleToneObject = [[self alloc]init];
        singleToneObject.arrayAdress = [[NSMutableArray alloc] init];
        
    });
    
    return singleToneObject;
    
}

@end
