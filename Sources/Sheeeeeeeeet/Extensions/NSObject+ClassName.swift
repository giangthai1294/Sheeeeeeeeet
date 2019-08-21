//
//  NSObject+ClassName.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-11-24.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

//  This file contains internal util functions for resolving
//  the class name of classes and class instances.

import UIKit

extension NSObject {
    
    /**
     Get the type's class name.
     */
    static var className: String {
        return String(describing: self)
    }
    
    /**
    Get the instance's class name.
    */
    var className: String {
        return type(of: self).className
    }
}