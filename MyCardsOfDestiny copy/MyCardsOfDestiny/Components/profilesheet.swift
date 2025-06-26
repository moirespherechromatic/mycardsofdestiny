import SwiftUI

struct ProfileSheet: View {
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var birthDate = Date()
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showDatePicker: Bool = true
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }
    
    private func isValidBirthdate(_ date: Date) -> Bool {
        return date <= Date()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.91, green: 0.82, blue: 0.63)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Profile")
                        .font(.custom("Apothicaire Light Cd", size: 36))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Name")
                            .font(.custom("Apothicaire Light Cd", size: 22))
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        
                        TextField("", text: $name)
                            .font(.custom("Apothicaire Light Cd", size: 20))
                            .fontWeight(.heavy)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.95, green: 0.90, blue: 0.78))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        Text("Birth Date")
                            .font(.custom("Apothicaire Light Cd", size: 22))
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        
                        Text(formattedDate)
                            .font(.custom("Apothicaire Light Cd", size: 20))
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.95, green: 0.90, blue: 0.78))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal, 50)
                        
                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.95, green: 0.90, blue: 0.78))
                            )
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button {
                        if isValidBirthdate(birthDate) {
                            if dataManager.updateProfile(name: name, birthDate: birthDate) {
                                dataManager.explorationDate = nil
                                presentationMode.wrappedValue.dismiss()
                            }
                        } else {
                            errorMessage = "Invalid birth date. Please check that the date is not in the future."
                            showingError = true
                        }
                    } label: {
                        Text("Save Changes")
                            .font(.custom("Apothicaire Light Cd", size: 19))
                            .fontWeight(.heavy)
                            .tracking(2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 18)
                            .background(AppTheme.darkAccent.opacity(0.7))
                            .cornerRadius(30)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationBarItems(
                trailing: Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            )
            .onAppear {
                name = dataManager.userProfile.name
                birthDate = dataManager.userProfile.birthDate
            }
            .alert("Invalid Birth Date", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct CalendarSheet: View {
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.91, green: 0.82, blue: 0.63)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Explore Date")
                        .font(.custom("Apothicaire Light Cd", size: 36))
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        Text("Select a date")
                            .font(.custom("Apothicaire Light Cd", size: 22))
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.95, green: 0.90, blue: 0.78))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        dataManager.explorationDate = selectedDate
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Show Cards for This Date")
                            .font(.custom("Apothicaire Light Cd", size: 19))
                            .fontWeight(.heavy)
                            .tracking(2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 18)
                            .background(AppTheme.darkAccent.opacity(0.7))
                            .cornerRadius(30)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationBarItems(
                trailing: Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            )
        }
    }
}

#Preview("Profile Sheet") {
    ProfileSheet()
}

#Preview("Calendar Sheet") {
    CalendarSheet()
}