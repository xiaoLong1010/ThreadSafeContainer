//
//  CXLThreadSafeMutableDictionary.m
//  ThreadSafeContainer
//
//  Created by Csy on 14/02/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#import "CXLThreadSafeMutableDictionary.h"
#import "CXLThreadSafeHeader.h"

@implementation CXLThreadSafeMutableDictionary {
    pthread_mutex_t _lock;
    CFMutableDictionaryRef _dictionary;
}

- (void)dealloc {
    if (&_lock) {
        pthread_mutex_destroy(&_lock);
    }
    if (_dictionary) {
        CFRelease(_dictionary);
        _dictionary = NULL;
    }
}

#pragma mark - Init
+ (instancetype)dictionary {
    return [[self alloc] init];
}

+ (instancetype)dictionaryWithCapacity:(NSUInteger)num {
    return [[self alloc] initWithCapacity:num];
}

+ (instancetype)dictionaryWithDictionary:(NSDictionary *)otherDictionary {
    CXLThreadSafeMutableDictionary *dictionary = [[self alloc] init];
    [dictionary addEntriesFromDictionary:otherDictionary];
    return dictionary;
}

+ (instancetype)dictionaryWithObject:(id)anObject forKey:(id<NSCopying>)aKey {
    CXLThreadSafeMutableDictionary *dictionary = [[self alloc] init];
    [dictionary setObject:anObject forKey:aKey];
    return dictionary;
}

- (instancetype)init {
    return [self initWithCapacity:kDefaultCapacity];
}

- (instancetype)initWithCapacity:(NSUInteger)num {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, num,
                                                &kCFTypeDictionaryKeyCallBacks,
                                                &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

#pragma mark - Copy
- (id)copyWithZone:(NSZone *)zone {
    NSDictionary *dictionary = nil;
    
    LOCK
    CFDictionaryRef dictionaryRef = CFDictionaryCreateCopy(kCFAllocatorDefault, _dictionary);
    if (dictionaryRef) {
        dictionary = CFBridgingRelease(dictionaryRef);
    }
    UNLOCK
    
    return dictionary;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSMutableDictionary *mutableDictionary = nil;
    
    LOCK
    CFMutableDictionaryRef mutableDictionaryRef = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, CFDictionaryGetCount(_dictionary), _dictionary);
    if (mutableDictionaryRef) {
        mutableDictionary = CFBridgingRelease(mutableDictionaryRef);
    }
    UNLOCK
    
    return mutableDictionary;
}
#pragma mark - Add
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!anObject || !aKey) {
        return;
    }
    
    LOCK
    CFDictionarySetValue(_dictionary, (__bridge const void *)aKey, (__bridge const void *)anObject);
    UNLOCK
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey {
    [self setObject:object forKey:aKey];
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    if (!([otherDictionary isKindOfClass:[NSDictionary class]] && (otherDictionary.count > 0))) {
        return;
    }
    
    //Ensure is NSDictionary
    NSDictionary *copiedDictionary = [otherDictionary copy];
    
    LOCK
    [copiedDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        CFDictionarySetValue(_dictionary, (__bridge const void *)key, (__bridge const void *)obj);
    }];
    UNLOCK
}

#pragma mark - Remove
- (void)removeObjectForKey:(id)aKey {
    if (!aKey) {
        return;
    }
    
    LOCK
    CFDictionaryRemoveValue(_dictionary, (__bridge const void *)aKey);
    UNLOCK
}

- (void)removeAllObjects {
    LOCK
    CFDictionaryRemoveAllValues(_dictionary);
    UNLOCK
}

#pragma mark - Query
- (NSUInteger)count {
    LOCK
    NSUInteger count = CFDictionaryGetCount(_dictionary);
    UNLOCK
    
    return count;
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (id)objectForKey:(id)aKey {
    if (!aKey) {
        return nil;
    }
    
    LOCK
    id result = CFDictionaryGetValue(_dictionary, (__bridge const void *)(aKey));
    UNLOCK
    
    return result;
}

#pragma mark - Enumerate
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    if (!block) {
        return;
    }
    
    LOCK
    NSUInteger count = CFDictionaryGetCount(_dictionary);
    if (count > 0) {
        CFTypeRef *keys = malloc(count * sizeof(CFTypeRef));
        CFTypeRef *values = malloc(count * sizeof(CFTypeRef));
        
        CFDictionaryGetKeysAndValues(_dictionary, (const void **) keys, (const void **) values);
        
        BOOL stop = NO;
        for (NSUInteger index = 0; index < count; index++) {
            if (stop) {
                break;
            }
            
            id key = (__bridge id)(keys[index]);
            id obj = (__bridge id)(values[index]);
            block(key, obj, &stop);
        }
        
        free(keys);
        free(values);
    }
    UNLOCK
}

@end
