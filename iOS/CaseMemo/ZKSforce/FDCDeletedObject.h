

#import <Foundation/Foundation.h>

@interface FDCDeletedObject : NSObject {
    NSString *Id;
    NSDate *deletedDate;
}

@property (readonly) NSString *Id;
@property (readonly) NSDate *deletedDate;

- (FDCDeletedObject *)initWithId:(NSString *)objectId deletedDate:(NSDate *)date;

@end
