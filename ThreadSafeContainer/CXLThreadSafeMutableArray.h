//
//  CXLThreadSafeMutableArray.h
//  ThreadSafeContainer
//
//  Created by Csy on 28/01/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface CXLThreadSafeMutableArray : NSObject <NSCopying, NSMutableCopying>

#pragma mark - Init
+ (instancetype)array;
+ (instancetype)arrayWithCapacity:(NSUInteger)num;
+ (instancetype)arrayWithArray:(NSArray *)anArray;
+ (instancetype)arrayWithObject:(id)anObject;

#pragma mark - Add
- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)otherArray;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;

#pragma mark - Remove
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeLastObject;
/**
 Removes all occurrences in the array of a given object.
 */
- (void)removeObject:(id)anObject;
- (void)removeAllObjects;

#pragma mark - Replace
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
/**
 Replaces the object at the index with the new object, possibly adding the object.
 */
- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index;

#pragma mark - Query
- (NSUInteger)count;
/**
 Returns the lowest index whose corresponding array value is equal to a given object.
 */
- (NSUInteger)indexOfObject:(id)anObject;
- (nullable id)objectAtIndexedSubscript:(NSUInteger)index;
- (nullable id)objectAtIndex:(NSUInteger)index;
- (nullable id)firstObject;
- (nullable id)lastObject;

#pragma mark - Enumerate
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
NS_ASSUME_NONNULL_END
