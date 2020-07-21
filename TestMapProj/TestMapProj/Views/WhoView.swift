//
//  WhoView.swift
//  TestMapProj
//
//  Created by Cheremushka on 14.07.2020.
//  Copyright © 2020 Daria Cheremina. All rights reserved.
//

import SwiftUI

struct WhoView: View {
    @ObservedObject var anotationData : AnotationModel

    @Binding var saveData: Bool
    @State private var hide = false
    @State private var showWeightPicker = false
    @State private var showAgePicker = false
    @State private var showSexPicker = false
    @State private var showHobbyPicker = false
    @State private var showDurView = false
    
    @State private var selectedHobby = 0

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedObgectContext

    @State private var selectedWeight = 0
    @State private var showingAlert = false
    
    var body: some View {
            NavigationView {
                ZStack(alignment: .bottom) {
                    VStack(alignment: .center, spacing: 20) {
                        Spacer()
                        if (!self.saveData) {
                            if (self.showSexPicker || !self.hide) {
                                HStack {
                                    Text("Пол-").padding(.leading)
                                    Spacer()
                                    Button(action: {
                                        self.hide.toggle()
                                        self.showSexPicker.toggle()
                                    }, label: {
                                        if (self.anotationData.sex != -1) {
                                            Text("\(self.anotationData.sexes[self.anotationData.sex])").padding(.trailing).foregroundColor(.blue).font(.callout)
                                        } else {
                                            Image(systemName: "plus")
                                        }
                                    }).padding(.trailing)
                                }
                                Divider()
                            }
                            if (showAgePicker || !self.hide) {
                                HStack {
                                    Text("Возраст-").padding(.leading)
                                    Spacer()
                                    Button(action: {
                                        self.hide.toggle()
                                        self.showAgePicker.toggle()

                                    }, label: {
                                        if (self.anotationData.age != -1) {
                                            Text("\(self.anotationData.ages[self.anotationData.age])").padding(.trailing).foregroundColor(.blue).font(.callout)
                                        } else {
                                            Image(systemName: "plus")
                                            
                                        }
                                    }).padding(.trailing)
                                }
                                Divider()
                            }
                            if (showWeightPicker || !self.hide) {
                                HStack {
                                    Text("Вес-").padding(.leading)
                                    Spacer()
                                    Button(action: {
                                        self.showWeightPicker.toggle()
                                        self.hide.toggle()
                                    }, label: {
                                        if (self.anotationData.weight != -1) {
                                            Text("\(self.anotationData.weights[self.anotationData.weight])").padding(.trailing).foregroundColor(.blue).font(.callout)
                                        } else {
                                            Image(systemName: "plus")
                                        }
                                    }).padding(.trailing)
                                }
                                Divider()
                            }
                            if (!self.hide) {
                                Form {
                                    Section {
                                        Picker(selection: self.$anotationData.hobby, label: Text("Интересы-")) {
                                            ForEach(0 ..< self.anotationData.hobbies.count) {
                                                Text(self.anotationData.hobbies[$0])
                                            }
                                        }
                                    }
                                }.onAppear {
                                   UITableView.appearance().backgroundColor = .white
                                }
                            }
                            Spacer()
                            if (self.hide) {
                                if (self.showWeightPicker) {
                                        Picker(selection: self.$anotationData.weight, label: Text("")) {
                                           ForEach(0 ..< self.anotationData.weights.count) {
                                              Text(self.anotationData.weights[$0])
                                           }
                                        }
                                    .frame(width: 300, height: 100, alignment: .center)
                                }

                                if (self.showSexPicker) {
                                        Picker(selection: self.$anotationData.sex, label: Text("")) {
                                           ForEach(0 ..< self.anotationData.sexes.count) {
                                              Text(self.anotationData.sexes[$0])
                                           }
                                        }
                                    .frame(width: 300, height: 100, alignment: .center)
                                }

                                if (self.showAgePicker) {
                                        Picker(selection: self.$anotationData.age, label: Text("")) {
                                           ForEach(0 ..< self.anotationData.ages.count) {
                                              Text(self.anotationData.ages[$0])
                                           }
                                        }
                                    .frame(width: 300, height: 100, alignment: .center)
                                }
                                Spacer()
                                Button(action: {
                                    self.hide.toggle()
                                    self.showSexPicker = false
                                    self.showAgePicker = false
                                    self.showHobbyPicker = false
                                    self.showWeightPicker = false
                               }, label: {
                                Image(systemName: "checkmark.circle.fill").font(.largeTitle)
                               })
                            }
                            if (!hide) {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        self.showDurView.toggle()
                                        if self.anotationData.sex == -1 || self.anotationData.hobby == -1 || self.anotationData.weight == -1 || self.anotationData.age == -1 { self.showingAlert.toggle() }
                                    }) {
                                        Image(systemName: "arrow.right")
                                    }.sheet(isPresented: self.$showDurView, content: { DurationView(saveData: self.$saveData, anotationData: self.anotationData).environment(\.managedObjectContext, self.managedObgectContext)})
                                        .alert(isPresented: $showingAlert) {
                                            Alert(title: Text("Для размещения необходима полная информация"), message: Text("Заполни все поля"), dismissButton: .default(Text("ОК")))
                                        }
                                    .padding()
                                    .background(Color.black.opacity(0.85))
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .clipShape(Circle())
                                    .padding(.trailing)
                                }
                            }
                        } else {
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                                self.saveData = false
                                self.clearData(anotationData: self.anotationData)
                            }) {
                                Text("Готово")
                            }.padding(.bottom, UIScreen.main.bounds.height/2)
                        }
                    }
                }
                .navigationBarTitle("Выбери параметры для размещения", displayMode: .inline)
            }
    }
    
    func clearData(anotationData: AnotationModel) {
        anotationData.adress = ""
        anotationData.sex = -1
        anotationData.age = -1
        anotationData.hobby = -1
        anotationData.weight = -1
        anotationData.duration = ""
        anotationData.saveData = false
    }
}
