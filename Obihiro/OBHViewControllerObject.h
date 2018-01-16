#import <UIKit/UIKit.h>

@class OBHUIPredicate;
@class OBHNavigationControllerObject;
@class OBHAlertControllerObject;

NS_ASSUME_NONNULL_BEGIN

@interface OBHViewControllerObject<ViewController: UIViewController *> : NSObject

@property (nonatomic, readonly) ViewController viewController;

/**
 Returns new ViewController Object with given ViewController.
 */
+ (instancetype)objectWithViewController:(ViewController)viewController;

/**
 */
+ (instancetype)objectWithInitialViewControllerFromStoryBoardWithName:(NSString *)name;

/**
 Returns new ViewController Object with a ViewController loaded from StoryBoard.
 */
+ (instancetype)objectWithIdentifier:(NSString *)identifier fromStoryBoardWithName:(NSString *)name;

/**
 Initialize the object with given ViewController.
 */
- (instancetype)initWithViewController:(ViewController)viewController;

/**
 Initialize the object.
 Invoked during `init` methods.
 
 You should use this object instead of overriding `init` methods.
 */
- (void)initializeObject;

/**
 Make `objectClass` be instantiated for ViewController instances of `viewControllerClass`.
 */
- (void)registerObjectClass:(Class)objectClass forViewControllerClass:(Class)viewControllerClass;

/**
 Shortcut for `registerObjectClass:forViewControllerClass:`.
 It takes class of View Controller Object, and guess the class of ViewController based on its name.
 
 * Assumes the name of Object class has suffix of `Object`
 * Assumes the name of ViewController class can be obtained by dropping `Object` suffix
 */
- (void)registerObjectClass:(Class)objectClass;

#pragma mark - ViewController Containment

/**
 Returns objects associated with immediate child view controllers of given class.
 */
- (NSArray<__kindof OBHViewControllerObject *> *)childObjectsOfViewControllerClass:(Class)klass;

/**
 Returns first object from `childObjectsOfViewControllerClass:`.
 */
- (nullable __kindof OBHViewControllerObject *)firstChildObjectOfViewControllerClass:(Class)klass;

/**
 Returns ViewController Object associated with given `viewController`.
 
 * Referes cache so that if you call twice with same View Controller instance, returns same object
 * Intances View Controller Objects based on registory
 */
- (__kindof OBHViewControllerObject *)objectWithViewController:(UIViewController *)viewController;

#pragma mark -

/**
 Returns object for View Controller of given class presented by the View Controller associated to this object.
 */
- (nullable __kindof OBHViewControllerObject *)presentedObjectOfViewControllerClass:(Class)klass;

/**
 Returns object for View Controller presented by as Popover by the View Controller associated to this object.
 */
- (nullable __kindof OBHViewControllerObject *)presentedPopoverObject;

/**
 Returns object for UIAlertController presented by as Popover by the View Controller associated to this object.
 */
- (nullable OBHAlertControllerObject *)alertObject;

@property (nonatomic, readonly) BOOL hasAlert __deprecated;
@property (nonatomic, readonly) BOOL hasNoAlert __deprecated;

/**
 Returns predicate to test the View Controller presents alert or not.
 */
@property (nonatomic, readonly) OBHUIPredicate *alertPresented;

#pragma mark - Views

/**
 View associated with `viewController`.
 */
@property (nonatomic, readonly) __kindof UIView *view;

/**
 Returns array of descendant views which is an instance of subclass of `klass`.
 */
- (NSArray<__kindof UIView *> *)descendantViewsOfClass:(Class)klass;

/**
 Returns an instance of subclass of `klass`.
 */
- (nullable __kindof UIView *)firstDescendantViewOfClass:(__unsafe_unretained Class)klass;

#pragma mark - User Action

/**
 Run given block and then wait for a while.
 The wait inserted after block execution lets run Main Thread to do something associated action.
 */
- (void)simulateUserAction:(void(^)(void))action;

#pragma mark - Present/Dismiss

/**
 Present the ViewController under UIWindow.rootViewController.
 Returns after `viewDidAppear` call.
 
 If viewController's modalPresentationStyle is UIModalPresentationPopover, the method will configure popoverPresentationController of viewController.
 The popover presentation location will be left-top of the window.
 */
- (void)presentViewController;

/**
 Dismiss the ViewController.
 Returns after `viewDidDisappear` call.
 */
- (void)dismissViewController;

/**
 Returns `YES` if the ViewController is already presented.
 */
@property (nonatomic, readonly) BOOL isPresented;

#pragma mark - Predicates

- (OBHUIPredicate *)predicateWithTest:(BOOL(^)(void))test;

#pragma mark - Utilities

/**
 Blocks until `+ allViewControllersDidAppear` returns true, or timed out.
 */
- (void)ensureAllViewsDidAppear;

/**
 Blocks until `+ allViewControllersDidAppear` returns true.
 If timed out, raises an error if `raiseError` is true.
 */
- (void)ensureAllViewsDidAppear:(NSTimeInterval)timeout orRaiseError:(BOOL)raiseError __deprecated_msg("Use +[OBHViewControllerObject ensureAllViewsDidAppear:orRaiseError] instead");

/**
 Default timeout for `-[OBHViewControllerObject waitFor:timeout:]`.
 Should be greater than zero.
 */
@property (nonatomic) NSTimeInterval defaultTimeout;

/**
 Blocks until `test` returns true.
 Time out by `defaultTimeout`.
 */
- (BOOL)waitFor:(BOOL(^)(void))test;

- (BOOL)eventually:(BOOL(^)(void))test;
- (BOOL)eventuallyNot:(BOOL(^)(void))test;

- (BOOL)eventuallyNil:(id(^)(void))test;
- (BOOL)eventuallyNotNil:(id(^)(void))test;

- (BOOL)globally:(BOOL(^)(void))test;
- (BOOL)globallyNotNil:(id(^)(void))test;

/**
 Blocks until `test` returns true.
 
 Returns true when `test` is finally satisfied.
 Returns false when timed out.
 */
+ (BOOL)waitFor:(BOOL (^)(void))test timeout:(NSTimeInterval)timeout;

+ (BOOL)eventually:(BOOL(^)(void))test timeout:(NSTimeInterval)timeout;
+ (BOOL)globally:(BOOL(^)(void))test forSeconds:(NSTimeInterval)seconds;

/**
 Returns true if there is no ViewController appearing/disappearing.
 Returns false one or more ViewController which has been `viewWillAppear:` and not yet `viewDidAppear`.
 Returns false one or more ViewController which has been `viewWillDisappear:` and not yet `viewDidDisappear`.
 */
+ (BOOL)allViewControllersDidAppear;

/**
 Blocks for a while.
 */
+ (void)runLoopForAWhile;

/**
 Blocks for `seconds`.
 */
+ (void)runLoopForSeconds:(NSTimeInterval)seconds;

/**
 Blocks until `+ allViewControllersDidAppear` returns true.
 If timed out, raises an error if `raiseError` is true.
 */
+ (void)ensureAllViewsDidAppear:(NSTimeInterval)timeout orRaiseError:(BOOL)raiseError;

@end

NS_ASSUME_NONNULL_END
