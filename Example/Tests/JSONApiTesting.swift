//
//  JSONApiTesting.swift
//  PersistentSwift
//
//  Created by Alex Hartwell on 2/5/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import PersistentSwift
import SwiftyJSON
import PromiseKit

class JSONApiTesting: XCTestCase {
    
    
    class Author: PSCachedModel {
        override class var modelName: String {
            return "authors";
        }
    }
    class Articles: PSCachedModel {
        
        typealias ArticleService = PSServiceMap<Articles, ArticlesTestData>
        
        override class var modelName: String {
            return "articles";
        }
        var title: String?
        var body: String?
        
        
        var authorId: String?
        
        override var attributes: [String: Any?] {
            return [
                "title": self.title,
                "body": self.body
            ];
        }
        
        override var relationships: [String: (id: String, type: PSCachedModel.Type)] {
            return [
                "author": (id: self.authorId!, type: Author.self)
            ];
        }
        
        override init() {
            super.init();
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder);
        }
        
        required init?(jsonData: JSON) {
            super.init(jsonData: jsonData);
        }
        
        override func setUpAttributes(json: JSON) {
            self.title = json["title"].string;
            self.body = json["body"].string;
        }
        
        override func setUpRelationships(json: JSON) {
            self.authorId = self.getRelationshipId(fromKey: "author", fromJSON: json);
        }
        
    }
    
    class ArticlesTestData: TestData {
        public static var deleteTestData: Data {
            return Data();
        }

        public static var getListTestData: Data {
            return "{\n  \"data\": [{\n    \"type\": \"articles\",\n    \"id\": \"1\",\n    \"attributes\": {\n      \"title\": \"JSON API paints my bikeshed!\",\n      \"body\": \"The shortest article. Ever.\",\n      \"created\": \"2015-05-22T14:56:29.000Z\",\n      \"updated\": \"2015-05-22T14:56:28.000Z\"\n    },\n    \"relationships\": {\n      \"author\": {\n        \"data\": {\"id\": \"42\", \"type\": \"people\"}\n      }\n    }\n  }],\n  \"included\": [\n    {\n      \"type\": \"people\",\n      \"id\": \"42\",\n      \"attributes\": {\n        \"name\": \"John\",\n        \"age\": 80,\n        \"gender\": \"male\"\n      }\n    }\n  ]\n}".data(using: String.Encoding.utf8)!;
        }
        
        public static var getCreateTestData: Data {
            return "{\n  \"data\": {\n    \"type\": \"articles\",\n    \"attributes\": {\n      \"title\": \"test title\",\n      \"body\": \"test body\"\n    },\n    \"relationships\": {\n      \"author\": {\n        \"data\": { \"type\": \"authors\", \"id\": \"test id\" }\n      }\n    }\n  }\n}".data(using: String.Encoding.utf8)!;
        }
        
    }
    
    class ArticleService: PSService<Articles.ArticleService, Articles> {
        static var shared: ArticleService = ArticleService();
    }

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testGetRequest() {
        
        let exp = self.expectation(description: "will get a list of articles");
        
        
        
        PSServiceManager.setIsTesting(true);
        ArticleService.shared.makeRequestArray(Articles.ArticleService.getList).then(execute: {
            articles -> Void in
            XCTAssertEqual(articles.count, 1)
            XCTAssertEqual(articles[0].title, "JSON API paints my bikeshed!");
            XCTAssertEqual(articles[0].body, "The shortest article. Ever.");
            exp.fulfill();
        }).catch {
            error in
            XCTAssert(false);
        }
        
        self.waitForExpectations(timeout: 15, handler: nil);
        
    }
    
    func testCreatingPostParams() {
        PSServiceManager.setBaseUrl("http://google.com");
        PSServiceManager.setIsTesting(true);
        
        let article = Articles();
        article.title = "test title";
        article.body = "test body";
        article.authorId = "test id";
        let params = article.getCreateParameters(fromModelName: Articles.modelName);
        
        let data = params!["data"]! as! [String: Any];
        let type = data["type"] as! String;
        XCTAssertEqual(type, "articles");
        
        let attributes = data["attributes"] as! [String: Any];
        XCTAssertEqual(attributes["title"] as! String, "test title");
        XCTAssertEqual(attributes["body"] as! String, "test body");
        
        let relationships = data["relationships"] as! [String: Any];
        let author = relationships["author"] as! [String: Any];
        let authorData = author["data"] as! [String: Any];
        XCTAssertEqual(authorData["id"] as! String, "test id");
        XCTAssertEqual(authorData["type"] as! String, "authors");
        
        
        
    }
    
    func testCreateRequest() {
        let exp = self.expectation(description: "will create an article");
        PSServiceManager.setBaseUrl("http://google.com");
        PSServiceManager.setIsTesting(true);
        let article = Articles();
        article.title = "test title";
        article.body = "test body";
        article.authorId = "test id";
        ArticleService.shared.makeRequest(.createObject(obj: article)).then {
            article -> Void in
            XCTAssertEqual(article.authorId, "test id");
            XCTAssertEqual(article.title, "test title");
            XCTAssertEqual(article.body, "test body");
            exp.fulfill();
            }.catch {
                error in
                XCTAssert(false, "request failed");
        }
        
        self.waitForExpectations(timeout: 5, handler: nil);
        
    }
    
    func testDeleteData() {
        let exp = self.expectation(description: "will delete an article");
        PSServiceManager.setBaseUrl("http://google.com");
        PSServiceManager.setIsTesting(true);
        let article = Articles();
        article.title = "test title";
        article.body = "test body";
        article.authorId = "test id";
        ArticleService.shared.makeRequestNoObjectReturn(.deleteObject(obj: article)).then {
            exp.fulfill();
            }.catch {_ in 
                XCTAssert(false, "this request never finished");
        }
        self.waitForExpectations(timeout: 5, handler: nil);
    }
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}