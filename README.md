# ThreadSafeContainer
系统的NSMutableArray，NSMutableDictionary，NSMutableSet都是线程不安全的。对于线程安全问题，有经验的程序员有多种方法解决，比如锁，或者将容器的所有读写操作放到串行队列。但有时，一个线程安全的容器使得代码更加简洁和优雅。


苹果官方文档不建议继承系统容器（There is typically little reason to subclass NSMutableArray），所以可以通过组合的方式实现线程安全容器。

# 1 使用方法
将源码拖入工程。

# 2 接口说明
容器包含5种类型的接口，分别是

- Init
- Add
- Remove
- Query
- Enumerate
- copy/mutableCopy，转换成系统的容器

# 3 内部实现

有多个解决线程安全的锁，从性能上来说，最好的是`OSSpinLock`。但根据相关文档，`OSSpinLock`在新版 iOS 中已经不能再保证安全了，故使用了`pthread_mutex_t`作为替代方案。

为了提高性能，内部使用CoreFoundation容器，并且使用直接访问成员的方式，而不使用点语法。

更快的removeObject:实现

removeObject：需要删除数组中所有的object，一般的实现方式，其时间复杂度是O(n^2)

```
	NSUInteger count = CFArrayGetCount(_array);
	for (NSUInteger index = 0; index < count; index++) {
	    NSUInteger index = [self p_indexOfObject:anObject];
	    [self p_removeObjectAtIndex:index];
	}
    
```
通过移动元素，时间复杂度可以降低到哦O(n)

```
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

```

