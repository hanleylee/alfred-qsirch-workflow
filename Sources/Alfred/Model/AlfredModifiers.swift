//
//  AlfredModifiers.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/24.
//

struct AlfredModifiers: Codable {
    var cmd: AlfredMod? = nil
    var alt: AlfredMod? = nil
    var ctrl: AlfredMod? = nil
    var shift: AlfredMod? = nil
}
