/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.
*/
#include <dlfcn.h>


@interface MyDKFLEXLoader : NSObject

@end

@implementation MyDKFLEXLoader

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MyDKFLEXLoader *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)show
{
	// [[FLEXManager sharedManager] showExplorer];

	Class FLEXManager = NSClassFromString(@"FLEXManager");
	id sharedManager = [FLEXManager performSelector:@selector(sharedManager)];
	[sharedManager performSelector:@selector(showExplorer)];
}

@end



%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.yourcompany.flexinjected.plist"] ;
        NSString *libraryPath = @"/Library/Application Support/FLEXLoader/FLEX.framework/FLEX";
        
        NSString *keyPath = [NSString stringWithFormat:@"FLEXInjectedEnabled-%@", [[NSBundle mainBundle] bundleIdentifier]];
        NSLog(@"SSFLEXLoader before loaded %@,keyPath = %@,prefs = %@", libraryPath,keyPath,prefs);
        if ([[prefs objectForKey:keyPath] boolValue]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath]){
                void *haldel = dlopen([libraryPath UTF8String], RTLD_NOW);
            if (haldel == NULL) {
                char *error = dlerror();
                NSLog(@"dlopen error: %s", error);
            } else {
                NSLog(@"dlopen load framework success.");
                [[NSNotificationCenter defaultCenter] addObserver:[MyDKFLEXLoader sharedInstance] 
											selector:@selector(show) 
											name:UIApplicationDidBecomeActiveNotification 
											object:nil];
                    
                
            }

            NSLog(@"SSFLEXLoader loaded %@", libraryPath);
            } else {
                NSLog(@"SSFLEXLoader file not exists %@", libraryPath);
            }
        }
        else {
            NSLog(@"SSFLEXLoader not enabled %@", libraryPath);
        }
        
        NSLog(@"SSFLEXLoader after loaded %@", libraryPath);


    [pool drain];
}



