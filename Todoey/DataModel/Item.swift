

import Foundation
import RealmSwift
class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var timeStamp: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")// this is to define inverse relationship of "item to category" (Many to One)
}
