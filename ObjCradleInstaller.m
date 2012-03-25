//
//  Created by jameslynch on 23/03/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CouchCocoa/CouchCocoa.h>
#import <Couchbase/CouchbaseMobile.h>
#import "ObjCradleInstaller.h"

// The default remote database URL to sync with, if the user hasn't set a different one as a pref.
//#define kDefaultSyncDbURL @"http://couchbase.iriscouch.com/grocery-sync"

// Define this to use a server at a specific URL, instead of the embedded Couchbase Mobile.
// This can be useful for debugging, since you can use the admin console (futon) to inspect
// or modify the database contents.
//#define USE_REMOTE_SERVER @"http://localhost:5984/"

@implementation ObjCradleInstaller {

}

- (CouchEmbeddedServer *) installCannedDb:(NSString *)dbName {
    // Start the Couchbase Mobile server:
    // gCouchLogLevel = 1;
    CouchEmbeddedServer* server;

    server = [[CouchEmbeddedServer alloc] init];

    NSString* dbPath = [[NSBundle mainBundle] pathForResource: dbName ofType: @"couch"];
    NSString *m = [NSString stringWithFormat:@"Couldn't find %@.couch", dbName];
    NSAssert(dbPath, m);
    [server.couchbase installDefaultDatabase: dbPath];
    return server;
}

@end