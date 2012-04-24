//
//  Created by jameslynch on 23/03/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CouchCocoa/CouchCocoa.h>
#import <Couchbase/CouchbaseMobile.h>
#import "ObjCradle.h"
#import "ASIHTTPRequest.h"
#import "ObjCradleInstaller.h"
#import "JSONKit.h"

ObjCradleInstaller *installer;

@implementation ObjCradle {
@private
    CouchDatabase *_database;
    id _requestDelegate;
    CouchEmbeddedServer *_server;
    NSString *_dbName;
}

@synthesize database = _database;
@synthesize requestDelegate = _requestDelegate;
@synthesize server = _server;
@synthesize dbName = _dbName;


static ObjCradle *objCradle = nil;

+(ObjCradle *) default
{
	if (objCradle == nil) {
		objCradle = [[ObjCradle alloc] init];
	}

	return objCradle;
}




- (ObjCradle *) initWithDB:(NSString *)dbName {
    if([super init]) {
        _dbName = dbName;
        installer = [[ObjCradleInstaller alloc] init];
        _server = [installer installCannedDb:dbName];
    }
    return self;
}

- (ASIHTTPRequest *)get:(NSString *)path {
    return [self get:path usingKey:nil requestDelegate:nil];
}

- (ASIHTTPRequest *)get:(NSString *)path usingKey:(NSString *)key requestDelegate:(id)requestDelegate {
    return [self sendRequest:path withData:nil withMethod:@"GET" usingKey:key requestDelegate:requestDelegate];
}

- (ASIHTTPRequest *)put:(NSString *)path withData:(NSDictionary *)data {
    return [self put:path withData:data requestDelegate:nil];
}

- (ASIHTTPRequest *)put:(NSString *)path withData:(NSDictionary *)data requestDelegate:(id)requestDelegate {
    return [self sendRequest:path withData:data withMethod:@"PUT" usingKey:nil requestDelegate:requestDelegate];
}

- (ASIHTTPRequest *)post:(NSString *)path withData:(NSDictionary *)data {
    return [self sendRequest:path withData:data withMethod:@"POST" usingKey:nil requestDelegate:nil];
}

- (ASIHTTPRequest *)post:(NSString *)path withData:(NSDictionary *)data requestDelegate:(id)requestDelegate {
    return [self sendRequest:path withData:data withMethod:@"POST" usingKey:nil requestDelegate:requestDelegate];
}

- (ASIHTTPRequest *)delete:(NSString *)path {
    return [self delete:path requestDelegate:nil];
}

- (ASIHTTPRequest *)delete:(NSString *)path requestDelegate:(id)requestDelegate {
    return [self sendRequest:path withData:nil withMethod:@"DELETE" usingKey:nil requestDelegate:requestDelegate];
}

- (void)sendReplicateRequest:(NSString *)source target:(NSString *)target continuous:(BOOL)continuous requestDelegate:(id)requestDelegate {
    NSMutableDictionary *data = [[[NSMutableDictionary alloc] init] autorelease];
    [data setValue:source forKey:@"source"];
    [data setValue:target forKey:@"target"];
    [data setObject:[NSNumber numberWithBool:continuous] forKey:@"continuous"];
    [self post:@"_replicate" withData:data requestDelegate:requestDelegate];
}

- (void)replicate:(NSString *)remoteDBUrl replicationType:(Replication)replicationType continous:(BOOL)continuous {
    [self replicate:remoteDBUrl replicationType:replicationType continous:continuous requestDelegate:nil];
}

- (void)replicate:(NSString *)remoteDBUrl replicationType:(Replication)replicationType continous:(BOOL)continuous requestDelegate:(id)reqDelegate {

    switch (replicationType) {
        case ServerToClient:
            [self sendReplicateRequest:remoteDBUrl target:_dbName continuous:continuous requestDelegate:reqDelegate];
            break;
        case ClientToServer:
            [self sendReplicateRequest:_dbName target:remoteDBUrl continuous:continuous requestDelegate:reqDelegate];
            break;
        case BiDirectional:
            [self sendReplicateRequest:_dbName target:remoteDBUrl continuous:continuous requestDelegate:reqDelegate];
            [self sendReplicateRequest:remoteDBUrl target:_dbName continuous:continuous requestDelegate:reqDelegate];
            break;
    }
}



- (ASIHTTPRequest *)sendRequest:(NSString *)path withData:(NSDictionary *)data withMethod:(NSString *)method usingKey:(NSString *)key requestDelegate:(id)requestDelegate {
    NSString *url= path == @"_replicate" ? [NSString stringWithFormat:@"%@%@", _server.URL, path] : [NSString stringWithFormat:@"%@/%@", _database.URL, path];
    if(key) {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"?key=\"%@\"", key]];
    }

    NSURL *encodedUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:encodedUrl] autorelease];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request setRequestMethod:method];
    [request addBasicAuthenticationHeaderWithUsername:_server.couchbase.adminCredential.user andPassword:_server.couchbase.adminCredential.password];
    if (data) {
        [request appendPostData:[data JSONData]];
    }
    if(requestDelegate) {
        request.delegate = _requestDelegate;
        [request startAsynchronous];
    }
    else {
        [request startSynchronous];
    }
    return request;
}

- (NSArray *) results:(ASIHTTPRequest *)request {
    NSArray *rows = [self selectRows:request];
    return [rows valueForKey:@"value"];
}

- (NSArray *) keyValuePairs:(ASIHTTPRequest *)request {
    return [self selectRows:request];
}

- (void)init:(CouchEmbeddedServer *)server {


}


- (NSArray *)selectRows:(ASIHTTPRequest *)request {
    NSMutableDictionary *data = [[request responseString] objectFromJSONString];
    NSArray *rows = [data objectForKey:@"rows"];
    return rows;
}

- (void)dealloc {
    [_requestDelegate release];
    [_server release];
    [_dbName release];
    [super dealloc];
}

@end