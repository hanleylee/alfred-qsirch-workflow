//
//  AlfredItem.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

struct AlfredItem: Codable {
    struct Icon: Codable {
        var type: String? = nil
        let path: String
    }
    let title: String
    let subtitle: String
    let arg: String
    var icon: Icon? = nil
    var mods: AlfredModifiers? = nil
    var quicklookurl: String? = nil
    
    
//    var quicklookurl: String = ""
}
