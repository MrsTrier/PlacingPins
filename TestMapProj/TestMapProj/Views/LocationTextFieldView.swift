//
//  LocationTextField.swift
//  TestMapProj
//
//  Created by Cheremushka on 13.07.2020.
//  Copyright © 2020 Daria Cheremina. All rights reserved.
//

import SwiftUI
import MapKit

struct LocationTextFieldView: View {
    
    @ObservedObject var locationSearchService: LocationSearchService
    @ObservedObject var anotationData : AnotationModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    @Binding var locationTitle: String
    private let completer = MKLocalSearchCompleter()

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $locationSearchService.searchQuery)
                List(locationSearchService.completions) { completion in
                    Button(action: {
                        self.anotationData.adress = completion.title
                        self.convertAddressToCoords(adress: completion.subtitle)
                        self.presentationMode.wrappedValue.dismiss()
                    })
                    {
                        VStack(alignment: .leading) {
                            Text(completion.title)
                            Text(completion.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }.navigationBarTitle("Набери адрес для размещения", displayMode: .inline)
        }
        
    }
    
    func convertAddressToCoords(adress: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adress) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            if (lat != nil) && (lon != nil) {
                self.anotationData.latitude = lat!
                self.anotationData.longitude = lon!
            } else {
                if placemark == nil {
                    self.anotationData.adress = ""
                }
            }
        }
    }
}

//struct LocationTextField_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationTextField()
//    }
//}
