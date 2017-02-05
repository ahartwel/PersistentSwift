//
//  Background.swift
//  PersistentSwift
//
//  Created by Alex Hartwell on 9/6/16.
//  Copyright © 2016 SWARM. All rights reserved.
//

import Foundation

class Background {
    
    static func runInBackground(_ inBackground: @escaping (() -> ())) {
        let priority = DispatchQueue.GlobalQueuePriority.background;
        DispatchQueue.global(priority: priority).async {
            inBackground()
        }
    }
    
    static func runInBackgroundAndCallback(_ inBackground: @escaping (() -> ()), callback: @escaping (() -> ())) {
        let priority = DispatchQueue.GlobalQueuePriority.background;
        DispatchQueue.global(priority: priority).async {
            inBackground()
            DispatchQueue.main.async {
                callback()
            }
        }
    }
    
    static func runInBackgroundAsyncAndCallback(_ inBackground: @escaping (( (() -> ()) ) -> ()), callback: @escaping (() -> ())) {
        let priority = DispatchQueue.GlobalQueuePriority.background;
        DispatchQueue.global(priority: priority).async {
            inBackground({
                DispatchQueue.main.async {
                    callback();
                }
            })
        }
    }
    
    static func runInMainThread(_ closure: @escaping (() -> ())) {
        DispatchQueue.main.async(execute: closure);
    }
    
}
