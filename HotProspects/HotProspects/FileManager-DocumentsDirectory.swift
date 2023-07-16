//
//  FileManager-DocumentsDirectory.swift
//  FaceName
//
//  Created by Berardino Chiarello on 06/07/23.
//

import Foundation

extension FileManager {
    static var documentDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
