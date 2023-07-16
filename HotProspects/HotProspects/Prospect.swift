//
//  Prospect.swift
//  HotProspects
//
//  Created by Berardino Chiarello on 15/07/23.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    //Mark this fileprivate(set) block us to toggle this bool outside this file. Is important because toggling this boolean directly not update the UI, we create toggle function with objectWillChange.send() to avoid this problem, so use that method to toggle this property
    fileprivate(set) var isContacted = false
    
}


@MainActor class Prospects: ObservableObject {
    
    @Published fileprivate(set) var people: [Prospect]

    static let saveKey = "SavedData"
    let saveURL = FileManager.documentDirectory.appendingPathComponent(saveKey)
    
    init() {
        //reading data from JSON in Document directory
        do{
            let data = try Data(contentsOf: saveURL)
            people = try JSONDecoder().decode([Prospect].self, from: data)
        } catch {
            //no saved data
            people = []
        }
    }
    
    private func save() {
        do {
            let data =  try JSONEncoder().encode(people)
            try data.write(to: saveURL, options: [.atomic, .completeFileProtection])

            } catch {
                print(error.localizedDescription)
            }
        }
        
        func add(_ prospect: Prospect){
            people.append(prospect)
            save()
        }
        
        func remove(_ prospect: Prospect){
            if let index = people.firstIndex(where: { prospect.id == $0.id }) {
                people.remove(at: index)
                save()
            }
        }
        
        func toggle(_ person: Prospect) {
            //telling SwiftUI our object is changing, in this case we are modifying an object inside the @Published property, SwiftUI can't see this change
            objectWillChange.send()
            person.isContacted.toggle()
            save()
        }
    }
