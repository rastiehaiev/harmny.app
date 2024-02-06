//
//  ActivitiesView.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 02.01.2024.
//

import SwiftUI

struct ActivitiesView: View {
    @EnvironmentObject var activitiesViewModel: ActivitiesViewModel
    
    @State private var showAlert = false
    
    var body: some View {
        switch activitiesViewModel.state {
        case .unauthenticated:
            Text("Please open your IPhone app and sign in from there in order to list your activities.")
        case .failedToLoad(let errorMessage):
            NavigationView {
                Text(errorMessage)
                VStack{}
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }
            }
        case .loading:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5, anchor: .center)
        case .loaded(let activities):
            NavigationView {
                VStack {
                    if (activities.isEmpty) {
                        Text("You have no activities yet.")
                    } else {
                        activitiesList(activities, activitiesViewModel)
                    }
                }
                .navigationTitle("Activities")
            }
        }
    }
}

struct ActivityTreeView: View {
    @ObservedObject var activity: ActivityObservable
    let activitiesViewModel: ActivitiesViewModel
    
    init(_ activity: ActivityObservable, _ activitiesViewModel: ActivitiesViewModel) {
        self.activity = activity
        self.activitiesViewModel = activitiesViewModel
    }
    
    var body: some View {
        if activity.group {
            if (activity.childActivities != nil) {
                activitiesList(activity.childActivities!, activitiesViewModel)
                    .navigationTitle(activity.name)
            } else {
                Text("Activity group is empty")
            }
        } else if (!activity.group) {
            let activityViewModel = ActivityViewModel(activity)
            ActivityView(activityViewModel, activitiesViewModel)
                .navigationTitle(activity.name)
        }
    }
}

private func activitiesList(_ activities: [ActivityObservable], _ activitiesViewModel: ActivitiesViewModel) -> some View {
    List {
        ForEach(activities, id: \.id) { activity in
            let icon = getIconImageName(activity)
            let color = getIconColor(activity)
            NavigationLink(destination: ActivityTreeView(activity, activitiesViewModel)) {
                Image(systemName: icon).foregroundColor(color)
                Text(activity.name)
            }
        }
    }
}

private func getIconImageName(_ activity: ActivityObservable) -> String {
    if activity.group {
        if activity.childActivities?.isEmpty != false {
            return "folder"
        } else {
            return "folder.fill"
        }
    } else {
        return "figure.run"
    }
}

private func getIconColor(_ activity: ActivityObservable) -> Color {
    if activity.currentRepetitionId != nil {
        return .orange
    } else if activity.group {
        return .teal
    } else {
        return .indigo
    }
}
