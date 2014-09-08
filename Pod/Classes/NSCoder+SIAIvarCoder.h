//
//  NSCoder+SIAIvarCoder.h
//  IvarCoder
//
//  Created by KUROSAKI Ryota on 2013/01/11.
//  Copyright (c) 2013-2014 SI Agency Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCoder (SIAIvarCoder)

- (void)sia_encodeInstanceVariables:(id)object ofClass:(Class)objectClass;
- (void)sia_encodeInstanceVariables:(id)object ofClass:(Class)objectClass ignore:(const void *)firstIgnoreVariable, ...;
- (void)sia_decodeInstanceVariables:(id)object ofClass:(Class)objectClass;
- (void)sia_decodeInstanceVariables:(id)object ofClass:(Class)objectClass ignore:(const void *)firstIgnoreVariable, ...;

@end
