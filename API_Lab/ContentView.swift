//
//  ContentView.swift
//  apiapp
//
//  Created by KIRSTEN Markley on 4/15/24.
//

import SwiftUI
// API url  https://api.github.com/search/users?q=greg

// Both structs use Codable so that we can passs them to the JSON Decord to decode the JSON response string back into the structs

// Structs will contain the information returned from the JSON
// NOTE that the variable names have to be exactly like in the JSON file

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
    @State var alertResponse: AlertResponse?
    @State var searchText = ""
    
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
                    List(alertResponse?.areas.sorted(by: { $0.key < $1.key }) ?? [], id: \.key) { state, count in
                        NavigationLink(destination: AlertDetailsView(state: state, count: count)) {
                            VStack(alignment: .leading) {
                                Text((state))                           
                            }
                        }
                    }
                }
            }
            .navigationTitle("Alerts by State")
            .searchable(text: $searchText)
        }
    }
    
    func getUsers() {
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
