//
//  Anotation.swift
//  TestMapProj
//
//  Created by Cheremushka on 14.07.2020.
//  Copyright © 2020 Daria Cheremina. All rights reserved.
//

import Combine

final class AnotationModel: ObservableObject {
    
    @Published var weights = ["Не выбрано", "50-55", "55-60", "60-70", "70-80", "80-90", "90-100"]
    @Published var ages = ["Не выбрано", "18+", "18-20", "20-25", "25-35", "30-40", "40-50", "50-55", "55-60", "60-70", "70-80", "80-90", "90-100"]
    @Published var sexes = ["Не выбрано", "Женщина", "Мужчина", "Небинарный"]
    @Published var hobbies = ["Почитать книгу", "Посмотреть кино", "Помочь по дому", "Прогулка", "Сходить в магазин", "Другое"]

    @Published var adress = String()
    @Published var sex = -1
    @Published var age = -1
    @Published var hobby = -1
    @Published var weight = -1
    @Published var longitude = Double()
    @Published var latitude = Double()
    @Published var duration = String()

    @Published var saveData = false

}
