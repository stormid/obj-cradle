//
//  Created by jameslynch on 23/03/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "CouchCocoa/CouchEmbeddedServer.h"


@interface ObjCradleInstaller : NSObject
- (CouchEmbeddedServer *)installCannedDb:(NSString *)dbName;

@end