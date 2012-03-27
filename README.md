ObjCradle
=========
A thin Objective C wrapper around CouchDB's REST api

Introduction
------------
Inspired by the node.js [cradle](http://cloudhead.io/cradle) and [DotCradle](http://github.com/roryf/DotCradle) librares.

Dependancies
------------
- [Couchbase Mobile](https://github.com/couchbaselabs/iOS-Couchbase-manifest)
- [CouchCocoa](https://github.com/couchbaselabs/CouchCocoa)
- [ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest)
- [JSONKit](https://github.com/johnezang/JSONKit)

Road Map
--------
- Configuration to use a Remote Server
- Configuration to install a blank db on first run

API Documentation
-----------------
#####Installing an embedded database from `mydatabase.couch` file resource

``` objectivec
	
ObjCradle *couch = [[ObjCradle default] initWithDB:@"mydatabase"];
[couch.server start: ^{  // ... this block runs later on when the server has started up:
    if (couch.server.error) {
        NSLog(@"Error staring CouchEmbeddedServer: %@", couch.server.error.domain);
        return;
    }
    couch.database = [couch.server databaseNamed:dbName];
    NSLog(@"CouchDB installed with ObjCradle on %@", couch.server.URL);
    ...
}];
```

#####Retrieving all documents

``` objectivec
	
ASIHTTPRequest *request= [[ObjCradle default] get:@"_all_docs"];
NSLog(@"Results: %@", request.responseString);
```

#####Retrieving documents from a view using a key

``` objectivec

ASIHTTPRequest *request = [[ObjCradle default] get:@"_design/category/_view/byParent" usingKey:[NSString stringWithFormat:@"%d", parent]];
NSLog(@"Results: %@", request.responseString);
```

#####Selecting results as a custom class
The `results` method returns a `NSArray` of `NSDictionary` instances. These can be exposed as a custom type:

######Item.h

``` objectivec

@interface Item : NSObject {
        NSString *__id;
        NSString *__rev;
        NSString *_title;
        NSString *_summary;
        NSString *_body;
        NSString *_type;
        NSString *_category_id;
}

@property (nonatomic, retain) NSString *_id;
@property (nonatomic, retain) NSString *_rev;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *category_id;

- (id)initWithProperties:(NSDictionary *)properties;


@end
```

######Item.m

``` objectivec

#import "Item.h"

@implementation Item

@synthesize _id = __id, title = _title, summary = _summary, body = _body, _rev = __rev, type = _type, category_id = _category_id;

- (id)initWithProperties:(NSDictionary *)properties {
  [self setValuesForKeysWithDictionary:properties];
   return self;
}

@end
```

``` objectivec

-(void) setItemId:(NSString *)itemId{
    ASIHTTPRequest *itemRequest = [[ObjCradle default] get:@"_design/item/_view/all" usingKey:[NSString stringWithFormat:@"%@", itemId]];
    NSDictionary *result = [[[ObjCradle default] results:itemRequest] objectAtIndex:0];
    _item = [[Item alloc] initWithProperties:result];
}
```

#####Using the [ASIHTTPRequestDelegate](http://allseeing-i.com/ASIHTTPRequest/):

######ItemsController.h

``` objectivec

#import "ASIHTTPRequestDelegate.h"

@interface ItemsController: NSObject <ASIHTTPRequestDelegate>

@end
```

######ItemsController.m

``` objectivec

#import "ItemsController.h"
#import "ASIHTTPRequest.h"

@implementation ItemsController {
}

-(void)createModel {
    ASIHTTPRequest *itemRequest = [[ObjCradle default] get:@"_design/item/_view/all" usingKey:[NSString stringWithFormat:@"%@", itemId] requestDelegate:self];   
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (request.responseStatusCode == 200 || request.responseStatusCode == 201) {
        NSDictionary *result = [[[ObjCradle default] results:itemRequest] objectAtIndex:0];
        _item = [[Item alloc] initWithProperties:result];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Request failed: %@", request.error)
}
```

#####Replication
Three replication types are supported `ServerToClient`, `ClientToServer` and `BiDirectional`. Continuous replication can be used.


``` objectivec
[[ObjCradle default] replicate:@"http://me.iriscouch.com/mydatabase" replicationType:ServerToClient continous:YES];
```

