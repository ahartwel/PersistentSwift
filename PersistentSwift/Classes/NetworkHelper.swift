//
//  NetworkHelper.swift
//  Pods
//
//  Created by Alex Hartwell on 2/5/17.
//
//

import Foundation
import Moya
import SwiftyJSON
import PromiseKit
import PersistentSwift
import Alamofire


public extension Response {
    
    /// Maps data received from the signal into an object which implements the ALSwiftyJSONAble protocol.
    /// If the conversion fails, the signal errors.
    public func map<T: PSCachedModel>(to type:T.Type) throws -> T {
        let jsonObject = try mapJSON()
        
        guard let mappedObject = T(jsonData: JSON(jsonObject)["data"]) else {
            throw MoyaError.jsonMapping(self)
        }
        
        return mappedObject
    }
    
    /// Maps data received from the signal into an array of objects which implement the ALSwiftyJSONAble protocol
    /// If the conversion fails, the signal errors.
    public func map<T: PSCachedModel>(to type:[T.Type]) throws -> [T] {
        let jsonObject = try mapJSON()
        
        let mappedArray = JSON(jsonObject)["data"];
        let mappedObjectsArray = mappedArray.arrayValue.flatMap { T(jsonData: $0) }
        
        return mappedObjectsArray
    }
    
}


struct AuthPlugin: PluginType {
    let tokenClosure: (() -> String?)
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        
        if let token = tokenClosure() {
            var request = request
            request.addValue("Token " + token, forHTTPHeaderField: "Authorization")
            return request
        }
        else {
            return request;
        }
    }
}

public enum PSServiceMap<T: PSCachedModel, D: TestData> {
    case getList
    case createObject(obj: T)
    case updateObject(obj: T)
    case deleteObject(obj: T)
}


extension PSServiceMap: TargetType {
    /// The target's base `URL`.
    public var baseURL: URL {
        return URL(string: PSServiceManager.constants.baseUrl)!;
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .getList:
            return "/\(T.modelName)";
        case .createObject(let obj):
            return "/\(T.modelName)";
        case .updateObject(let obj):
            return "/\(T.modelName)";
        case .deleteObject(let obj):
            return "/\(T.modelName)/\(obj.id)";
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .getList:
            return .get;
        case .createObject( _):
        return .post;
        case .updateObject(obj: _):
            return .patch;
        case .deleteObject( _):
            return .delete
        }
    }
    
    /// The parameters to be incoded in the request.
    public var parameters: [String: Any]? {
        switch self {
        case .getList:
            return nil;
        case .createObject(let obj):
            return obj.getCreateParameters(fromModelName: T.modelName);
        case .updateObject(let obj):
            return obj.getCreateParameters(fromModelName: T.modelName);
        case .deleteObject( _):
            return nil;
        }
    }
    
    /// The method used for parameter encoding.
    public var parameterEncoding: ParameterEncoding {
        switch self {
        case .getList:
            return URLEncoding.default;
        case .createObject( _):
            return JSONEncoding.default;
        case .updateObject( _):
            return JSONEncoding.default;
        case .deleteObject( _):
            return URLEncoding.default;
        }
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        switch self {
        case .getList:
            return D.getListTestData;
        case .createObject( _):
            return D.getCreateTestData;
        case .updateObject( _):
            return D.getCreateTestData;
        case .deleteObject( _):
            return D.deleteTestData;
        }
    }
    
    /// The type of HTTP task to be performed.
    public var task: Task {
        return Task.request
    }
    
    
}



open class NoTestData: TestData {
    public static var getListTestData: Data {
        return Data();
    }
    
    public static var getCreateTestData: Data {
        return Data();
    }
    
    public static var deleteTestData: Data {
        return Data();
    }
    
}

public protocol TestData {
    static var getListTestData: Data { get }
    static var getCreateTestData: Data { get }
    static var deleteTestData: Data { get }
}


struct ServiceConstants {
    var baseUrl: String
}

open class PSServiceManager {
    
    static var constants = ServiceConstants(baseUrl: "");
    static var authToken: String?
    static var isTesting: Bool = false;
    open static func setBaseUrl(_ url: String) {
        PSServiceManager.constants.baseUrl = url;
    }
    
    open static func setAuthToken(token: String) {
        PSServiceManager.authToken = token;
    }
    
    open static func setIsTesting(_ bool: Bool) {
        self.isTesting = bool;
    }
    
}

//A Generic class for making network requests (to be subclassed for each section of the API eg. AvatarService, EventService, UserService etc
open class PSService<T: TargetType, V: PSCachedModel> {
    
    var baseUrl: String = "";
    
    //the actual object used to make the requests
    lazy var provider: MoyaProvider<T> = self.getProvider();
    var authToken: String?
    func getProvider() -> MoyaProvider<T> {
        if PSServiceManager.isTesting {
            let provider = MoyaProvider<T>(stubClosure: {
                _ in
                return .immediate;
            }, plugins: [
                AuthPlugin(tokenClosure: {
                    
                    return PSServiceManager.authToken
                    
                })
                ]);
            return provider;
        } else {
            
            let provider = MoyaProvider<T>(
                plugins: [
                    AuthPlugin(tokenClosure: { return PSServiceManager.authToken })
                ]
            )
            return provider;
        }
    }
    
    public init() {
        
    }
    
    //a wrapper for a request which returns a single object, type is the type of request, defined in the API map
    public func makeRequest(_ type: T) -> Promise<V> {
        let promise = Promise<V>.pending();
        Background.runInBackground {
            self.provider.request(type, completion: {
                result in
                switch result {
                case let .success(moyaResponse):
                    let json = JSON(data: moyaResponse.data);
                    print(json);
                    do {
                        let object = try moyaResponse.map(to: V.self);
                        Background.runInMainThread {
                            promise.fulfill(object);
                        }
                    }catch {
                        print(error);
                        print(type);
                        Background.runInMainThread {
                            promise.reject(error);
                        }
                    }
                    break;
                case let .failure(error):
                    Background.runInMainThread {
                        promise.reject(error);
                    }
                    break;
                }
            });
        }
        return promise.promise;
    }
    
    public func makeRequestNoObjectReturn(_ type: T) -> Promise<Void> {
        let promise = Promise<Void>.pending();
        Background.runInBackground {
            self.provider.request(type, completion: {
                result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        try moyaResponse.filterSuccessfulStatusAndRedirectCodes();
                        Background.runInMainThread {
                            promise.fulfill();
                        }
                    
                    }catch {
                        print(error);
                        Background.runInMainThread {
                            promise.reject(error);
                        }
                    }
                    break;
                case let .failure(error):
                    Background.runInMainThread {
                        promise.reject(error);
                    }
                    break;
                }
            });
        }
        
        return promise.promise;
    }
    
    
    //a wrapper for a request which returns an array of objects
    public func makeRequestArray(_ type: T) -> Promise<[V]> {
        let promise = Promise<[V]>.pending();
        Background.runInBackground {
            self.provider.request(type, completion: {
                result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        let objects = try moyaResponse.map(to: [V.self]) as! [V];
                        Background.runInMainThread {
                            promise.fulfill(objects);
                        }
                    }catch {
                        print(error);
                        Background.runInMainThread {
                            promise.reject(error);
                        }
                    }
                    break;
                case let .failure(error):
                    Background.runInMainThread {
                        promise.reject(error);
                    }
                    break;
                }
            });
        }
        
        return promise.promise;
    }
    
    
}
