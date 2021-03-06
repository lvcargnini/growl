//
//  NSObject+DRYDescription.m
//  growltunes
//
//  Created by Travis Tilley on 11/4/11.
//

#import "NSObject+DRYDescription.h"
#import <objc/runtime.h>

@implementation NSObject (DRYDescription)

- (NSArray*)sortedPropertyNames
{    
    unsigned int outCount, i;
    
    objc_property_t* properties = class_copyPropertyList([self class], &outCount);
    NSMutableArray* props = [[[NSMutableArray alloc] initWithCapacity:outCount] autorelease];
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char* nameCStr = property_getName(property);
        NSString* name = [NSString stringWithCString:nameCStr 
                                            encoding:[NSString defaultCStringEncoding]];
        [props addObject:name];
    }
    
    free(properties);

    // clang assumes that the selector is for self, not props
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wselector"
    return [props sortedArrayUsingSelector:@selector(compare:)];
    #pragma clang diagnostic pop
}

- (NSArray*)sortedInstanceVariableNames
{
    unsigned int outCount, i;
    
    Ivar* list = class_copyIvarList([self class], &outCount);
    NSMutableArray* ivars = [[[NSMutableArray alloc] initWithCapacity:outCount] autorelease];
    
    for (i = 0; i < outCount; i++) {
        Ivar ivar = list[i];
        const char* nameCStr = ivar_getName(ivar);
        NSString* name = [NSString stringWithCString:nameCStr 
                                            encoding:[NSString defaultCStringEncoding]];
        [ivars addObject:name];
    }
    
    free(list);
    
    // clang assumes that the selector is for self, not props
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wselector"
    return [ivars sortedArrayUsingSelector:@selector(compare:)];
    #pragma clang diagnostic pop
}

- (NSString*)dryDescriptionForProperties
{
    return [NSString stringWithFormat:@"<%@ %p: %@>", 
            [self class], self, 
            [self dictionaryWithValuesForKeys:[self sortedPropertyNames]]];
}

- (NSString*)dryDescriptionForIVars
{
    return [NSString stringWithFormat:@"<%@ %p: %@>", 
            [self class], self, 
            [self dictionaryWithValuesForKeys:[self sortedInstanceVariableNames]]];
}

@end
