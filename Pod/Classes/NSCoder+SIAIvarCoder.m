//
//  NSCoder+SIAIvarCoder.m
//  IvarCoder
//
//  Created by KUROSAKI Ryota on 2013/01/11.
//  Copyright (c) 2013-2014 SI Agency Inc. All rights reserved.
//

#import "NSCoder+SIAIvarCoder.h"

#import <objc/runtime.h>

void SIAIvarCoderEnumerateVariables(id object, Class objectClass, void (^block)(NSString *name, NSString *typeEncoding, void *address))
{
    if (block == nil) {
        return;
    }
    
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(objectClass, &outCount);
    
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        ptrdiff_t offset = ivar_getOffset(ivar);
        void *p = (UInt8 *)(__bridge void *)object + offset;
        
        block(@(name), @(type), p);
    }
    
    if (outCount > 0) { free(ivars); }
}

@implementation NSCoder (SIAIvarCoder)

- (void)sia_encodeInstanceVariables:(id)object ofClass:(Class)objectClass
{
    [self sia_encodeInstanceVariables:object ofClass:objectClass ignore:NULL];
}

- (void)sia_encodeInstanceVariables:(id)object ofClass:(Class)objectClass ignore:(const void *)firstIgnoreVariable, ...
{
    NSMutableArray *ignoreList = @[].mutableCopy;
    if (firstIgnoreVariable) {
        [ignoreList addObject:[NSValue valueWithPointer:firstIgnoreVariable]];
        
        va_list argumentList;
        va_start(argumentList, firstIgnoreVariable);
        void *vp = NULL;
        while ((vp = va_arg(argumentList, void *)) != nil) {
            [ignoreList addObject:[NSValue valueWithPointer:vp]];
        }
        va_end(argumentList);
    }

    SIAIvarCoderEnumerateVariables(object, objectClass, ^(NSString *name, NSString *typeEncoding, void *address) {
        if ([ignoreList containsObject:[NSValue valueWithPointer:address]]) {
            return;
        }
        
        
        switch (*typeEncoding.UTF8String) {
            case '@':
                [self encodeObject:*(__unsafe_unretained id *)address forKey:name];
                break;
            case '#':
                [self encodeObject:NSStringFromClass(*(Class *)address) forKey:name];
                break;
            case ':':
                [self encodeObject:NSStringFromSelector(*(SEL *)address) forKey:name];
                break;
            case 'c':
                [self encodeObject:@(*(BOOL *)address) forKey:name];
                break;
            case 'C':
                [self encodeObject:@(*(unsigned char *)address) forKey:name];
                break;
            case 'i':
                [self encodeObject:@(*(int *)address) forKey:name];
                break;
            case 'I':
                [self encodeObject:@(*(unsigned int *)address) forKey:name];
                break;
            case 's':
                [self encodeObject:@(*(short *)address) forKey:name];
                break;
            case 'S':
                [self encodeObject:@(*(unsigned short *)address) forKey:name];
                break;
            case 'l':
                [self encodeObject:@(*(long *)address) forKey:name];
                break;
            case 'L':
                [self encodeObject:@(*(unsigned long *)address) forKey:name];
                break;
            case 'q':
                [self encodeObject:@(*(long long *)address) forKey:name];
                break;
            case 'Q':
                [self encodeObject:@(*(unsigned long long *)address) forKey:name];
                break;
            case 'f':
                [self encodeObject:@(*(float *)address) forKey:name];
                break;
            case 'd':
                [self encodeObject:@(*(double *)address) forKey:name];
                break;
            case 'B':
                [self encodeObject:@(*(bool *)address) forKey:name];
                break;
            case '*':
                if (*(char **)address != NULL) {
                    [self encodeBytes:(const uint8_t *)*(char **)address length:strlen(*(char **)address) forKey:name];
                }
                break;
            case '^':
                // nothing to do for pointer
                break;
            case '{': {
                NSString *structName = [typeEncoding substringWithRange:NSMakeRange(1, [typeEncoding rangeOfString:@"="].location - 1)];
                NSValue *value = nil;
                if ([structName isEqualToString:@"CGPoint"]) {
                    value = [NSValue valueWithCGPoint:*(CGPoint *)address];
                }
                else if ([structName isEqualToString:@"CGRect"]) {
                    value = [NSValue valueWithCGRect:*(CGRect *)address];
                }
                else if ([structName isEqualToString:@"CGSize"]) {
                    value = [NSValue valueWithCGSize:*(CGSize *)address];
                }
                if (value) {
                    [self encodeObject:value forKey:name];
                }
                break;
            }
            default:
                break;
        }
    });
}

- (void)sia_decodeInstanceVariables:(id)object ofClass:(Class)objectClass
{
    [self sia_decodeInstanceVariables:object ofClass:objectClass ignore:NULL];
}

- (void)sia_decodeInstanceVariables:(id)object ofClass:(Class)objectClass ignore:(const void *)firstIgnoreVariable, ...
{
    NSMutableArray *ignoreList = @[].mutableCopy;
    if (firstIgnoreVariable) {
        [ignoreList addObject:[NSValue valueWithPointer:firstIgnoreVariable]];

        va_list argumentList;
        va_start(argumentList, firstIgnoreVariable);
        void *vp = NULL;
        while ((vp = va_arg(argumentList, void *)) != nil) {
            [ignoreList addObject:[NSValue valueWithPointer:vp]];
        }
        va_end(argumentList);
    }

    SIAIvarCoderEnumerateVariables(object, objectClass, ^(NSString *name, NSString *typeEncoding, void *address) {
        if ([ignoreList containsObject:[NSValue valueWithPointer:address]]) {
            return;
        }
        
        switch (*typeEncoding.UTF8String) {
            case '@': {
                Ivar ivar = class_getInstanceVariable([object class], name.UTF8String);
                object_setIvar(object, ivar, [self decodeObjectForKey:name]);
                break;
            }
            case '#': {
                Ivar ivar = class_getInstanceVariable([object class], name.UTF8String);
                NSString *className = [self decodeObjectForKey:name];
                if (className) {
                    object_setIvar(object, ivar, NSClassFromString(className));
                }
                break;
            }
            case ':': {
                NSString *selName = [self decodeObjectForKey:name];
                if (selName) {
                    *(SEL *)address = NSSelectorFromString(selName);
                }
                break;
            }
            case 'c':
                *(BOOL *)address = [[self decodeObjectForKey:name] boolValue];
                break;
            case 'C':
                *(unsigned char *)address = [[self decodeObjectForKey:name] unsignedCharValue];
                break;
            case 'i':
                *(int *)address = [[self decodeObjectForKey:name] intValue];
                break;
            case 'I':
                *(unsigned int *)address = [[self decodeObjectForKey:name] unsignedIntValue];
                break;
            case 's':
                *(short *)address = [[self decodeObjectForKey:name] shortValue];
                break;
            case 'S':
                *(unsigned short *)address = [[self decodeObjectForKey:name] unsignedShortValue];
                break;
            case 'l':
                *(long *)address = [[self decodeObjectForKey:name] longValue];
                break;
            case 'L':
                *(unsigned long *)address = [[self decodeObjectForKey:name] unsignedLongValue];
                break;
            case 'q':
                *(long long *)address = [[self decodeObjectForKey:name] longLongValue];
                break;
            case 'Q':
                *(unsigned long long *)address = [[self decodeObjectForKey:name] unsignedLongLongValue];
                break;
            case 'f':
                *(float *)address = [[self decodeObjectForKey:name] floatValue];
                break;
            case 'd':
                *(double *)address = [[self decodeObjectForKey:name] doubleValue];
                break;
            case 'B':
                *(bool *)address = [[self decodeObjectForKey:name] boolValue];
                break;
            case '*': {
                NSUInteger len = 0;
                const uint8_t *bytes = [self decodeBytesForKey:name returnedLength:&len];
                if (len > 0) {
                    *(char **)address = malloc(len + 1);
                    memcpy(*(char **)address, bytes, len);
                    (*(char **)address)[len] = '\0';
                }
                break;
            }
            case '^':
                // nothing to do for pointer
                break;
            case '{': {
                NSString *structName = [typeEncoding substringWithRange:NSMakeRange(1, [typeEncoding rangeOfString:@"="].location - 1)];
                if ([structName isEqualToString:@"CGPoint"]) {
                    NSValue *value = [self decodeObjectForKey:name];
                    *(CGPoint *)address = [value CGPointValue];
                }
                else if ([structName isEqualToString:@"CGRect"]) {
                    NSValue *value = [self decodeObjectForKey:name];
                    *(CGRect *)address = [value CGRectValue];
                }
                else if ([structName isEqualToString:@"CGSize"]) {
                    NSValue *value = [self decodeObjectForKey:name];
                    *(CGSize *)address = [value CGSizeValue];
                }
                break;
            }
            default:
                break;
        }
    });
}

@end
