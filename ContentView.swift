//
//  ContentView.swift
//  ChatApp
//
//  Created by Sean Kang on 2020/09/13.
//  Copyright © 2020 myname. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @State var name = ""
    
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Color.black
                
                VStack {
                    Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                        .padding(.top, 12)
                    
                    TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    
                    // To MessagePage
                    NavigationLink(destination: MessagePage(name: self.name)) {
                        HStack {
                            Text("Join")
                            Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            
                        }
                    }.frame(width: 100, height: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                    .cornerRadius(20)
                        .padding(.bottom, 15)
                }.background(Color.white)
                .cornerRadius(20)
                .padding()
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MessagePage: View {
    
    
    var name = ""
    @ObservedObject var message = observer()
    @State var typedMessage = ""
    
    var body: some View {
        
        VStack{
            List(message.messages) {i in
                Text(i.msg)
            }.navigationBarTitle("Chats",displayMode:.large)
            
            HStack {
                TextField("message", text: $typedMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    self.message.addMessage(msg: self.typedMessage, user: self.name)
                    self.typedMessage = ""
                }) {
                    Text("Send")
                }
            }.padding()
        }
        

    }
}

class observer: ObservableObject {
    @Published var messages = [dataType]()
    
    init() {
        let db = Firestore.firestore()
        db.collection("msg").addSnapshotListener { (snap, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            for i in snap!.documentChanges {
                if i.type == .added {
                    let name = i.document.get("name") as! String
                    
                     let message = i.document.get("msg") as! String
                    
                     let id = i.document.documentID
                    
                    self.messages.append(dataType(id: id, name: name, msg: message))
                }
            }
        }
    }
    
    func addMessage(msg : String, user : String) {
        
        let db = Firestore.firestore()
        
        db.collection("messages").addDocument(data: ["msg": msg,"name": user]) { (err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            print("Success")
        }
    }
}

struct dataType: Identifiable {
    var id: String
    var name : String
    var msg: String
}
