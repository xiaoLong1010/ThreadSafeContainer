//
//  CXLThreadSafeMutableArray.m
//  ThreadSafeContainer
//
//  Created by Csy on 28/01/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#import "CXLThreadSafeMutableArray.h"
#import "CXLThreadSafeHeader.h"

@implementation CXLThreadSafeMutableArray {
    pthread_mutex_t _lock;
    CFMutableArrayRef _array;
}
- (void)dealloc {
    if (&_lock) {
        pthread_mutex_destroy(&_lock);
    }
    if (_array) {
        CFRelease(_array);
        _array = NULL;
    }
}

#pragma mark - Init
+ (instancetype)array {
    return [[self alloc] init];
}

+ (instancetype)arrayWithCapacity:(NSUInteger)num {
    return [[self alloc] initWithCapacity:num];
}

+ (instancetype)arrayWithArray:(NSArray *)anArray {
    CXLThreadSafeMutableArray *array = [[self alloc] init];
    [array addObjectsFromArray:anArray];
    return array;
}
+ (instancetype)arrayWithObject:(id)anObject {
    CXLThreadSafeMutableArray *array = [[self alloc] init];
    [array addObject:anObject];
    return array;
}

- (instancetype)init {
    return [self initWithCapacity:kDefaultCapacity];
}

- (instancetype)initWithCapacity:(NSUInteger)num {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _array = CFArrayCreateMutable(kCFAllocatorDefault, num,  &kCFTypeArrayCallBacks);
    }
    return self;
}

#pragma mark - Copy
- (id)copyWithZone:(NSZone *)zone {
    NSArray *array = nil;
    
    LOCK
    CFArrayRef arrayRef = CFArrayCreateCopy(kCFAllocatorDefault, _array);
    if (arrayRef) {
        array = CFBridgingRelease(arrayRef);
    }
    UNLOCK
    
    return array;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSMutableArray *mutableArray = nil;
    
    LOCK
    CFMutableArrayRef mutableArrayRef = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(_array),_array);
    if (mutableArrayRef) {
        mutableArray = CFBridgingRelease(mutableArrayRef);
    }
    UNLOCK
    
    return mutableArray;
}


#pragma mark - Add
- (void)addObject:(id)anObject {
    if (!anObject) {
        return;
    }
    
    LOCK
    CFArrayAppendValue(_array, (__bridge const void *)anObject);
    UNLOCK
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    if (!([otherArray isKindOfClass:[NSArray class]] && (otherArray.count > 0))) {
        return;
    }
    //Ensure is NSArray
    NSArray *copiedArray = [otherArray copy];
    
    LOCK
    [copiedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CFArrayAppendValue(_array, (__bridge const void *)obj);
    }];
    UNLOCK
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {
        return;
    }
    
    LOCK
    NSUInteger count = CFArrayGetCount(_array);
    if (index <= count) {
        CFArrayInsertValueAtIndex(_array, index, (__bridge const void *)anObject);
    }
    UNLOCK
}

#pragma mark - Remove
- (void)removeObjectAtIndex:(NSUInteger)index {
    LOCK
    [self p_removeObjectAtIndex:index];
    UNLOCK
}

- (void)removeLastObject {
    LOCK
    NSUInteger count = CFArrayGetCount(_array);
    if (count > 0) {
        CFArrayRemoveValueAtIndex(_array, count - 1);
    }
    UNLOCK
}

- (void)removeObject:(id)anObject {
    if (!anObject) {
        return;
    }
    //Removes all occurrences
    LOCK
    NSUInteger count = CFArrayGetCount(_array);
    
    //找到第一个anObject对象
    NSUInteger destination = [self p_indexOfObject:anObject];
    if (NSNotFound == destination) {
        return;
    }
    
    //遍历，将非anObject对象移动到正确的位置
    NSUInteger source  = destination + 1;
    while (source < count) {
        id candidate = CFArrayGetValueAtIndex(_array, source);
        if (!((anObject == candidate) || [candidate isEqual:anObject])) {
            CFArraySetValueAtIndex(_array, destination, (__bridge const void*)candidate);
            destination++;
        }
        source++;
    }
    
    //从数组后面开始remove，效率更高
    NSUInteger waste = count - 1;
    while (waste >= destination) {
        CFArrayRemoveValueAtIndex(_array, waste);
        waste--;
    }
    UNLOCK
}

- (void)removeAllObjects {
    LOCK
    CFArrayRemoveAllValues(_array);
    UNLOCK
}

#pragma mark - Replace
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (!anObject) {
        return;
    }
    
    LOCK
    NSUInteger count = CFArrayGetCount(_array);
    if (index < count) {
        CFArraySetValueAtIndex(_array, index, (__bridge const void*)anObject);
    }
    UNLOCK
}

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index {
    if (!anObject) {
        return;
    }
    
    LOCK
    NSUInteger count = CFArrayGetCount(_array);
    //根据官方文档定义，可以等于count，进行grow
    if (index <= count) {
        CFArraySetValueAtIndex(_array, index, (__bridge const void*)anObject);
    }
    UNLOCK
}

#pragma mark - Query
- (NSUInteger)count {
    LOCK
    NSUInteger result = CFArrayGetCount(_array);
    UNLOCK
    
    return result;
}

- (NSUInteger)indexOfObject:(id)anObject {
    LOCK
    NSUInteger result = [self p_indexOfObject:anObject];
    UNLOCK
    
    return result;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return  [self objectAtIndex:index];
}

- (id)objectAtIndex:(NSUInteger)index {
    LOCK
    id result = [self p_objectAtIndex:index];
    UNLOCK
    
    return result;
}

- (id)firstObject {
    LOCK
    id result =[self p_objectAtIndex:0];
    UNLOCK
    
    return result;
}

- (id)lastObject {
    LOCK
    NSUInteger count = CFArrayGetCount(_array);
    id result = nil;
    if (count > 0) {
        result = [self p_objectAtIndex:count - 1];
    }
    UNLOCK
    
    return result;
}

#pragma mark - Enumerate
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    if (!block) {
        return;
    }
    
    LOCK
    NSUInteger count = CFArrayGetCount(_array);
    if (count > 0) {
        BOOL stop = NO;
        for (NSUInteger index = 0; index < count; index++) {
            if (stop) {
                break;
            }
            id obj = [self p_objectAtIndex:index];
            block(obj, index, &stop);
        }
    }
    UNLOCK
}

#pragma mark - Private Unlock
- (NSUInteger)p_indexOfObject:(id)anObject {
    if (!anObject) {
        return NSNotFound;
    }
    
    NSUInteger count = CFArrayGetCount(_array);
    CFIndex result = CFArrayGetFirstIndexOfValue(_array, CFRangeMake(0, count), (__bridge const void *)(anObject));
    if (result == kCFNotFound) {
        return NSNotFound;
    }
    return result;
}

- (void)p_removeObjectAtIndex:(NSUInteger)index {
    NSUInteger count = CFArrayGetCount(_array);
    if (index < count) {
        CFArrayRemoveValueAtIndex(_array, index);
    }
}

- (id)p_objectAtIndex:(NSUInteger)index {
    NSUInteger count = CFArrayGetCount(_array);
    id result = index < count ? CFArrayGetValueAtIndex(_array, index) : nil;
    return result;
}


@end
