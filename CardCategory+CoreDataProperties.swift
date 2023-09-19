//
//  CardCategory+CoreDataProperties.swift
//  FlashCards
//
//  Created by Sam Black on 9/19/23.
//
//

import Foundation
import CoreData

public class CardCategory: NSManagedObject {

}

extension CardCategory {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<CardCategory> {
        return NSFetchRequest<CardCategory>(entityName: "CardCategory")
    }

    @NSManaged public var catImage: Data?
    @NSManaged public var catName: String?

}

extension CardCategory : Identifiable {

}
