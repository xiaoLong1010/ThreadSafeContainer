//
//  CXLThreadSafeMutableDictionary.h
//  ThreadSafeContainer
//
//  Created by Csy on 14/02/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface CXLThreadSafeMutableDictionary : NSObject

#pragma mark - Init
+ (instancetype)dictionary;
+ (instancetype)dictionaryWithCapacity:(NSUInteger)num;
+ (instancetype)dictionaryWithDictionary:(NSDictionary *)otherDictionary;
+ (instancetype)dictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey;

#pragma mark - Add
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey;
- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary;

#pragma mark - Remove
- (void)removeObjectForKey:(id)aKey;
- (void)removeAllObjects;

#pragma mark - Query
- (NSUInteger)count;
- (nullable id)objectForKeyedSubscript:(id)key;
- (nullable id)objectForKey:(id)aKey;

#pragma mark - Enumerate
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;

@end
NS_ASSUME_NONNULL_END
