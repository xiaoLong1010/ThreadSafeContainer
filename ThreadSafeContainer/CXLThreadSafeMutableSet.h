//
//  CXLThreadSafeMutableSet.h
//  ThreadSafeContainer
//
//  Created by Csy on 14/02/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface CXLThreadSafeMutableSet : NSObject

#pragma mark - Init
+ (instancetype)set;
+ (instancetype)setWithCapacity:(NSUInteger)num;
+ (instancetype)setWithArray:(NSArray *)array;
+ (instancetype)setWithObject:(id)object;

#pragma mark - Add
- (void)addObject:(id)object;
- (void)addObjectsFromArray:(NSArray *)array;

#pragma mark - Remove
- (void)removeObject:(id)object;
- (void)removeAllObjects;

#pragma mark - Query
- (NSUInteger)count;
- (nullable NSArray *)allObjects;

#pragma mark - Enumerate
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;

@end
NS_ASSUME_NONNULL_END
