import UIKit
import XCTest
import PersistentSwift
import SwiftyJSON

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    
    
    
    
    
    func testCachedModels() {
        var cache = PSModelCache();

        
        class TestModel: PSCachedModel {
            
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            
            
            var name: String = "Hello";
            var isLive: Bool = true;
            var number: Double = 1000;
            
        }
        
        let modelArray: [PSCachedModel.Type] = [TestModel.self];
        cache.registerModels(models: modelArray);
        
        let newModel = TestModel();
        newModel.name = "test";
        newModel.isLive = false;
        newModel.number = 10;
        newModel.forTestingAddToCache(cache: cache);
        
        let data = NSKeyedArchiver.archivedData(withRootObject: newModel);
        UserDefaults.standard.setValue(data, forKey: "cacheTest");
        
        
        if let dataFromCache = UserDefaults.standard.object(forKey: "cacheTest") as? Data {
            if let objs = NSKeyedUnarchiver.unarchiveObject(with: dataFromCache) as? TestModel {
                if objs.name == "test" && objs.isLive == false && objs.number == 10 {
                    XCTAssert(true);
                } else {
                    XCTAssert(false);
                }
                
            } else {
                XCTAssert(false);
            }
        } else {
            XCTAssert(false);
        }
        
        
        
        
    }
    
    
    func testGetModelById() {
        var cache = PSModelCache.shared;

        enum TestEnum {
            case what
            case test
        }
        class TestModel: PSCachedModel {
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            var testEnum: TestEnum = TestEnum.what;
            var name: String? = nil;
            var isLive: Bool = true;
            var number: Double = 1000;
            
        }
        
        let modelArray: [PSCachedModel.Type] = [TestModel.self];
        cache.registerModels(models: modelArray);
        
        let newModel = TestModel();
        newModel.id = "100";
        newModel.name = "testtesttest";
        newModel.isLive = false;
        newModel.number = 10000;
        newModel.forTestingAddToCache(cache: cache);
        
        XCTAssert((TestModel.getModel(byId: "100") as! TestModel).name == "testtesttest");
        
        
        
        
    }
    
    func testCacheManager() {
        var cache = PSModelCache.shared;

              class TestModel: PSCachedModel {
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            var name: String? = nil;
            var isLive: Bool = true;
            var number: Double = 1000;
            

        }
        
        let modelArray: [PSCachedModel.Type] = [TestModel.self];
        cache.registerModels(models: modelArray);
        
        let newModel = TestModel();
        newModel.name = "testtesttest";
        newModel.isLive = false;
        newModel.number = 10000;
        newModel.forTestingAddToCache(cache: cache);
        
        cache.saveCache();
        cache.clearCache();
        cache.loadCache();
        if let models: [TestModel] = cache.getModelsFromCache(ofType: TestModel.self) {
            let obj = models[0];
            if obj.name == "testtesttest" && obj.isLive == false && obj.number == 10000 {
                XCTAssert(true);
                
            } else {
                XCTAssert(false);
                
            }
        } else {
            XCTAssert(false);
        }
    }
    
    
    func testCachedModelGetHelper() {
        var cache = PSModelCache.shared;

        class TestModel: PSCachedModel {
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            
            var name: String? = "Hello";
            var isLive: Bool = true;
            var number: Double = 1000;
            
        }
        
        let modelArray: [PSCachedModel.Type] = [TestModel.self];
        cache.registerModels(models: modelArray);
        
        let newModel = TestModel();
        newModel.name = "testtest";
        newModel.isLive = false;
        newModel.number = 10;
        newModel.forTestingAddToCache(cache: cache);
        
        let models: [TestModel] = TestModel.models as! [TestModel];
        if let model = models[0] as? TestModel {
            if model.name == "testtest" {
                XCTAssert(true);
            } else {
                XCTAssert(false);
                
            }
        } else {
            XCTAssert(false);
        }
        
    }
    
    
    func testModelSearching() {
        var cache = PSModelCache.shared;

        class TestModel: PSCachedModel {
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            
            var name: String? = "Hello";
            var isLive: Bool = true;
            var number: Double = 1000;
            
        }
        
        let modelArray: [PSCachedModel.Type] = [TestModel.self];
        cache.registerModels(models: modelArray);
        
        let model1 = TestModel();
        model1.id = "100";
        model1.name = "WHAT WHAT"
        
        _ = model1.forTestingAddToCache(cache: cache);
        
        let model2 = TestModel();
        model2.id = "10000";
        model2.name = "what";
        
        
        let models = PSDataManager<TestModel>.getModels(byValue: "WHAT WHAT", forKey: "name", ofType: String.self);
        
        XCTAssert(models.count == 1);
        
        
        
        
    }
    
    
    func testReturnType() {
        class TestModel: PSCachedModel {

            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            
            var name: String? = "Hello";
            var isLive: Bool = true;
            var number: Double = 1000;
            
        }
        
        
        
    }
    
    func testGetObjDictionary() {
        var cache = PSModelCache.shared;
        class TestModel: PSCachedModel {
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            
            var name: String? = "Hello";
            var isLive: Bool = true;
            var number: Double = 1000;
            
        }
        
        let modelArray: [PSCachedModel.Type] = [TestModel.self];
        cache.registerModels(models: modelArray);
        
        let model1 = TestModel();
        model1.id = "100";
        
        _ = model1.forTestingAddToCache(cache: cache);
        
        let models = TestModel.modelsDictionary as! [String: TestModel];
        XCTAssert(models["100"]!.id == model1.id);
        
    }
    
    
    func testClearingCache() {
        class TestModel: PSCachedModel {
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            
            var name: String? = "Hello";
            var isLive: Bool = true;
            var number: Double = 1000;
            
        }
        let modelArray: [PSCachedModel.Type] = [TestModel.self];
        PSModelCache.shared.registerModels(models: modelArray);
        
        let model1 = TestModel();
        model1.id = "100";
        _  = model1.addToCache();
        
        let modelCount = TestModel.models.count;
        
        PSModelCache.shared.clearCache(ofType: TestModel.self);
        
        let newModelCount = TestModel.models.count;
        
        XCTAssertEqual(modelCount, 1);
        XCTAssertEqual(newModelCount, 0);
        
        
        

    }
    
    func testDuplicateObjectsBehaivor() {
        var cache = PSModelCache.shared;

        class TestModel: PSCachedModel {
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            
            var name: String? = "Hello";
            var isLive: Bool = true;
            var number: Double = 1000;
            
        }
        
        let modelArray: [PSCachedModel.Type] = [TestModel.self];
        cache.registerModels(models: modelArray);
        
        var model1 = TestModel();
        model1.id = "100";
        var model2 = TestModel()
        model2.name = "WHAT WHAT WHAT";
        model2.id = "100";
        
        
        model1.forTestingAddToCache(cache: cache);
        
        model2.forTestingAddToCache(cache: cache);
        
        let models = TestModel.models as! [TestModel];
        XCTAssert(models.count == 1);
        XCTAssert(models[0].name == "WHAT WHAT WHAT")
        
        
        
    }
    

    
    func testBindingAdd() {
        var cache = PSModelCache();

        let exp = self.expectation(description: "get event with a model");
        class TestModel: PSCachedModel {
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            
            var name: String? = "Hello";
            var isLive: Bool = true;
            var number: Double = 1000;
            
        }
        let modelArray: [PSCachedModel.Type] = [TestModel.self];
        cache.registerModels(models: modelArray);
        var model1 = TestModel();
        model1.id = "100";
        
        var onDataAdded: (PSDataEvent<PSCachedModel>) -> () = {
            event in
            print(event);
            if event.getData() != nil {
                exp.fulfill();
            }
        }
        
        TestModel.addCallbackOnCacheChange(onDataAdded);
        model1.forTestingAddToCache(cache: cache);
        
        self.waitForExpectations(timeout: 4, handler: nil);
        
        
    }
    

    func testJSONValueCreation() {
        var cache = PSModelCache();

        var value: PSModelValue<Int> = PSModelValue<Int>(jsonPath: "test.inside.int");
        let jsonString = "{" +
        "\"test\": {" +
            "\"inside\": {" +
                        "\"int\": 3" +
            "}" +
        "}" +
        "}";
        
       
        let json: JSON = JSON(parseJSON: jsonString);
        
        value.setValueFromJSON(json);
        
        XCTAssertEqual(value.get(), 3);
        
        
        
        
        
    }
    
   
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}



