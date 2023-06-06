//
//  ContentView.swift
//  speedTracker
//
//  Created by Hojin Moon on 6/6/23.
//
import MapKit
import SwiftUI
import CoreLocation

struct ContentView: View {
    @ObservedObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $viewModel.region,
                interactionModes: .all,
                showsUserLocation: true)
                .ignoresSafeArea()
            
            Text("Speed: \(viewModel.speed, specifier: "%.2f") m/s")
                .font(.title)
                .padding()
        }
        .onAppear {
            viewModel.checkIfLocationServicesIsEnabled()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    @Published var userLocation: CLLocation?
    @Published var speed: CLLocationSpeed = 0.0

    var locationManager: CLLocationManager?

    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.startUpdatingLocation()
        } else {
            print("Location Services Not Available By User")
        }
    }

    private func setupRegionWithUserLocation(_ location: CLLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        region = MKCoordinateRegion(center: location.coordinate, span: span)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        setupRegionWithUserLocation(location)
        
        if location.speed >= 0 {
            speed = location.speed
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your Location is Restricted")
        case .denied:
            print("You denied permission to use your location. Please go into the settings app to allow location for the app's operation to continue")
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = locationManager.location {
                userLocation = location
                _ = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                setupRegionWithUserLocation(location)
                locationManager.startUpdatingLocation()
            } else {
                locationManager.requestLocation()
            }
        @unknown default:
            break
        }
    }
}
