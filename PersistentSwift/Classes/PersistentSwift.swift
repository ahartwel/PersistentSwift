//
//  PersistantSwift.swift
//  PersistentSwift
//
//  Created by Alex Hartwell on 1/28/17.
//  Copyright © 2017 hartwell. All rights reserved.
//

import Foundation
import Foundation





open class PSModelCache {
    
    public static var shared: PSModelCache = PSModelCache();
    public var models: [PSCachedModel.Type] = [];
    public var cache: [String: [PSCachedModel]] = [:];
    
    
    /// get models of type from the cache
    ///
    /// - Parameter ofType: the type of object to get ex. SubclassCachedModel.self
    /// - Returns: the array of models if they exist, otherwise nil
    public func getModelsFromCache<T: PSCachedModel>(ofType: PSCachedModel.Type) -> [T]? {
        return self.cache[ofType.modelName] as? [T]
    }
    
    
    
    /// Register model types to the cache
    ///
    /// - Parameter models: the types to add to the cache, looks like [PSCachedModel.self, SubclassCachedModel.self]
    public func registerModels(models: [PSCachedModel.Type]) {
        for model in models {
            self.models.append(model);
        }
    }
    
    
    /// add a model to the cache. It will find the proper cache based on the models type, append it and save the cache
    ///
    /// - Parameter model: the model to save
    public func addModelToCache(model: PSCachedModel) {
        let type: PSCachedModel.Type = type(of: model);
        
        var inside: Bool = false;
        for model in self.models {
            if model.modelName == type.modelName {
                inside = true;
            }
        }
        if inside == false {
            assertionFailure("You did not register the model type \(type.modelName)");
            return;
        }
        
        let name = type.modelName;
        if var cache = self.cache[name] {
            cache.append(model);
        } else {
            self.cache[name] = [];
            self.cache[name]?.append(model);
        }
        
        model.isInCache = true;
        self.saveCache();
    }
    
    /// load everything in the cache
    public func loadCache() {
        for model in self.models {
            if let data = UserDefaults.standard.object(forKey: model.modelName) as? Data {
                if let objs = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PSCachedModel] {
                    self.cache[model.modelName] = objs;
                }
            }
            
        }
    }
    
    /// save everything in the cache
    public func saveCache() {
        for model in self.models {
            if self.cache[model.modelName] == nil {
                self.cache[model.modelName] = [];
            }
            
            //look into removing duplicate objects
            //            let ar = $.uniq(self.cache[model.modelName]!, by: {
            //                return $0.id;
            //            });
            
            
            let data = NSKeyedArchiver.archivedData(withRootObject: self.cache[model.modelName]!);
            UserDefaults.standard.setValue(data, forKeyPath: model.modelName);
            
        }
        UserDefaults.standard.synchronize();
    }
    
    
}


/// Base cached model
@objc open class PSCachedModel: NSObject, NSCoding {
    
    
    /// The name of the model (used in the model cache)
    open class var modelName: String {
        get {
            assertionFailure("did not override model name in a cached model type");
            return "Cached Model"
        }
    }
    
    /// helper property, it gets all of the cached models of this type from the model cache
    open class var models: [PSCachedModel] {
        get {
            if let models = PSModelCache.shared.getModelsFromCache(ofType: self) {
                return models;
            }
            return [];
        }
    }
    
    
    public var id: String = "";
    
    public var isInCache: Bool = false;
    
    
    public func encode(with aCoder: NSCoder) {
        let mirror = Mirror(reflecting: self);
        for child in mirror.children { //mirror the object so we can loop through the object's properties and get the saved values
            if let name = child.label {
                aCoder.encode(child.value as? AnyObject, forKey: name);
            }
        }
    }
    
    
    
    public override init() {
        super.init();
    }
    
    /// Add the model to the cache
    public func addToCache() {
        if self.isInCache == true {
            return;
        }
        PSModelCache.shared.addModelToCache(model: self);
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init();
        let mirror = Mirror(reflecting: self);
        for child in mirror.children { //mirror the object so we can loop through the object'ss properties and get the saved values
            if let name = child.label {
                let value = aDecoder.decodeObject(forKey: name);
                setValue(value, forKey: name);
            }
        }
    }
    
    
    
    
}
