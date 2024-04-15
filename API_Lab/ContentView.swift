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
struct User: Codable {
    public var login: String
    public var url: String
    public var avatar_url:String
    public var html_url: String
}
// the items array from the JSON
struct Result: Codable {
    var items:[User]
}

struct ContentView: View {
    @State var users:[User] = []
    @State var searchText = ""
    var body: some View {
        NavigationStack{
            if users.count == 0 && !searchText.isEmpty{
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
                List(users, id:\.login) {user in
                    // links to their github profile using Safari
                    Link(destination:URL(string:user.html_url)!){
                        
                        
                        // diplay the image
                        HStack(alignment:.top){
                            AsyncImage(url:URL(string: user.avatar_url)){ response in
                                switch response {
                                case .success(let image):
                                    image.resizable()
                                        .frame(width:50, height: 50)
                                default:
                                    Image(systemName:"nosign")
                                }
                            }
                        }
                        
                        // display the user info
                        VStack(alignment: .leading){
                            Text(user.login)
                            Text("\(user.url)")
                                .font(.system(size:11))
                                .foregroundColor(Color.gray)
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
        if let apiURL = URL(string:"https://api.github.com/search/users?q=\(trimmedSearchText)"){
            var request = URLRequest(url:apiURL)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request){
                data, response,error in
                if let userData = data {
                    if let usersFromAPI = try? JSONDecoder().decode(Result.self, from: userData){
                        users = usersFromAPI.items
                        print(users)
                    }
                }
            }.resume()
        }
    }
}

#Preview {
    ContentView()
}
