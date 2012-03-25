//
//  Created by jameslynch on 23/03/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <CouchCocoa/CouchCocoa.h>
#import "ASIHTTPRequest.h"


@interface ObjCradle : NSObject

@property(nonatomic, retain) CouchDatabase *database;

@property(nonatomic, retain) id requestDelegate;

@property(nonatomic, retain) CouchEmbeddedServer *server;

- (ObjCradle *)initWithDB:(NSString *)dbName;

- (ASIHTTPRequest *)get:(NSString *)path usingKey:(NSString *)key requestDelegate:(id)requestDelegate;

- (ASIHTTPRequest *)put:(NSString *)path withData:(NSDictionary *)data;

- (ASIHTTPRequest *)put:(NSString *)path withData:(NSDictionary *)data requestDelegate:(id)requestDelegate;

- (ASIHTTPRequest *)delete:(NSString *)path;

- (ASIHTTPRequest *)delete:(NSString *)path requestDelegate:(id)requestDelegate;

- (NSArray *)results:(ASIHTTPRequest *)request;

- (NSArray *)keyValuePairs:(ASIHTTPRequest *)request;


- (void)init:(CouchEmbeddedServer *)server;

- (ASIHTTPRequest *)get:(NSString *)string;

+ (ObjCradle *)default;


@end