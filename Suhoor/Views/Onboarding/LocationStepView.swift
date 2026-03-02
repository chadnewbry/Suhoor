import SwiftUI

struct LocationStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            Image(systemName: "location.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.suhoorGold)

            Text("Your Location")
                .font(.title.weight(.bold))
                .foregroundStyle(Color.suhoorTextPrimary)

            Text("We need your location to calculate accurate\nprayer times and fasting schedule.")
                .font(.subheadline)
                .foregroundStyle(Color.suhoorTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Detected location
            if let location = vm.selectedLocation {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.suhoorSuccess)
                    Text(location.name ?? "Location set")
                        .foregroundStyle(Color.suhoorTextPrimary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.suhoorSurface))
                .padding(.horizontal, 32)
            }

            if vm.selectedLocation == nil {
                // Auto-detect button
                if vm.locationService.authorizationState == .notDetermined ||
                   vm.locationService.authorizationState == .authorized {
                    OnboardingButton(title: vm.locationService.isLocating ? "Detecting..." : "Use My Location") {
                        if vm.locationService.authorizationState == .notDetermined {
                            vm.requestLocation()
                        } else {
                            vm.locationService.detectLocation()
                        }
                    }
                    .disabled(vm.locationService.isLocating)
                }

                // Divider
                HStack {
                    Rectangle().fill(Color.suhoorDivider).frame(height: 1)
                    Text("or search manually")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                    Rectangle().fill(Color.suhoorDivider).frame(height: 1)
                }
                .padding(.horizontal, 32)

                // City search
                HStack {
                    TextField("Search city...", text: $vm.citySearchText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(Color.suhoorTextPrimary)
                        .onSubmit {
                            Task { await vm.searchCity() }
                        }

                    if vm.isSearching {
                        ProgressView()
                            .tint(Color.suhoorGold)
                    } else {
                        Button {
                            Task { await vm.searchCity() }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.suhoorGold)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.suhoorSurface))
                .padding(.horizontal, 32)
            }

            Spacer()

            // Listen for auto-detect completion
            if vm.selectedLocation == nil && vm.locationService.detectedLocationData != nil {
                Color.clear.onAppear {
                    vm.useDetectedLocation()
                }
            }

            OnboardingButton(title: "Continue", isEnabled: vm.selectedLocation != nil) {
                vm.advance()
            }

            OnboardingSecondaryButton(title: "Skip for now") {
                vm.advance()
            }

            Spacer().frame(height: 20)
        }
    }
}
