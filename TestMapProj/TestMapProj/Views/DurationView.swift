//
//  DurationView.swift
//  TestMapProj
//
//  Created by Cheremushka on 16.07.2020.
//  Copyright © 2020 Daria Cheremina. All rights reserved.
//

import SwiftUI
import Combine

extension String: Identifiable {
  public var id: String { return self }
}

struct RadioButton: View {

    let id: String
    let callback: (String)->()
    let selectedID : String
    let size: CGFloat
    let color: Color
    let textSize: CGFloat

    init(
        _ id: String,
        callback: @escaping (String)->(),
        selectedID: String,
        size: CGFloat = 40,
        color: Color = Color.blue,
        textSize: CGFloat = 20
        ) {
        self.id = id
        self.size = size
        self.color = color
        self.textSize = textSize
        self.selectedID = selectedID
        self.callback = callback
    }

    var body: some View {
        Button(action:{
            self.callback(self.id)
        }) {
            HStack(alignment: .center, spacing: 50) {
                Image(systemName: self.selectedID == self.id ? "largecircle.fill.circle" : "circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.size, height: self.size)
                .foregroundColor(self.color)

                Text(id)
                    .font(Font.system(size: textSize))
                    .foregroundColor(.black)
                Spacer()
            }
        }
    }
}

struct RadioButtonGroup: View {

    let items : [String]

    @State var selectedId: String = ""

    let callback: (String) -> ()

    var body: some View {
        VStack {
            ForEach(0..<items.count) { index in
                RadioButton(self.items[index], callback: self.radioGroupCallback, selectedID: self.selectedId)
            }
        }.padding(33)
    }

    func radioGroupCallback(id: String) {
        selectedId = id
        callback(id)
    }
}

struct DurationView: View {

    @Environment(\.managedObjectContext) var managedObgectContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var saveData: Bool
    @State private var showingAlert = false
    @ObservedObject var anotationData : AnotationModel

    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("Выберите длительность").font(.title)
                HStack  {
                    Spacer()
                    RadioButtonGroup(items: ["1 час (100 рублей)", "2 часа (150 рублей)", "3 часа (200 рублей)"])
                    { selected in
                        self.anotationData.duration = selected
                    }
                    Spacer()
                }
                Button(action: {
                    if self.anotationData.duration == "" {
                        self.showingAlert = true
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                        let ad = Ad(context: self.managedObgectContext)
                        ad.age = self.anotationData.ages[self.anotationData.age]
                        ad.hobby = self.anotationData.hobbies[self.anotationData.hobby]
                        ad.latitude = self.anotationData.latitude
                        ad.longitude = self.anotationData.longitude
                        ad.weight = self.anotationData.weights[self.anotationData.weight]
                        ad.sex = self.anotationData.sexes[self.anotationData.sex]
                        ad.duration = Int32(Int(self.anotationData.duration.split(separator: " ")[0])!)
                        self.saveData = true
                    }
                }, label: {Text("Разместить")})
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Для размещения необходима полная информация"), message: Text("Выбери время, на которое ты хочешь создать размещение"), dismissButton: .default(Text("ОК")))
                }
            }
            .navigationBarTitle("Заверши размещение", displayMode: .inline)
        }
    }
}
