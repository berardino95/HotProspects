//
//  ProscetsView.swift
//  HotProspects
//
//  Created by Berardino Chiarello on 15/07/23.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    enum SortType {
        case name, date
    }
    
    let filter : FilterType
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var showAlertNotification = false
    @State private var showSortingOption = false
    @State private var sortOrder = SortType.date
    
    var body: some View {
        NavigationView {
            List {
                ForEach (filteredProspects) { prospect in
                    HStack{
                        VStack(alignment: .leading){
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        
                        if prospect.isContacted && filter == .none {
                            Spacer()
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .foregroundColor(.green)
                                .font(.title)
                        }
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)

                        } else {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.badge.checkmark")
                            }
                            .tint(.green)
                            
                            Button {
                                addNotification(for: prospect)
                            } label: {
                                Label("Remind me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                    .swipeActions (edge: .leading) {
                        Button {
                            prospects.remove(prospect)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                        .tint(.red)
                    }
                }
            }
                .navigationTitle(title)
                .toolbar {
                    
                    Button {
                        showSortingOption = true
                    } label: {
                        Label("Change order", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr],
                                    simulatedData: "Paul Hudson\nemail@yoursite.com",
                                    completion: handleScan)
                }
                .alert("Turn on notification", isPresented: $showAlertNotification) {
                    Button ("Ok", role: .cancel) {  }
                } message: {
                    Text("Go to Settings -> Notification -> HotPrespects and enable notifications")
                }
                .confirmationDialog("Change list order", isPresented: $showSortingOption) {
                    Button("Name") { sortOrder = .name }
                    Button("Date of adding") { sortOrder = .date }
                    Button("Cancel", role: .destructive) { }
                } message: {
                    Text("Order prospects by:")
                }
        }
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        let result : [Prospect]
        
        switch filter {
        case .none:
            result =  prospects.people
        case .contacted:
            result = prospects.people.filter{$0.isContacted}
        case .uncontacted:
            result = prospects.people.filter{!$0.isContacted }
        }
        
        if sortOrder == .name {
            return result.sorted{ $0.name < $1.name }
        } else {
            return result.reversed()
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.add(person)
            
        case .failure(let error):
            print("Scanning failure: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        
        //Closure to use after the authorization
        let addRequest = {
            //setting notification info
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            //setting trigger for notification
            var dateComponents = DateComponents()
            dateComponents.hour = 9
//          let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            //for testing setting interval to 5 second
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        //Checking notification authorization
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        showAlertNotification = true
                        print("Notification are not enabled")
                    }
                }
            }
        }
        
    }
    
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
