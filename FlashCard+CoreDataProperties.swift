//
//  FlashCard+CoreDataProperties.swift
//  FlashCards
//
//  Created by Sam Black on 9/13/23.
//
//

import Foundation
import CoreData


extension FlashCard {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<FlashCard> {
        return NSFetchRequest<FlashCard>(entityName: "FlashCard")
    }

    @NSManaged public var prompt: String?
    @NSManaged public var category1: String?
    @NSManaged public var category2: String?
    @NSManaged public var category3: String?
    @NSManaged public var answer: String?

}

extension FlashCard : Identifiable {

}
