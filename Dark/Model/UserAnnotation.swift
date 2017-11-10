//
//  UserAnnotation.swift
//  Dark
//
//  Created by surendra kumar on 11/3/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation

class UserAnnotation :NSObject, MKAnnotation{
   
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var id : String?
    init(title : String , coordinate : CLLocationCoordinate2D, id : String){
        self.title = title
        self.coordinate = coordinate
        self.id = id
    }
}
