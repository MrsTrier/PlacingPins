//
//  ContentView.swift
//  TestMapProj
//
//  Created by Cheremushka on 11.07.2020.
//  Copyright © 2020 Daria Cheremina. All rights reserved.
//

import MapKit
import Network
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var locationManager = LocationManager()
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var pastCenterCoordinate = CLLocationCoordinate2D()
    @State private var locations = [MKPointAnnotation]()
    @State private var selectedPlace : MKPointAnnotation?

    @State private var removeAnnotations = [MKPointAnnotation]()
    @ObservedObject var anotationData = AnotationModel()
    
    @State var showingPlaceDetails = false

    @Environment(\.managedObjectContext) var managedObgectContext
    
    @FetchRequest(entity: Ad.entity(),
                  sortDescriptors: [
    ]) var ads: FetchedResults<Ad>
    let locationSearchService = LocationSearchService()

    @State private var showLocationTF = false
    @State private var showWhoView = false
    @State private var showingAlert = false
    @State private var wifiAlert = false
    @State private var showAllAnotations = false

    
    var body: some View {
        ZStack {
            MapView(annotations: locations, removeAnnotations: $removeAnnotations, selectedPlace: $selectedPlace, centerCoordinate: $centerCoordinate, pastCenterCoordinate: $pastCenterCoordinate, showingPlaceDetails: $showingPlaceDetails, allAnotations: self.$showAllAnotations).edgesIgnoringSafeArea(.all)
            if  !self.showAllAnotations {
                Button(action: {
                    let newLocation = MKPointAnnotation()
                    newLocation.coordinate = self.centerCoordinate
                    self.pastCenterCoordinate = self.centerCoordinate
                    self.anotationData.latitude = self.pastCenterCoordinate.latitude
                    self.anotationData.longitude = self.pastCenterCoordinate.longitude
                    self.convertCoordsToAddress(latitude: self.pastCenterCoordinate.latitude, longitude: self.pastCenterCoordinate.longitude) { (adress) in self.anotationData.adress = adress
                        if self.anotationData.adress == "" {
                            self.wifiAlert = true
                        }
                    }
                    self.locations.append(newLocation)
                    if self.locations.count == 2 {
                        self.removeAnnotations.append(self.locations[0])
                        self.locations.remove(at: 0)
                    }
                }) { Image(systemName: "mappin.circle.fill").font(.largeTitle).foregroundColor(.red) }
                    .alert(isPresented: $wifiAlert) {
                        Alert(title: Text("Отсутствует подключение к интернету"), message: Text("Проверьте подключение к WI-FI"), dismissButton: .default(Text("OK")))
                    }
                VStack {
                    Text("Хочешь сделать размещение по адресу - \(self.anotationData.adress)").padding().background(SwiftUI.Color.white).cornerRadius(15).padding(.all)
                    Spacer()

                    HStack {
                        Button(action: {
                            self.showAllAnotations.toggle()
                            self.removeAnnotations = self.locations
                            self.locations.removeAll()
                            for ad in self.ads {
                                let newLocation = MKPointAnnotation()
                                newLocation.coordinate.latitude = ad.latitude
                                newLocation.coordinate.longitude = ad.longitude
                                newLocation.title = ad.sex
                                newLocation.subtitle = """
                                Цель: \(String(describing: ad.hobby!))
                                Вес: \(String(describing: ad.weight!)) Возраст: \(String(describing: ad.age!))
                                Размещено на \(String(describing: ad.duration)) час(а)
                                """
                                self.locations.append(newLocation)
                            }
                        }) { Text("Мои размещения") }
                        .padding()
                        .background(Color.black.opacity(0.50))
                        .foregroundColor(.white)
                            .clipShape(Capsule())
                        .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            let newLocation = MKPointAnnotation()
                            newLocation.coordinate = self.locationManager.location!.coordinate
                            self.selectedPlace?.coordinate = self.locationManager.location!.coordinate
                            self.pastCenterCoordinate = self.locationManager.location!.coordinate
                            self.anotationData.latitude = self.pastCenterCoordinate.latitude
                            self.anotationData.longitude = self.pastCenterCoordinate.longitude
                            self.convertCoordsToAddress(latitude: self.locationManager.location!.coordinate.latitude, longitude:   self.locationManager.location!.coordinate.longitude) { (adress) in self.anotationData.adress = adress }
                            self.locations.append(newLocation)
                            if self.locations.count == 2 {
                                self.removeAnnotations.append(self.locations[0])
                                self.locations.remove(at: 0)
                            }
                        }) { Image(systemName: "location.fill") }
                        .padding()
                        .background(Color.black.opacity(0.50))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        
                        Spacer()
                        
                        Button(action: {
                            self.showLocationTF.toggle()
                            self.showWhoView.toggle()
                        }) { Image(systemName: "questionmark") }
                            .sheet(isPresented: self.$showLocationTF, content: { LocationTextFieldView(locationSearchService: self.locationSearchService, locationTitle: self.$anotationData.adress) })
                        .padding()
                        .background(Color.black.opacity(0.50))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        Spacer()
                        Button(action: {
                            if self.anotationData.adress == "" {
                                self.showingAlert = true
                            } else {
                                self.showWhoView.toggle()
                            }
                        }) { Image(systemName: "arrow.right") }
                        .sheet(isPresented: self.$showWhoView, content: { WhoView(anotationData: self.anotationData, saveData: self.$anotationData.saveData).environment(\.managedObjectContext, self.managedObgectContext)})
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text("Для размещения необходим адрес"), message: Text("Найди место на карте и нажжми на кнопку в центре"), dismissButton: .default(Text("ОК")))
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
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showAllAnotations.toggle()
                            self.removeAnnotations = self.locations
                            self.locations.removeAll()
                        }) { Image(systemName: "plus") }.alert(isPresented: $showingPlaceDetails) {
                            Alert(title: Text(selectedPlace?.title ?? "Информация отсутствует"), message: Text(selectedPlace?.subtitle ?? "Информация отсутствует"), dismissButton: .default(Text("OK")))}
                        .padding()
                        .background(Color.black.opacity(0.85))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                    }
                }
            }
        }
    }
    
    func convertCoordsToAddress(latitude: Double, longitude: Double, completion: @escaping(String)->()) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        var address: String = ""

        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            let p = placemarks?[0]

            if let locationName = p?.name {
                address += locationName + ", "
            }
            if let city = p?.locality {
                address += city + ", "
            }
            if let country = p?.country {
                address += country
            }
            completion(address)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
