//
//  PersistantSwift.swift
//  PersistentSwift
//
//  Created by Alex Hartwell on 1/28/17.
//  Copyright © 2017 hartwell. All rights reserved.
//

import Foundation



open class PSModelCache {
    
    public static var shared: PSModelCache = PSModelCache();
    public var models: [PSCachedModel.Type] = [];
    
    var dictionaryCache: [String: [String: PSCachedModel]] = [:];
    
 
    
    /// get models of type from the cache as an array
    ///
    /// - Parameter ofType: the type of object to get ex. SubclassCachedModel.self
    /// - Returns: the array of models if they exist, otherwise nil
    public func getModelsFromCache<T: PSCachedModel>(ofType: PSCachedModel.Type) -> [T]? {
        if let cache = self.dictionaryCache[ofType.modelName] {
            let array = Array(cache.values);
            return array as! [T];
        }
        return nil;
    }
    
    /// get models of a specific type from the cache as a dictionary [Id String: Obj]
    ///
    /// - Parameter ofType: the type of models you want ex SubclassCachedModel.self
    /// - Returns: the dictionary of models if they exist, otherwise nil
    public func getModelsDictionaryFromCache<T: PSCachedModel>(ofType: PSCachedModel.Type) -> [String: T]? {
        return self.dictionaryCache[ofType.modelName] as? [String: T];
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
    /// - Parameter model: the model to add
    /// - Returns: true if model was added to the cache, false if it was already in it
    public func addModelToCache(model: PSCachedModel) -> Bool {
        let type: PSCachedModel.Type = type(of: model);
        
        var inside: Bool = false;
        for model in self.models {
            if model.modelName == type.modelName {
                inside = true;
            }
        }
        if inside == false {
            assertionFailure("You did not register the model type \(type.modelName)");
            return false;
        }

        
        let name = type.modelName;

        self.createCacheIfNeeded(ofName: name);
        var alreadyInCache: Bool = self.isObjectInCache(ofName: name, obj: model);
        self.appendObjectToCache(ofName: name, obj: model);
        
        model.isInCache = true;

        return alreadyInCache == false;
    }
    
    
    func isObjectInCache(ofName name: String, obj: PSCachedModel) -> Bool {
        if (self.dictionaryCache[name]![obj.id] != nil) {
            return true;
        }
        return false;
    }
    
    func createCacheIfNeeded(ofName name: String) {
        if self.dictionaryCache[name] == nil {
            self.dictionaryCache[name] = [:];
        }
    }
    
    func appendObjectToCache(ofName name: String, obj: PSCachedModel) {
        self.dictionaryCache[name]?[obj.id] = obj;
    }
    
    /// load everything in the cache
    public func loadCache() {
        for model in self.models {
            if let data = UserDefaults.standard.object(forKey: model.modelName) as? Data {
                if let objs = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: PSCachedModel] {
                    self.dictionaryCache[model.modelName] = objs;
                }
            }
            
        }
    }
    
    /// save everything in the cache
    public func saveCache() {
        for model in self.models {
            self.createCacheIfNeeded(ofName: model.modelName);
            
            //look into removing duplicate objects
            //            let ar = $.uniq(self.cache[model.modelName]!, by: {
            //                return $0.id;
            //            });
            
            
            let data = NSKeyedArchiver.archivedData(withRootObject: self.dictionaryCache[model.modelName]!);
            UserDefaults.standard.setValue(data, forKeyPath: model.modelName);
            
        }
        UserDefaults.standard.synchronize();
    }
    
    
    public func clearCache() {
        self.dictionaryCache = [:];
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
    
    open class var modelsDictionary: [String: PSCachedModel] {
        get {
            if let models = PSModelCache.shared.getModelsDictionaryFromCache(ofType: self) {
                return models;
            }
            return [:];
        }
    }
    
    
    open class func getModel(byId id: String) -> PSCachedModel? {
        if let models = PSModelCache.shared.getModelsDictionaryFromCache(ofType: self) {
            if let model = models[id] {
                return model;
            }
        }
        return nil;
    }
    
    
    //I am assuming every model has an id (this property is not used in the internals of the cache, you can set it to whatever is in your db)
    public var id: String = "";
    
    public var isInCache: Bool = false;
    
    
    public func encode(with aCoder: NSCoder) {
        let mirror = Mirror(reflecting: self);
        self.encodeFromMirror(mirror: mirror, aCoder: aCoder);
    }
    
    func encodeFromMirror(mirror: Mirror, aCoder: NSCoder) {
        for child in mirror.children { //mirror the object so we can loop through the object's properties and get the saved values
            if let name = child.label {
                aCoder.encode(child.value as? Any, forKey: name);
            }
        }
        if let parent = mirror.superclassMirror {
            self.encodeFromMirror(mirror: parent, aCoder: aCoder);
        }
    }
    
    
    public override init() {
        super.init();
    }
    
    /// add a model to the cache
    ///
    /// - Returns: returns true if the model was added to the cache, false if it was already in the cache
    public func addToCache() -> Bool {
        if self.isInCache == true {
            return false;
        }
        return PSModelCache.shared.addModelToCache(model: self);
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init();
        let mirror = Mirror(reflecting: self);
        self.initFromMirror(mirror: mirror, aDecoder: aDecoder);
    }
    
    func initFromMirror(mirror: Mirror, aDecoder: NSCoder) {
        for child in mirror.children { //mirror the object so we can loop through the object'ss properties and get the saved values
            if let name = child.label {
                let value = aDecoder.decodeObject(forKey: name);
                if value is NSNull {
                    print("the value for \(name) was NSNull, we are not loading it from the cache");
                } else {
                    if let v = value as? Any {
                        if v is NSNull {
                            print("not loading value \(name), it is NSNull");
                        } else {
                            setValue(v, forKey: name);
                        }
                    }
                }
            }
        }
        if let parent = mirror.superclassMirror {
            self.initFromMirror(mirror: parent, aDecoder: aDecoder);
        }
    }
    
    
    
    
}
