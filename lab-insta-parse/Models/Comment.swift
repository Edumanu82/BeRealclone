//
//  Comment.swift
//  lab-insta-parse
//

//
//  Comment.swift
//  lab-insta-parse
//

import Foundation
import ParseSwift

struct Comment: ParseObject {
    var originalData: Data?
    

    // ParseSwift required fields
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?

    // Class name in your Parse DB (Back4App)
    static var className: String { "Comment" }

    // Your custom fields (must match column names in Back4App)
    var text: String?
    var post: Post?
    var user: User?
    var username: String?

    // ParseSwift sometimes expects an explicit empty init
    init() { }
}
