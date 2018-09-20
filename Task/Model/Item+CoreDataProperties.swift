//
//  Item+CoreDataProperties.swift
//  Task
//
//  Created by Admin on 9/19/18.
//  Copyright © 2018 Admin. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    
    @NSManaged public var descrip: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var title: String?
    
}
