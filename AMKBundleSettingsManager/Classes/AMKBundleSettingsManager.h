//
//  AMKBundleSettingsManager.h
//  AMKBundleSettingsManager
//
//  Created by Andy on 2017/12/6.
//  Copyright © 2017年 Andy Meng. All rights reserved.
//

#import <Foundation/Foundation.h>

/** BundleSettings管理 */
@interface AMKBundleSettingsManager : NSObject
@property(nonatomic, copy, nullable, class) NSString *rootPlistFileName;                //!< 根文件名称，默认Root
@property(nonatomic, copy, nullable, class) NSString *settingsKeySuffix;                //!< 设置项唯一标示前缀，默认

+ (nullable instancetype)defaultManager;                                                //!< 默认Manager
- (NSString * _Nullable)defaultsKeyForPropertyNamed:(NSString * _Nullable)propertyName; //!< 属性的UserDefaultsKey
@end



/** BundleSettings管理 - 键值对更新 */
@interface AMKBundleSettingsManager (UpdateWithKeyValues)
- (BOOL)updateWithKeyValuesJSONString:(NSString * _Nullable)string;
- (BOOL)updateWithKeyValues:(NSDictionary * _Nullable)keyValues;
@end


