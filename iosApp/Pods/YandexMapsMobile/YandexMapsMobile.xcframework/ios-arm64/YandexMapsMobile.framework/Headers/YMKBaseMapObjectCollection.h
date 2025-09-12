#import <YandexMapsMobile/YMKMapObject.h>
#import <YandexMapsMobile/YMKMapObjectCollectionListener.h>
#import <YandexMapsMobile/YMKMapObjectVisitor.h>
#import <YandexMapsMobile/YRTExport.h>

/**
 * Undocumented
 */
YRT_EXPORT @interface YMKBaseMapObjectCollection : YMKMapObject

/**
 * Traverses through the collection with a visitor object. Used for
 * iteration over map objects in the collection.
 */
- (void)traverseWithMapObjectVisitor:(nonnull id<YMKMapObjectVisitor>)mapObjectVisitor;

/**
 * Removes the given map object from the collection.
 */
- (void)removeWithMapObject:(nonnull YMKMapObject *)mapObject;

/**
 * Removes all map objects from the collection.
 */
- (void)clear;

/**
 * Adds a listener to track notifications of changes to the collection.
 */
- (void)addListenerWithCollectionListener:(nonnull id<YMKMapObjectCollectionListener>)collectionListener;

/**
 * Removes a listener.
 */
- (void)removeListenerWithCollectionListener:(nonnull id<YMKMapObjectCollectionListener>)collectionListener;

@end
