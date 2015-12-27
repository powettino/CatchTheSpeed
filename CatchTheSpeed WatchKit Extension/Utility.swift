//
//  utility.swift
//  CatchTheSpeed
//
//  Created by Iacopo Peri on 05/10/15.
//  Copyright (c) 2015 YeApp. All rights reserved.
//

import Foundation


class Utility {
    
    static func prepareRestRequest(url : String) -> NSMutableURLRequest{
        
         var urlReq : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        urlReq.HTTPMethod = "GET"
        urlReq.setValue("7Zn8mV9WPMzBprhPiZDcqOVxlGc6UYNpmTN4qQLs", forHTTPHeaderField: "X-Parse-Application-Id")
        urlReq.setValue("Rv9xdCM7GzTvTz13VeCzE8UEB0UPpmWMC29lAg0k", forHTTPHeaderField: "X-Parse-REST-API-Key")
        return urlReq
    }
    
}