//
//  Post.swift
//  Quill
//
//  Created by Yasir Hakami on 24/12/2021.
//

import Foundation
import Firebase
struct Post {
    var id = ""
    var price = ""
    var contact = ""
    var description = ""
    var signature = ""
    var imageUrl = ""
    var user:User
    var createdAt:Timestamp?
    
    init(dict:[String:Any],id:String,user:User) {
        if let price = dict["price"] as? String,
           let description = dict["description"] as? String,
           let contact = dict["contact"] as? String,
           let signature = dict["signature"] as? String,
           let imageUrl = dict["imageUrl"] as? String,
            let createdAt = dict["createdAt"] as? Timestamp{
            self.price = price
            self.signature = signature
            self.contact = contact
            self.description = description
            self.imageUrl = imageUrl
            self.createdAt = createdAt
        }
        self.id = id
        self.user = user
    }
}
