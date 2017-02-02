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
        PSModelCache.shared.registerModels(models: modelArray);
        
        let newModel = TestModel();
        newModel.name = "test";
        newModel.isLive = false;
        newModel.number = 10;
        newModel.addToCache();
        
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
        PSModelCache.shared.registerModels(models: modelArray);
        
        let newModel = TestModel();
        newModel.id = "100";
        newModel.name = "testtesttest";
        newModel.isLive = false;
        newModel.number = 10000;
        newModel.addToCache();
        
        XCTAssert((TestModel.getModel(byId: "100") as! TestModel).name == "testtesttest");
        
        
        
        
    }
    
    func testCacheManager() {
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
        PSModelCache.shared.registerModels(models: modelArray);
        
        let newModel = TestModel();
        newModel.name = "testtesttest";
        newModel.isLive = false;
        newModel.number = 10000;
        newModel.addToCache();
        
        PSModelCache.shared.saveCache();
        PSModelCache.shared.clearCache();
        PSModelCache.shared.loadCache();
        if let models: [TestModel] = PSModelCache.shared.getModelsFromCache(ofType: TestModel.self) {
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
        
        let newModel = TestModel();
        newModel.name = "testtest";
        newModel.isLive = false;
        newModel.number = 10;
        newModel.addToCache();
        
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
        model1.name = "WHAT WHAT"
        
        _ = model1.addToCache();
        
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
        
        _ = model1.addToCache();
        
        let models = TestModel.modelsDictionary as! [String: TestModel];
        XCTAssert(models["100"]!.id == model1.id);
        
    }
    
    
    func testDuplicateObjectsBehaivor() {
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
        
        var model1 = TestModel();
        model1.id = "100";
        var model2 = TestModel()
        model2.name = "WHAT WHAT WHAT";
        model2.id = "100";
        
        
        model1.addToCache();
        
        model2.addToCache();
        
        let models = TestModel.models as! [TestModel];
        XCTAssert(models.count == 1);
        XCTAssert(models[0].name == "WHAT WHAT WHAT")
        
        
        
    }
    

    
    func testBindingAdd() {
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
        PSModelCache.shared.registerModels(models: modelArray);
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
        model1.addToCache();
        
        self.waitForExpectations(timeout: 4, handler: nil);
        
        
    }
    

    func testJSONValueCreation() {
        var value: PSModelValue<Int> = PSModelValue<Int>(path: "test.inside.int");
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
    
    
    func testJSONModelCreation() {
        class TestModel: PSCachedModel {
            
            override class var modelName: String {
                get {
                    return "Test Model"
                }
            }
            
            var name: String? = "Hello";
            var isLive: Bool = true;
            var number: Double = 1000;
            var _tester: PSModelValue<Int> = PSModelValue<Int>(path: "test.inside.int");
            var tester: Int? {
                return self._tester.get();
            }
        }
        
        let jsonString = "{" +
            "\"test\": {" +
            "\"inside\": {" +
            "\"int\": 3" +
            "}" +
            "}" +
        "}";
        let json: JSON = JSON(parseJSON: jsonString);

        let model = TestModel(withJSON: json);
        
        XCTAssertEqual(model.tester, 3);
        
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}



