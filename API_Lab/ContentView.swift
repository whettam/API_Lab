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

//indivisual User from the json
struct Weather: Codable {
    public var areas: String
    public var regions: String
    public var dictionary: String
}
// the items array from the JSON
struct Result: Codable {
    var items:[Weather]
}

struct ContentView: View {
    @State var states:[Weather] = []
    @State var searchText = ""
    var body: some View {
        NavigationStack{
            if states.count == 0 && !searchText.isEmpty{
                //display a progress spinning wheel if no data has been pulled yet
                VStack{
                    ProgressView().padding()
                    Text("Fetching Users...")
                        .foregroundStyle(Color.purple)
                        .onAppear{
                            getUsers()
                        }
                }
            } else {
                // bind the list to the User array
                List(states, id: \.areas) {state in
                    // links to their github profile using Safari
                    Link(destination:URL(string:state.areas)!){
                        VStack {
                            Text("Alerts in State:" + state.areas)
                        }
                    }
                }
            }
        }.searchable(text:$searchText)
            .onSubmit(of: .search){
                getUsers()
            }
    }
    
    // fetches the Users from the github api
    
    func getUsers(){
        // Add Search content
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Proceed only if searchText is not empty or just whitespace
        guard !trimmedSearchText.isEmpty else {
            return
        }
        if let apiURL = URL(string: "https://api.weather.gov/alerts/active/count") {
            let task = URLSession.shared.dataTask(with: apiURL) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let dictionary = json as? [String: Any] {
                                // Handle the JSON data here (e.g., extract relevant information)
                                print(dictionary)
                            }
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                        }
                    } else {
                        print("HTTP status code: \(response.statusCode)")
                    }
                }
            }
            task.resume()
        }
    }
}


#Preview {
    ContentView()
}
