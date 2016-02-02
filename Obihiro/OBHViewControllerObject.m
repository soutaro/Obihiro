#import "OBHViewControllerObject.h"
#import "UIViewController+OBH.h"
#import "OBHViewControllerObjectRef.h"
#import "OBHNavigationControllerObject.h"
#import "OBHAlertControllerObject.h"

static NSTimeInterval runLoopTimeout = 0.1;

@interface OBHViewControllerObject ()

@property (nonatomic) OBHViewControllerObject *parentObject;
@property (nonatomic) NSMutableArray<OBHViewControllerObjectRef *> *objectRefs;
@property (nonatomic) NSMutableDictionary<NSString *, Class> *classRegistory;

@end

@implementation OBHViewControllerObject

+ (instancetype)objectWithViewController:(UIViewController *)viewController {
    return [[self alloc] initWithViewController:viewController parentObject:nil];
}

+ (instancetype)objectWithIdentifier:(NSString *)identifier fromStoryBoardWithName:(NSString *)name {
    UIStoryboard *storyboard =[UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    return [self objectWithViewController:viewController];
}

+ (instancetype)objectWithInitialViewControllerFromStoryBoardWithName:(NSString *)name {
    UIStoryboard *storyboard =[UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *viewController = [storyboard instantiateInitialViewController];
    
    return [self objectWithViewController:viewController];
}

#pragma mark - Initialize

- (instancetype)initWithViewController:(UIViewController *)viewController parentObject:(OBHViewControllerObject *)parentObject {
    self = [self init];
    
    _parentObject = parentObject;
    _viewController = viewController;
    
    self.defaultTimeout = 0.4;
    if (!self.parentObject) {
        self.objectRefs = [NSMutableArray new];
    }
    self.classRegistory = [NSMutableDictionary new];
    
    [self initializeObject];
    
    return self;
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    return [self initWithViewController:viewController parentObject:nil];
}

- (void)initializeObject {
    // Do nothing
}

- (void)dealloc {
    if (self.isPresented && self.viewController.parentViewController == nil) {
        [self dismissViewController];
    }
}

#pragma mark -

- (void)registerObjectClass:(Class)objectClass forViewControllerClass:(Class)viewControllerClass {
    self.classRegistory[NSStringFromClass(viewControllerClass)] = objectClass;
}

- (void)registerObjectClass:(Class)objectClass {
    NSString *objectClassName = NSStringFromClass(objectClass);
    if ([objectClassName hasSuffix:@"Object"]) {
        NSString *viewControllerClassName = [objectClassName substringToIndex:objectClassName.length - 6];
        Class viewControllerClass = NSClassFromString(viewControllerClassName);
        if (viewControllerClass) {
            [self registerObjectClass:objectClass forViewControllerClass:viewControllerClass];
        } else {
            NSLog(@"%s Object class registration failed: invalid guessed ViewController class name %@", __PRETTY_FUNCTION__, viewControllerClassName);
        }
    } else {
        NSLog(@"%s Object class registration failed: cannot guess ViewController class from %@", __PRETTY_FUNCTION__, objectClassName);
    }
}

#pragma mark - ViewController Containment

- (NSArray<OBHViewControllerObject *> *)childObjectsOfViewControllerClass:(Class)klass {
    [self ensureAllViewsDidAppear];
    
    NSMutableArray<__kindof OBHViewControllerObject *> *childObjects = [NSMutableArray new];
    
    for (UIViewController *viewController in self.viewController.childViewControllers) {
        if ([viewController isKindOfClass:klass]) {
            OBHViewControllerObject *object = [self childObjectWithViewController:viewController];
            [childObjects addObject:object];
        }
    }
    
    return childObjects;
}

- (OBHViewControllerObject *)firstChildObjectOfViewControllerClass:(Class)klass {
    return [self childObjectsOfViewControllerClass:klass].firstObject;
}

- (OBHViewControllerObject *)objectWithViewController:(UIViewController *)viewController {
    return [self childObjectWithViewController:viewController];
}

#pragma mark -

- (OBHViewControllerObject *)presentedObjectOfViewControllerClass:(Class)klass {
    [self ensureAllViewsDidAppear];
    
    UIViewController *presentedViewController = self.viewController.presentedViewController;
    
    if (presentedViewController && [presentedViewController isKindOfClass:klass]) {
        return [self childObjectWithViewController:presentedViewController];
    } else {
        return nil;
    }
}

- (OBHViewControllerObject *)presentedPopoverObject {
    [self ensureAllViewsDidAppear];
    
    UIViewController *presentedViewController = self.viewController.presentedViewController;
    
    if (presentedViewController && presentedViewController.modalPresentationStyle == UIModalPresentationPopover) {
        return [self objectWithViewController:presentedViewController];
    } else {
        return nil;
    }
}

- (OBHAlertControllerObject *)alertObject {
    return [self presentedObjectOfViewControllerClass:[UIAlertController class]];
}

- (BOOL)hasAlert {
    [self ensureAllViewsDidAppear];
    
    return [self.viewController.presentedViewController isKindOfClass:[UIAlertController class]];
}

#pragma mark - View

- (UIView *)view {
    return self.viewController.view;
}

- (NSArray<UIView *> *)descendantViewsOfClass:(Class)klass {
    NSMutableArray<UIView *> *array = [NSMutableArray new];
    [self addViews:self.view class:klass toArray:array];
    return array;
}

- (UIView *)firstDescendantViewOfClass:(__unsafe_unretained Class)klass {
    return [self descendantViewsOfClass:klass].firstObject;
}

- (void)addViews:(UIView *)view class:(Class)klass toArray:(NSMutableArray<UIView *> *)array {
    if ([view isKindOfClass:klass]) {
        [array addObject:view];
    }
    
    for (UIView *subview in view.subviews) {
        [self addViews:subview class:klass toArray:array];
    }
}

#pragma mark - User Action

- (void)simulateUserAction:(void (^)())action {
    action();
    [self.class runLoopForSeconds:0.1];
}

#pragma mark - Present/Dismiss

- (void)presentViewController {
    if (self.isPresented) {
        NSLog(@"%s ViewController is already presented: presentingViewController=%@", __PRETTY_FUNCTION__, self.viewController.presentingViewController);
        return;
    }
    
    if (self.viewController.parentViewController) {
        NSLog(@"%s Cannot present ViewController because it has parentViewController: parentViewController=%@", __PRETTY_FUNCTION__, self.viewController.parentViewController);
        return;
    }
    
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    
    UIViewController *root = window.rootViewController;
    
    __block BOOL done = NO;
    [root presentViewController:self.viewController animated:NO completion:^{
        done = YES;
    }];
    
    [self waitFor:^{ return done; }];
}

- (void)dismissViewController {
    if (!self.isPresented) {
        NSLog(@"%s ViewController is not yet presented", __PRETTY_FUNCTION__);
        return;
    }

    if (self.viewController.parentViewController) {
        NSLog(@"%s Cannot dismiss ViewController because it has parentViewController: %@, parentViewController=%@", __PRETTY_FUNCTION__, self, self.viewController.parentViewController);
        return;
    }

    __block BOOL done = NO;
    [self.viewController.presentingViewController dismissViewControllerAnimated:NO completion:^{
        done = YES;
    }];
    
    [self waitFor:^{ return done; }];
}

- (BOOL)isPresented {
    return self.viewController.presentingViewController != nil;
}

#pragma mark - Utilities

- (void)ensureAllViewsDidAppear {
    [self ensureAllViewsDidAppear:self.defaultTimeout orRaiseError:NO];
}

- (void)ensureAllViewsDidAppear:(NSTimeInterval)timeout orRaiseError:(BOOL)raiseError {
    if ([self.class allViewControllersDidAppear]) {
        return;
    }
    
    BOOL satisfied = [self.class waitFor:^{ return [self.class allViewControllersDidAppear]; } timeout:timeout];
    
    if (!satisfied && raiseError) {
        [NSException raise:@"Timeout Exceeded" format:@"Waited for all views did appear for %f seconds", timeout];
    }
}

- (BOOL)waitFor:(BOOL (^)())test {
    return [self.class waitFor:test timeout:self.defaultTimeout];
}

- (BOOL)eventually:(BOOL (^)())test {
    return [self.class eventually:test timeout:self.defaultTimeout];
}

- (BOOL)eventuallyNotNil:(id (^)())test {
    return [self eventually:^BOOL{
        return test() != nil;
    }];
}

- (BOOL)globally:(BOOL (^)())test {
    return [self.class globally:test forSeconds:self.defaultTimeout];
}

- (BOOL)globallyNotNil:(id (^)())test {
    return [self globally:^BOOL{
        return test() != nil;
    }];
}

+ (BOOL)allViewControllersDidAppear {
    return OBHAppearingViewControllerCount == 0;
}

+ (void)runLoopForAWhile {
    [self runLoopForSeconds:runLoopTimeout];
}

+ (void)runLoopForSeconds:(NSTimeInterval)seconds {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
}

+ (BOOL)waitFor:(BOOL (^)())test timeout:(NSTimeInterval)timeout {
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    while ([[NSDate date] compare:end] == NSOrderedAscending) {
        [self.class runLoopForAWhile];
        
        if (test()) {
            return YES;
        }
    }
    
    return test();
}

+ (BOOL)eventually:(BOOL (^)())test timeout:(NSTimeInterval)timeout {
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow:timeout];
    
    while ([[NSDate date] compare:end] == NSOrderedAscending) {
        [self.class runLoopForAWhile];
        
        if (test()) {
            return YES;
        }
    }
    
    return test();
}

+ (BOOL)globally:(BOOL (^)())test forSeconds:(NSTimeInterval)seconds {
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow:seconds];
    
    while ([[NSDate date] compare:end] == NSOrderedAscending) {
        [self.class runLoopForAWhile];
        
        if (!test()) {
            return NO;
        }
    }
    
    return !test();
}

#pragma mark - Cache and factory

- (__kindof OBHViewControllerObject *)cachedObjectForViewController:(UIViewController *)viewController {
    if (self.parentObject) {
        return [self.parentObject cachedObjectForViewController:viewController];
    }
    
    for (OBHViewControllerObjectRef *ref in self.objectRefs) {
        if ([ref.viewController isEqual:viewController]) {
            return ref.object;
        }
    }
    
    return nil;
}

- (void)cacheObject:(OBHViewControllerObject *)object {
    if (self.parentObject) {
        [self.parentObject cacheObject:object];
    }
    
    OBHViewControllerObjectRef *ref = [OBHViewControllerObjectRef referenceWithObject:object];
    [self.objectRefs addObject:ref];
}

- (Class)objectClassForViewControllerClass:(Class)klass {
    Class objectClass = self.classRegistory[NSStringFromClass(klass)];
    
    if (objectClass) {
        return objectClass;
    } else {
        if (self.parentObject) {
            return [self.parentObject objectClassForViewControllerClass:klass];
        } else {
            if ([klass isSubclassOfClass:[UINavigationController class]]) {
                return [OBHNavigationControllerObject class];
            }
            
            if ([klass isSubclassOfClass:[UIAlertController class]]) {
                return [OBHAlertControllerObject class];
            }
            
            return [OBHViewControllerObject class];
        }
    }
}

- (__kindof OBHViewControllerObject *)childObjectWithViewController:(UIViewController *)viewController {
    OBHViewControllerObject *object = [self cachedObjectForViewController:viewController];
    if (object) {
        return object;
    }
    
    Class objectClass = [self objectClassForViewControllerClass:viewController.class];
    object = [[objectClass alloc] initWithViewController:viewController parentObject:self];
    
    [self cacheObject:object];
    
    return object;
}

@end
