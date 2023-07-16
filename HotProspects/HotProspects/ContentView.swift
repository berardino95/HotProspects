//
//  ContentView.swift
//  HotProspects
//
//  Created by Berardino Chiarello on 15/07/23.
//

import SwiftUI

struct ContentView: View {
    
    enum SelectedTab: Int, Hashable {
        case everyone, contacted, uncontacted, me
    }
    
    @StateObject var prospects = Prospects()
    
    //Save selectedTab to user defaults
    @AppStorage("SelectedTab") private var selectedTab = SelectedTab.everyone.rawValue
    
    var body: some View {
        TabView (selection: $selectedTab){
            ProspectsView(filter: .none)
                .tabItem {
                    Label("Everyone", systemImage: "person.3")
                }
                .tag(SelectedTab.everyone.rawValue)
            
            ProspectsView(filter: .contacted)
                .tabItem {
                    Label("Contacted", systemImage: "checkmark.circle")
                }
                .tag(SelectedTab.contacted.rawValue)
            
            ProspectsView(filter: .uncontacted)
                .tabItem {
                    Label("Uncontacted", systemImage: "questionmark.diamond")
                }
                .tag(SelectedTab.uncontacted.rawValue)
            
            MeView()
                .tabItem {
                    Label("Me", systemImage: "person.crop.square")
                }
                .tag(SelectedTab.me.rawValue)
        }
        .environmentObject(prospects)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
