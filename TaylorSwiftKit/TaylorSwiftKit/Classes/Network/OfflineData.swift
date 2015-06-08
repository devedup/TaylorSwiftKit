//
//  OfflineData.swift
//  InvescoTraining
//
//  Created by David Casserly on 23/11/2014.
//  Copyright (c) 2014 DevedUp Ltd. All rights reserved.
//

import Foundation

class OfflineData {
    
    func writeToFile(data: NSData, url: NSURL) {
        let path = filePath(url.absoluteString!)
        if let path = path {
            data.writeToFile(path, atomically: false);
        }
        println("Cached data at path [\(path)]")
    }
    
    func readFromFile(url: NSURL) -> NSData? {        
        let path = filePath(url.absoluteString!)
        println("Reading data at path [\(path)]")
        if let path = path {
            let data = NSData(contentsOfFile:path, options: nil, error: nil)
            return data
        } else {
            return nil
        }
    }
    
    func dataExistAtURL(path: String) -> Bool {
        let cache = cacheDir()
        let fileName = fileNameNormalised(path)
        
        let fm = NSFileManager()
        
        let enumerator = fm.enumeratorAtPath(cache!)
        while let element = enumerator?.nextObject() as? String {
            println("Element \(element)")
            println("Filenam \(fileName)")
            if element == fileName {
                return true
            }
        }
        return false
    }
    
    class func clearCache() {
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        if ((dirs) != nil) {
            var dir = dirs![0]; //documents directory
            dir += "/urlcache"
            
            var isDir: ObjCBool = true
            let fm = NSFileManager()
            fm.removeItemAtPath(dir, error: nil)
            
        }
    }
    
    private func cacheDir() -> String? {
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        if ((dirs) != nil) {
            var dir = dirs![0]; //documents directory
            dir += "/urlcache"
            
            var isDir: ObjCBool = true
            let fm = NSFileManager()
            if !fm.fileExistsAtPath(dir, isDirectory: &isDir) {
                if !fm.createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil, error: nil) {
                    println("Couldn't create")
                }
            }
    
            return dir
        } else {
            return nil
        }
    }
    
    private func fileNameNormalised(fileName: String) -> String {
        var fileName = fileName.stringByReplacingOccurrencesOfString(".", withString: "", options: nil)
        fileName = fileName.stringByReplacingOccurrencesOfString("/", withString: "", options: nil)
        fileName = fileName.stringByReplacingOccurrencesOfString(":", withString: "", options: nil)
        return fileName
    }
    
    
    private func filePath(fileName: String) -> String? {
        let cache = cacheDir()
        if let cache = cache {
            var fileName = fileNameNormalised(fileName)
            var path = cache.stringByAppendingPathComponent(fileName);
            return path
        } else {
            return nil
        }
    }
    
}