//
//  Meal.h
//  HTMLParsing
//
//  Created by Kyle Liu on 8/13/14.
//  Copyright (c) 2014 Kyle Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Meal : NSObject
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *transaction;
@property (nonatomic, copy) NSString *tenderUsed;
@property (nonatomic, copy) NSString *amountOfSale;
@property (nonatomic, copy) NSString *currentBalance;
@end
