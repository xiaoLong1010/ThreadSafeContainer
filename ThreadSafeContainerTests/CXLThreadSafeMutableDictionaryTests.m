//
//  CXLThreadSafeMutableDictionaryTests.m
//  ThreadSafeContainerTests
//
//  Created by Csy on 14/02/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CXLThreadSafeMutableDictionary.h"

static const NSString * const kKey1 = @"1";
static const NSString * const kKey2 = @"2";
static const NSString * const kKey3 = @"3";
static const NSString * const kKey4 = @"4";

static const NSString * const kObject1 = @"5";
static const NSString * const kObject2 = @"6";
static const NSString * const kObject3 = @"7";
static const NSString * const kObject4 = @"8";


@interface BaiduAPMThreadSafeMutableDictionaryTests : XCTestCase

@property (nonatomic, strong) CXLThreadSafeMutableDictionary *dictionary;

@end

@implementation BaiduAPMThreadSafeMutableDictionaryTests

- (void)setUp {
    [super setUp];
    
    self.dictionary = [CXLThreadSafeMutableDictionary dictionary];
    [self.dictionary setObject:kObject1 forKey:kKey1];
    [self.dictionary setObject:kObject2 forKey:kKey2];
    [self.dictionary setObject:kObject3 forKey:kKey3];}

- (void)tearDown {
    self.dictionary = nil;
    
    [super tearDown];
}

- (void)testInit {
    CXLThreadSafeMutableDictionary *dictionary = [CXLThreadSafeMutableDictionary dictionary];
    XCTAssertNotNil(dictionary);
    
    dictionary = nil;
    dictionary = [CXLThreadSafeMutableDictionary dictionaryWithCapacity:10];
    XCTAssertNotNil(dictionary);
    
    dictionary = nil;
    dictionary = [CXLThreadSafeMutableDictionary dictionaryWithDictionary:@{kKey1 : kObject1, kKey2 : kObject2}];
    XCTAssertNotNil(dictionary);
    
    dictionary = nil;
    dictionary = [CXLThreadSafeMutableDictionary dictionaryWithObject:kObject2 forKey:kKey2];
    XCTAssertNotNil(dictionary);
}

- (void)testCopy {
    XCTAssertTrue(self.dictionary.count == 3);
    
    NSDictionary *copiedDictionary = [self.dictionary copy];
    XCTAssertTrue([copiedDictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(copiedDictionary[kKey3], kObject3);
    
    NSMutableDictionary *mutableCopiedDictionary = [self.dictionary mutableCopy];
    XCTAssertTrue([mutableCopiedDictionary isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertEqualObjects(mutableCopiedDictionary[kKey3], kObject3);
}

- (void)testAddRemove {
    NSObject * nilKey = nil;
    NSObject * nilObject = nil;
    NSDictionary * nilDict = nil;
    //Add
    [self.dictionary setObject:nilObject forKey:kKey1];
    XCTAssertTrue(self.dictionary.count == 3);
    
    self.dictionary[kKey4] = kObject4;
    XCTAssertTrue(self.dictionary.count == 4);
    
    //Remove
    [self.dictionary removeObjectForKey:kKey1];
    [self.dictionary removeObjectForKey:nilKey];
    [self.dictionary removeObjectForKey:@"123"];
    XCTAssertTrue(self.dictionary.count == 3);
    
    [self.dictionary removeAllObjects];
    XCTAssertTrue(self.dictionary.count == 0);
    
    //Add Entries
    [self.dictionary addEntriesFromDictionary:nilDict];
    [self.dictionary addEntriesFromDictionary:@{kKey1 : kObject1, kKey2 : kObject2}];
    XCTAssertTrue(self.dictionary.count == 2);
}

- (void)testQuery {
    NSObject * nilKey = nil;
    XCTAssertTrue(self.dictionary.count == 3);
    
    XCTAssertEqualObjects([self.dictionary objectForKey:kKey1], kObject1);
    XCTAssertEqualObjects([self.dictionary objectForKey:kKey2], kObject2);
    XCTAssertEqualObjects([self.dictionary objectForKey:kKey3], kObject3);
    XCTAssertEqualObjects([self.dictionary objectForKey:kKey4], nil);
    XCTAssertEqualObjects([self.dictionary objectForKey:nilKey], nil);
    
    XCTAssertEqualObjects(self.dictionary[kKey1], kObject1);
    XCTAssertEqualObjects(self.dictionary[kKey2], kObject2);
    XCTAssertEqualObjects(self.dictionary[kKey3], kObject3);
    XCTAssertEqualObjects(self.dictionary[kKey4], nil);
    XCTAssertEqualObjects(self.dictionary[nilKey], nil);
}

- (void)testEnumerate {
    XCTAssertTrue(self.dictionary.count == 3);
    
    __block NSInteger count = 0;
    [self.dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        count++;
        if (key == kKey1) {
            XCTAssertEqualObjects(obj, kObject1);
        }
        if (key == kKey2) {
            XCTAssertEqualObjects(obj, kObject2);
        }
        if (key == kKey3) {
            XCTAssertEqualObjects(obj, kObject3);
        }
    }];
    XCTAssertEqual(count, 3);
    
    count = 0;
    [self.dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        count++;
        if (key == kKey1) {
            *stop = YES;
        }
    }];
    XCTAssertLessThanOrEqual(count, 3);
}

@end

