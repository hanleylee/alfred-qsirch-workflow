//
//  AlfredItem.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

struct AlfredItem: Codable {
    struct Icon: Codable {
        let path: String
    }
    let title: String
    let subtitle: String
    let arg: String
    let icon: Icon
    var mods: AlfredModifiers? = nil
    var quicklookurl: String? = nil
    
    
//    var quicklookurl: String = ""
}
