//
//  URLSessionDataTask.swift
//  Overdrive
//
//  Created by Said Sikira on 6/21/16.
//  Copyright © 2016 Said Sikira. All rights reserved.
//

import Foundation

public class URLSessionDataTask: Task<(NSURLResponse, NSData)> {
    public let request: NSURLRequest
    
    //MARK: Init request
    public init(request: NSURLRequest) {
        self.request = request
    }
    
    public convenience init(URL: NSURL) {
        let request = NSURLRequest(URL: URL)
        self.init(request: request)
    }
    
    public convenience init(URLString: String) {
        let URL = NSURL(string: URLString)!
        let request = NSURLRequest(URL: URL)
        self.init(request: request)
    }
    
    //MARK: URL Session
    public override func run() {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                self.finish(.Error(error!))
            } else {
                self.finish(.Value((response!, data!)))
            }
        }
        
        task.resume()
    }
}
