//
//  CXLThreadSafeHeader.h
//  ThreadSafeContainer
//
//  Created by Csy on 28/01/2018.
//  Copyright © 2018 Csy. All rights reserved.
//

#ifndef CXLThreadSafeHeader_h
#define CXLThreadSafeHeader_h

#import <pthread.h>

static const NSUInteger kDefaultCapacity = 5;

#define LOCK       pthread_mutex_lock(&_lock);
#define UNLOCK     pthread_mutex_unlock(&_lock);

#endif /* CXLThreadSafeHeader_h */
