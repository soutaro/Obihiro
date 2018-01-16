#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OBHViewControllerObject;

@interface OBHUIPredicate : NSObject

@property (nonatomic, weak, readonly) __kindof OBHViewControllerObject *object;

- (instancetype)initWithObject:(OBHViewControllerObject *)object test:(BOOL(^)(void))test;

@property (nonatomic, readonly) BOOL holds;
@property (nonatomic, readonly) BOOL doesntHold;

@property (nonatomic, readonly) __kindof OBHUIPredicate *negation;

@end

NS_ASSUME_NONNULL_END
