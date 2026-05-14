//
//  CampusResourcesView.swift
//  CampusWellApp
//
//  Created by isabel on 5/13/26.
//
// Isabel Morales worked on this code

import SwiftUI
struct CampusResource: Identifiable{
    var id = UUID()
    var title: String
    var detail: String
    var symbolName: String
    var url: URL?
    
}
struct CampusResourcesView: View {
    private let resources: [CampusResource] = [
        CampusResource(
            title: String(localized: "Counseling & Psychological Services"),
            detail: String(localized: "Talk with a counselor — confidential support for stress, anxiety, and more."),
            symbolName: "bubble.left.and.bubble.right.fill",
            url: URL(string: "https://psyservs.sfsu.edu")
        ),
        CampusResource(
            title: String(localized: "Student Health / Wellness Center"),
            detail: String(localized: "Medical care, flu shots, and wellness programs on campus."),
            symbolName: "cross.case.fill",
            url: URL(string: "https://health.sfsu.edu")
        ),
        CampusResource(
            title: String(localized: "Recreation & Gym"),
            detail: String(localized: "Lap pool, weights, group fitness — movement breaks between study blocks."),
            symbolName: "figure.run",
            url: URL(string: "https://campusrec.sfsu.edu")
        ),
        CampusResource(
            title: String(localized: "Academic support"),
            detail: String(localized: "Tutoring, writing center, and accessibility services."),
            symbolName: "book.fill",
            url: URL(string: "https://tutoring.sfsu.edu")
        ),
        CampusResource(
            title: String(localized: "Crisis line & support"),
            detail: String(localized: "If you or someone else is in immediate danger, call campus police or 988."),
            symbolName: "phone.fill",
            url: URL(string: "https://caps.sfsu.edu/Emergencies/Emergencies")
        ),
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    ForEach(resources) { item in
                        WellnessCard {
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: item.symbolName)
                                    .font(.title2)
                                    .foregroundStyle(WellnessTheme.softPurple)
                                    .frame(width: 36)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.title)
                                        .font(.headline)
                                        .foregroundStyle(WellnessTheme.deepBlue)
                                    Text(item.detail)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    if let url = item.url {
                                        Link(destination: url) {
                                            Text(String(localized: "Open resource"))
                                                .font(.subheadline.weight(.semibold))
                                        }
                                        .padding(.top, 4)
                                        .tint(WellnessTheme.calmBlue)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(WellnessTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle(String(localized: "Campus"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
#Preview {
    CampusResourcesView()
}
