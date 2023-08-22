//
//  MainView.swift
//  Location Matchmaker
//
//  Created by Luca on 7/21/22.
//
import Combine
import SwiftUI
import FirebaseAuth

struct MainView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var showMatchMaker = false
    
    //For getting and updating location
    @StateObject var deviceLocationService = DeviceLocationService.shared
    @State var tokens: Set<AnyCancellable> = []
    @State var coordinates: (lat: Double, lon: Double) = (0, 0)
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    //For Writing Data
    @State var content: String = ""
    @StateObject var writeData = WriteUserLocationData()
    @State var safetyDupePrevention = true //used for preventing two coordinates from being input by a user at one timeframe
    
    //For Reading and Storing Data
    private let defaults = UserDefaults.standard
    @StateObject var readUserData = ReadUserLocationData()
    @State var tempUserList = [UserLocationData]()
    @State var matchesTable = [String: MatchesData]()
    @State var matchesList = [String]()
    
    @State var tempTime = ""
    @State var tempCoords = ""
    @State var tempLat = 0.0
    @State var tempLong = 0.0
    @State var tempLatForSearch = 0
    @State var tempLongForSearch = 0
    @State var timeKeyValue = 62
    @State var tempTimeKeyValue = 62
    @State var idleCheck1 = ""
    @State var idleCheck2 = ""
    @State var idle = false
    
    //For Testing
    @State var testName = ""
    @State var testTime = ""
    @State var testKey = ""
    @State var firstAppearance = true
    
    //For Deleting
    @StateObject var deleter = DeleteFirebaseItems()
    
    var body: some View {
        NavigationView{
            VStack{
                Spacer()
                Spacer().onReceive(timer){ time in
                    if getTime()[1] == "M" {
                        timeKeyValue = (Int(getTime()[5] + getTime()[4])) ?? 2
                        }else{
                            timeKeyValue = (Int(getTime()[2] + getTime()[1])) ?? 2
                        }
                    if (timeKeyValue % 3 == 0) && (safetyDupePrevention == true) {
                        processWrite()
                    }
                   
                    //Start reading 1 minute after each write
                    if (timeKeyValue % 3 == 1)  && (tempCoords != ""){
                        safetyDupePrevention = true
                        if !idle{
                            readAllNineBoxes(0, 0)
                            //DispatchQueue is weird hence why this isn't just a function
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10){
                                readAllNineBoxes(1, 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 20){
                                readAllNineBoxes(-1, 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 30){
                                readAllNineBoxes(0, 1)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 40){
                                readAllNineBoxes(0, -1)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 50){
                                readAllNineBoxes(1, 1)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 60){
                                readAllNineBoxes(1, -1)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 70){
                                readAllNineBoxes(-1, 1)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 80){
                                readAllNineBoxes(-1, -1)
                            }
                            saveUserList()
                        }
                    }
                }
                
                TextField("", text: $content).frame(width: 300.0, height: 60.0).background(Color.white).font(.system(size: 24)).multilineTextAlignment(.center).submitLabel(.done).foregroundColor(.black).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray)).cornerRadius(8).overlay(
                    Text("Enter your name").foregroundColor(.gray).opacity(content.isEmpty ? 1 : 0)
                )
                Spacer()
                Button{saveName()} label:{ Text("Set Username")}
                    .padding(.horizontal).padding(.vertical).background(Color.red).foregroundColor(.white).bold().cornerRadius(8)

                VStack{
                    NavigationLink{MatchMakerView()} label: {Text("View Matches")}.padding(.horizontal).padding(.vertical).background(Color.red).foregroundColor(.white).bold().cornerRadius(8)
                    Button{
                        signOut()
                        presentationMode.wrappedValue.dismiss()
                    } label:{ Text("Sign Out")}
                        .padding(.top)

                }
                Spacer()
                Spacer()
                
            }
            
            }
        .onAppear {
            observeCoordinateUpdates()
            observeLocationAccessDenied()
            deviceLocationService.requestLocationUpdates()

            loadName()
            loadUserList()
            loadTempUserList()
            updateListsFromTemp()
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ChildViewDismissed"), object: nil, queue: nil) { _ in
                loadName()
                loadUserList()
                loadTempUserList()
                updateListsFromTemp()
                }
        }.navigationBarBackButtonHidden(true).onDisappear {
            saveUserList()
        }
    }
    
    func updateListsFromTemp() {
        //probably a good idea for latitude/longitude list to also include the time/data
        for user in tempUserList{
            processUserData(object: user)
        }
        tempUserList.removeAll()
        saveTempUserList()
        saveUserList()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func observeCoordinateUpdates(){
        deviceLocationService.coordinatesPublisher.receive(on: DispatchQueue.main)
            .sink { completion in
            if case .failure(let error) = completion{
                print(error)
            }
            } receiveValue: { coordinates in
                self.coordinates = (coordinates.latitude, coordinates.longitude)
                
    }
        .store(in: &tokens)
    }
    
    func observeLocationAccessDenied(){
        deviceLocationService.deniedLocationAccessPublisher
            .receive(on: DispatchQueue.main)
            .sink {
            }
            .store(in: &tokens)
    }
    
    func getTime() -> String{
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    func saveName(){
        defaults.set(content, forKey: "name")
    }
    func loadName(){
        let savedName = defaults.string(forKey: "name")
        content = savedName ?? ""
    }
    
    
    //functions to save and load temp user list
    func loadTempUserList() {
        if let data = UserDefaults.standard.data(forKey: "tempUserList"){
            do{
                let decoder = JSONDecoder()
                tempUserList = try decoder.decode([UserLocationData].self, from: data)
            }catch{
                print("Could not Decode Array")
            }
        }
    }
    
    func saveTempUserList() {
        
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(tempUserList)
            UserDefaults.standard.set(data, forKey: "tempUserList")
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
    
    func readAllNineBoxes(_ latAdd: Int, _ longAdd: Int){
        readUserData.readListObject((String(tempLatForSearch + latAdd) + String(tempLongForSearch + longAdd)), tempTimeKeyValue)
        for object in readUserData.dataList{
            tempUserList.append(object)
            if object.isIdle{
                writeData.pushIdle(idleUsername: object.name, lat: tempLat, long: tempLong, user: content, tim: tempTime, coords: tempCoords, timeKey: tempTimeKeyValue, idleness: idle)
            }
            processUserData(object: object)
        }
        saveTempUserList()
        readUserData.dataList.removeAll()
    }
    
    func readFromIdle(myName: String){
        readUserData.readListObjectIdle(myName)
        for object in readUserData.dataListIdle{
            tempUserList.append(object)
            processUserData(object: object)
        }
        saveTempUserList()
        readUserData.dataListIdle.removeAll()
        deleter.deleteIdle(name: myName)
    }
    
    func processWrite(){
        idleCheck2 = idleCheck1
        idleCheck1 = tempCoords
        tempTimeKeyValue = timeKeyValue
        tempLat = coordinates.lat
        tempLong = coordinates.lon
        tempLatForSearch = Int(round(tempLat * 1000))
        tempLongForSearch = Int(round(tempLong * 1000))
        tempTime = getTime()
        tempCoords = String(Int(round(tempLat * 1000)))+String(Int(round(tempLong * 1000)))
        if (tempCoords == idleCheck1) && (idleCheck1 == idleCheck2){
            //idle = true
        }else{idle = false}
        writeData.pushCoord(lat: tempLat, long: tempLong, user: content, tim: tempTime, coords: tempCoords, timeKey: tempTimeKeyValue, idleness: idle)
        safetyDupePrevention = false
        
        //Read from Idle (currently disabled) and delete
        if timeKeyValue % 15 == 0{
            readFromIdle(myName: content)
            //Deletion is currently client side due to pricing but should be changed to server side if possible
            deleter.scheduledDeletes(timeKey: timeKeyValue)
        }
    }
    
    func processUserData(object: UserLocationData){
        if matchesTable.keys.contains(object.name){
            matchesTable[object.name]?.mostRecentMatch = object.time
            matchesTable[object.name]?.coordList.append(Coordinates(object.Latitude, object.Longitude, object.time))
        } else {
            matchesTable[object.name] = MatchesData(object.time, object.time, object.name, object.Latitude, object.Longitude)
            matchesList.append(object.name)
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

//Extension allows strings to be indexed from back to front (used to verify times)
extension String{
    subscript(i: Int) -> String {
        return String(self[index(endIndex, offsetBy: -i)])
    }
}

 
