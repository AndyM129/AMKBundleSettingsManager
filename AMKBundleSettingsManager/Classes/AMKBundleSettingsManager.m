//
//  AMKBundleSettingsManager.m
//  AMKBundleSettingsManager
//
//  Created by Andy on 2017/12/6.
//  Copyright © 2017年 Andy Meng. All rights reserved.
//

#import "AMKBundleSettingsManager.h"
#import <objc/runtime.h>

static NSString *kRootPlistFileName = nil;
static NSString *kSettingsKeySuffix = nil;

@interface AMKBundleSettingsManager ()
@property (strong, nonatomic) NSMutableDictionary *mapping;
@end

@implementation AMKBundleSettingsManager

+ (instancetype)defaultManager {
    static id _defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[super allocWithZone:NULL] init] ;
    });
    return _defaultManager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSAssert(self.class.rootPlistFileName, @"须先初始化 'rootPlistFileName' ");
        NSAssert(self.class.settingsKeySuffix, @"须先初始化 'settingsKeySuffix' ");
        
        NSDictionary *defaults = [self.class defaultsFromPlistNamed:self.class.rootPlistFileName];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
        [self generateAccessorMethods];
    }
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self defaultManager];
}

- (id)copy {
    return [self.class defaultManager];
}

#pragma mark - Properties

+ (NSString *)rootPlistFileName {
    if (!kRootPlistFileName) {
        kRootPlistFileName = @"Root";
    }
    return kRootPlistFileName.copy;
}

+ (void)setRootPlistFileName:(NSString *)rootPlistFileName {
    NSAssert(rootPlistFileName, @"无效参数");
    NSAssert(!kRootPlistFileName, @"请勿重复赋值");
    kRootPlistFileName = rootPlistFileName.copy;
}

+ (NSString *)settingsKeySuffix {
    if (!kSettingsKeySuffix) {
        kSettingsKeySuffix = @"Preference";
    }
    return kSettingsKeySuffix.copy;
}

+ (void)setSettingsKeySuffix:(NSString *)settingsKeySuffix {
    NSAssert(settingsKeySuffix, @"无效参数");
    NSAssert(!kSettingsKeySuffix, @"请勿重复赋值");
    kSettingsKeySuffix = settingsKeySuffix.copy;
}

#pragma mark - GCC diagnostic pop

enum TypeEncodings {
    Char                = 'c',
    Bool                = 'B',
    Short               = 's',
    Int                 = 'i',
    Long                = 'l',
    LongLong            = 'q',
    UnsignedChar        = 'C',
    UnsignedShort       = 'S',
    UnsignedInt         = 'I',
    UnsignedLong        = 'L',
    UnsignedLongLong    = 'Q',
    Float               = 'f',
    Double              = 'd',
    Object              = '@'
};

- (NSString *)defaultsKeyForPropertyNamed:(NSString *)propertyName {
    return [self _defaultsKeyForPropertyNamed:propertyName.UTF8String];
}

- (NSString *)defaultsKeyForSelector:(SEL)selector {
    return [self.mapping objectForKey:NSStringFromSelector(selector)];
}

static long long longLongGetter(AMKBundleSettingsManager *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [[NSUserDefaults.standardUserDefaults objectForKey:key] longLongValue];
}

static void longLongSetter(AMKBundleSettingsManager *self, SEL _cmd, long long value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    NSNumber *object = [NSNumber numberWithLongLong:value];
    [NSUserDefaults.standardUserDefaults setObject:object forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

static bool boolGetter(AMKBundleSettingsManager *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [NSUserDefaults.standardUserDefaults boolForKey:key];
}

static void boolSetter(AMKBundleSettingsManager *self, SEL _cmd, bool value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    [NSUserDefaults.standardUserDefaults setBool:value forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

static int integerGetter(AMKBundleSettingsManager *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return (int)[NSUserDefaults.standardUserDefaults integerForKey:key];
}

static void integerSetter(AMKBundleSettingsManager *self, SEL _cmd, int value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    [NSUserDefaults.standardUserDefaults setInteger:value forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

static float floatGetter(AMKBundleSettingsManager *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [NSUserDefaults.standardUserDefaults floatForKey:key];
}

static void floatSetter(AMKBundleSettingsManager *self, SEL _cmd, float value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    [NSUserDefaults.standardUserDefaults setFloat:value forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

static double doubleGetter(AMKBundleSettingsManager *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [NSUserDefaults.standardUserDefaults doubleForKey:key];
}

static void doubleSetter(AMKBundleSettingsManager *self, SEL _cmd, double value) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    [NSUserDefaults.standardUserDefaults setDouble:value forKey:key];
    [NSUserDefaults.standardUserDefaults synchronize];
}

static id objectGetter(AMKBundleSettingsManager *self, SEL _cmd) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    return [NSUserDefaults.standardUserDefaults objectForKey:key];
}

static void objectSetter(AMKBundleSettingsManager *self, SEL _cmd, id object) {
    NSString *key = [self defaultsKeyForSelector:_cmd];
    if (object) {
        [NSUserDefaults.standardUserDefaults setObject:object forKey:key];
    } else {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:key];
    }
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)generateAccessorMethods {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    self.mapping = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < count; ++i) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        const char *attributes = property_getAttributes(property);
        
        char *getter = strstr(attributes, ",G");
        if (getter) {
            getter = strdup(getter + 2);
            getter = strsep(&getter, ",");
        } else {
            getter = strdup(name);
        }
        SEL getterSel = sel_registerName(getter);
        free(getter);
        
        char *setter = strstr(attributes, ",S");
        if (setter) {
            setter = strdup(setter + 2);
            setter = strsep(&setter, ",");
        } else {
            asprintf(&setter, "set%c%s:", toupper(name[0]), name + 1);
        }
        SEL setterSel = sel_registerName(setter);
        free(setter);
        
        NSString *key = [self _defaultsKeyForPropertyNamed:name];
        [self.mapping setValue:key forKey:NSStringFromSelector(getterSel)];
        [self.mapping setValue:key forKey:NSStringFromSelector(setterSel)];
        
        IMP getterImp = NULL;
        IMP setterImp = NULL;
        char type = attributes[1];
        switch (type) {
            case Short:
            case Long:
            case LongLong:
            case UnsignedChar:
            case UnsignedShort:
            case UnsignedInt:
            case UnsignedLong:
            case UnsignedLongLong:
                getterImp = (IMP)longLongGetter;
                setterImp = (IMP)longLongSetter;
                break;
                
            case Bool:
            case Char:
                getterImp = (IMP)boolGetter;
                setterImp = (IMP)boolSetter;
                break;
                
            case Int:
                getterImp = (IMP)integerGetter;
                setterImp = (IMP)integerSetter;
                break;
                
            case Float:
                getterImp = (IMP)floatGetter;
                setterImp = (IMP)floatSetter;
                break;
                
            case Double:
                getterImp = (IMP)doubleGetter;
                setterImp = (IMP)doubleSetter;
                break;
                
            case Object:
                getterImp = (IMP)objectGetter;
                setterImp = (IMP)objectSetter;
                break;
                
            default:
                free(properties);
                [NSException raise:NSInternalInconsistencyException format:@"Unsupported type of property \"%s\" in class %@", name, self];
                break;
        }
        
        char types[5];
        
        snprintf(types, 4, "%c@:", type);
        class_addMethod([self class], getterSel, getterImp, types);
        
        snprintf(types, 5, "v@:%c", type);
        class_addMethod([self class], setterSel, setterImp, types);
    }
    
    free(properties);
}

#pragma mark - Helper Methods

- (NSString *)_defaultsKeyForPropertyNamed:(char const *)propertyName {
    NSString *key = nil;
    
    if (strlen(propertyName) > 1) {
        key = [NSString stringWithFormat:@"%c%s%@", toupper(propertyName[0]), propertyName+1, self.class.settingsKeySuffix];
    } else if (strlen(propertyName) == 1) {
        key = [NSString stringWithFormat:@"%c%@", toupper(propertyName[0]), self.class.settingsKeySuffix];
    }
    return key;
}

+ (NSDictionary *)defaultsFromPlistNamed:(NSString *)plistName {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    NSAssert(settingsBundle, @"Could not find Settings.bundle while loading defaults.");
    
    NSString *plistFullName = [NSString stringWithFormat:@"%@.plist", plistName];
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:plistFullName]];
    NSAssert1(settings, @"Could not load plist '%@' while loading defaults.", plistFullName);
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSAssert1(preferences, @"Could not find preferences entry in plist '%@' while loading defaults.", plistFullName);
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        id value = [prefSpecification objectForKey:@"DefaultValue"];
        if(key && value && ![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
            [defaults setObject:value forKey:key];
        }
        
        NSString *type = [prefSpecification objectForKey:@"Type"];
        if ([type isEqualToString:@"PSChildPaneSpecifier"]) {
            NSString *file = [prefSpecification objectForKey:@"File"];
            NSAssert1(file, @"Unable to get child plist name from plist '%@'", plistFullName);
            [defaults addEntriesFromDictionary:[self defaultsFromPlistNamed:file]];
        }
    }
    return defaults;
}

@end



@implementation AMKBundleSettingsManager (UpdateWithKeyValues)

- (BOOL)updateWithKeyValuesJSONString:(NSString *)string {
    if (string && string.length) {
        NSError *error = nil;
        NSData *keyValuesData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *keyValuesDict = [NSJSONSerialization JSONObjectWithData:keyValuesData options:kNilOptions error:&error];
        return [self updateWithKeyValues:keyValuesDict];
    }
    return NO;
}

- (BOOL)updateWithKeyValues:(NSDictionary *)keyValues {
    if (keyValues && [keyValues isKindOfClass:NSDictionary.class] && keyValues.count) {
        for (NSString *key in keyValues) {
            id value = [keyValues objectForKey:key];
            NSString *getterName = key;
            NSString *setterName = [NSString stringWithFormat:@"set%c%s:", toupper(key.UTF8String[0]), key.UTF8String+1];
            SEL getter = NSSelectorFromString(getterName);
            SEL setter = NSSelectorFromString(setterName);
            if ([self respondsToSelector:setter]
                && [self respondsToSelector:getter]
                && ([value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class])) {
                NSString *userDefaultsKey = [self defaultsKeyForPropertyNamed:key];
                [[NSUserDefaults standardUserDefaults] setObject:value forKey:userDefaultsKey];
            }
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

@end


