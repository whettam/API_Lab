//
//  ContentView.swift
//  apiapp
//
//  Created by KIRSTEN Markley on 4/15/24.
//

import SwiftUI

// Structs will contain the information returned from the JSON
struct AlertResponse: Codable {
    var regions: [String: Int]
    var land: Int
    var zones: [String: Int]
    var areas: [String: Int]
    var total: Int
    var marine: Int
}

struct AlertDetailsView: View {
    let state: String
    let count: Int
    
    var body: some View {
        VStack {
            Text("Alerts in State: \(state)")
            Text("Count: \(count)")
        }
        .navigationTitle("Alert Details")
    }
}

struct ContentView: View {
    @State private var alertResponse: AlertResponse?
    @State private var searchText = ""
    
    private var filteredStates: [String] {
        guard let alertResponse = alertResponse else { return [] }
        
        if searchText.isEmpty {
            return alertResponse.areas.keys.sorted()
        } else {
            return alertResponse.areas.keys.sorted().filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if alertResponse == nil {
                    ProgressView()
                        .padding()
                        .onAppear {
                            getUsers()
                        }
                } else {
                    List(filteredStates, id: \.self) { state in
                        if let count = alertResponse?.areas[state] {
                            NavigationLink(destination: AlertDetailsView(state: state, count: count)) {
                                VStack(alignment: .leading) {
                                    Text(state)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Alerts by State")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("According to the National Weather Service")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.bottom,8)
                        }
                        Spacer()
                    }
                }
            }
            .searchable(text: $searchText)
        }
    }
    
    private func getUsers() {
        guard let apiURL = URL(string: "https://api.weather.gov/alerts/active/count") else { return }
        let task = URLSession.shared.dataTask(with: apiURL) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(AlertResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.alertResponse = response
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
