import UIKit
import XCTest
import PersistentSwift

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
    
    func testCacheManager() {
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
        newModel.name = "testtesttest";
        newModel.isLive = false;
        newModel.number = 10000;
        newModel.addToCache();
        
        PSModelCache.shared.saveCache();
        
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
            
            var name: String = "Hello";
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
