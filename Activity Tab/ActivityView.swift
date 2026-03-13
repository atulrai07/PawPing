//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//
import SwiftUI

struct ActivityView: View {
    var profile: DogProfile = DogProfile.sampleProfile
    
    var walkActivity: WalkActivity = WalkActivity(currentMinutes: 23, goalMinutes: 60)
    
    var meals: [Meals] = Meals.sampleMeals
    
    var vaccine : Vaccines = Vaccines.sampleVaccines
    
    //Allergies Model
    var allergy : [Allergy] = Allergy.sampleAllergies
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators:false) {
                ZStack {
                    // MARK: - Main Stack
                    VStack(spacing: 16) {
                        
                        // MARK: - Header
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("Hello \(profile.dogName)")
                                    .font(.system(size: 16))
                                    .bold()
                                    .foregroundStyle(Color("baseRed"))
                                
                                Text("\(profile.breed). \(profile.gender), \(profile.age) years")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            
                            Circle()
                                .fill(.gray.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(profile.dogImage)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(Circle())
                                        .frame(width: 64, height: 64)
                                )
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Walked Card
                        ZStack {
                            RoundedRectangle(cornerRadius: 34)
                                .fill(.gray.opacity(0.1))
                                .frame(width: 370, height: 160)
                            
                            HStack(spacing: 20) {
                                
                                CircularProgressView(progress: walkActivity.progress)
                                    .frame(width: 100, height: 100)
                                    .padding(.leading, 20)
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Walked")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color("baseRed"))
                                    
                                    Text("\(walkActivity.currentMinutes)/\(walkActivity.goalMinutes)min")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundStyle(.primary)
                                    
                                    Button {
                                        print("Start Walk tapped")
                                    } label: {
                                        Text("START")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(Color("baseRed"))
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .stroke(Color("baseRed"), lineWidth: 1.5)
                                            )
                                    }
                                    .padding(.top, 4)
                                }
                                Spacer()
                            }
                        }
                        .frame(height: 160)
                        .padding(.horizontal)
                        
                        // MARK: - Vaccine & Meals Row
                        HStack(spacing:16) {
                            ZStack{
                                RoundedRectangle(cornerRadius:34)
                                    .fill(.gray.opacity(0.1))
                                    .frame(width: 175, height:190)
                                VStack(alignment: .leading){
                                    HStack (spacing:15){
                                        Text("Upcoming")
                                            .font(.system(size: 22,weight: .regular))
                                        Button{
                                            
                                        }label: {
                                            Circle()
                                                .fill(Color("baseRed").opacity(0.2))
                                                .frame(width:22,height:22)
                                                .overlay(
                                                    Image(systemName: "chevron.right")
                                                        .foregroundStyle(.black)
                                                        .font(.system(size: 12))
                                                )
                                        }
                                    }
                                    Image(systemName: "syringe")
                                        .foregroundStyle(.baseRed)
                                        .rotationEffect(.degrees(270))
                                        .font(.system(size: 65))
                                    Text(vaccine.name)
                                        .font(.system(size: 18,weight: .medium))
                                    Text("\(vaccine.daysLeft) days left")
                                        .font(.system(size: 12,weight:.semibold))
                                }
                                .frame(height: 175)
                            }
                            //Meals Card
                            MealsCardView()
                        }
                        
                        // MARK: - Allergies Card
                        ZStack{
                            RoundedRectangle(cornerRadius: 23)
                                .fill(.gray.opacity(0.1))
                                .frame(width:370, height:95)
                            HStack(spacing:20){
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 250/255, green: 250/255, blue: 250/255))
                                    .frame(width: 78, height: 78)
                                    .overlay(
                                        Image("allergiesIcon")
                                            .resizable()
                                            .frame(width:66, height: 63)
                                    )
                                VStack(alignment:.leading, spacing: 10){
                                    HStack(spacing:130) {
                                        Text("Allergies")
                                            .font(.system(size: 24,weight: .regular))
                                            .padding(.top,5)
                                        Button{
                                            //workflow pending
                                        }label: {
                                            Circle()
                                                .fill(Color("baseRed").opacity(0.2))
                                                .frame(width:22,height:22)
                                                .overlay(
                                                    Image(systemName: "chevron.right")
                                                        .foregroundStyle(.black)
                                                        .font(.system(size: 12))
                                                )
                                        }
                                    }
                                    HStack {
                                        ForEach(allergy.prefix(3)) { allergies in
                                            ZStack{
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(.baseRed)
                                                    .frame(width:62, height:27)
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(Color(red: 250/255, green: 250/255, blue: 250/255))
                                                    .frame(width:60, height:25)
                                                    .overlay(
                                                        Text(allergies.allergen ?? "none")
                                                            .font(.system(size: 10,weight: .medium))
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Graph Card
                        WalkTimeGraphView()
                    }
                    .padding(.top)
                }
            }
            .background(Color("baseBackground"))
        }
        
    }
}

#Preview {
    ActivityView()
}
