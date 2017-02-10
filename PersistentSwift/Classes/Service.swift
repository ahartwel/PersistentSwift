//
//  Service.swift
//  Pods
//
//  Created by Alex Hartwell on 2/9/17.
//
//

import Foundation
import Moya
import PromiseKit

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
class PSService<T: TargetType, V: PSCachedModel> {
    
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
