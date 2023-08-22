//
//  MatchMakerView.swift
//  Location Matchmaker
//
//  Created by Luca on 8/3/22.
//

import SwiftUI

struct MatchMakerView: View {
    
    private let defaults = UserDefaults.standard
    @State var nameDisplay = ""
    @State var matchesTable = [String: MatchesData]()
    @State var matchesList = [String]()
    @State var index = 0

    
    var body: some View {
        VStack{
            Spacer()
            Spacer()
            
            HStack{
                
                Spacer()
                Button{
                    if index > 0 {
                        index -= 1
                        nameDisplay = matchesList[index]
                    }
                    updateSavedCoords()
                } label:{ Text(" < ")}
                    .padding(.horizontal).padding(.vertical).background(Color.blue).foregroundColor(.white).bold().cornerRadius(8)
                Spacer()
                Text(nameDisplay).frame(width: 200, height: 60.0).background(Color.white).font(.system(size: 20)).multilineTextAlignment(.center).submitLabel(.done).foregroundColor(.black).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray)).cornerRadius(8)
                Spacer()
                
                Button{
                    if index < matchesList.count - 1 {
                        index += 1
                        nameDisplay = matchesList[index]
                        updateSavedCoords()
                    }
                } label:{ Text(" > ")}
                    .padding(.horizontal).padding(.vertical).background(Color.blue).foregroundColor(.white).bold().cornerRadius(8)
                Spacer()
                
            }
            Spacer()
            Button{
                if !matchesList.isEmpty{
                    matchesTable.removeValue(forKey: matchesList[index])
                    matchesList.remove(at: index)
                    if index > matchesList.count - 1{
                        index = matchesList.count - 1
                    }
                    if matchesList.isEmpty{
                        nameDisplay = "No Matches Available"
                    } else {
                        nameDisplay = matchesList[index]
                    }
                    saveUserList()
                    updateSavedCoords()
                }
                
            } label:{ Text("Delete Match")}
                .padding(.horizontal).padding(.vertical).background(Color.red).foregroundColor(.white).bold().cornerRadius(8)
            Spacer()
            

            NavigationLink{MapView(indexNum: $index, name : $nameDisplay)} label: {Text("Open Map")}.padding(.horizontal).padding(.vertical).background(Color.green).foregroundColor(.white).bold().cornerRadius(8)
            Spacer()
            Spacer()
            
        }.onAppear{
            loadUserList()
            if !matchesList.isEmpty && index == 0 {
                nameDisplay = matchesList[0]
            } else if matchesList.isEmpty {
                nameDisplay = "No Matches Found"
            }
            updateSavedCoords()
        }.onDisappear{
            saveUserList()
            NotificationCenter.default.post(name: NSNotification.Name("ChildViewDismissed"), object: nil)
        }
    }
    
    func updateSavedCoords() {
        if matchesList.isEmpty {
            do{
                let encoder = JSONEncoder()
               // let data = try encoder.encode(userList)
                let data = try encoder.encode([Coordinates]())
                    UserDefaults.standard.set(data, forKey: "savedCoords")
            } catch{
                print("Unable to Encode Array")
            }
            return
        }
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(matchesTable[matchesList[index]]?.coordList)
                UserDefaults.standard.set(data, forKey: "savedCoords")
        } catch{
            print("Unable to Encode Array")
        }
    }
    
    func saveUserList(){
        defaults.set(matchesList, forKey:"MatchesList")
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(matchesTable)
                UserDefaults.standard.set(data, forKey: "SavedMatchData")
        } catch{
            print("Unable to Encode Array")
        }
    }
    
    func loadUserList(){
        let savedList = defaults.array(forKey: "MatchesList")
        if let tempList = savedList as? [String] {
            matchesList = tempList
        } else {
            matchesList = [String]()
        }
        if let data = UserDefaults.standard.data(forKey: "SavedMatchData"){
            do{
                let decoder = JSONDecoder()
                matchesTable = try decoder.decode([String: MatchesData].self, from: data)
            }catch{
                print("Could not Decode Array")
            }
        }
    }

    
}

struct MatchMakerView_Previews: PreviewProvider {
    static var previews: some View {
        MatchMakerView()
    }
}
