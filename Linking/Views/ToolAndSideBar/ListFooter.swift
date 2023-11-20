//
//  ListFooter.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import SwiftUI

struct ListFooter: View {
    @Binding var isEdit: Bool
    @EnvironmentObject var groupVM: GroupViewModel
    @State private var isMailOn: Bool = true
    @State private var isAppOn: Bool = true
    @EnvironmentObject var notificationVM : NotificationViewModel
    @State private var showPopUp: Bool = false
    
    var body: some View {
        HStack(alignment: .bottom){
            Spacer()
           
            changeOrderGroupAndPageBtn
            
            settingNotiBtn
            
        }.padding([.top, .bottom, .trailing])
            .background(Color.lightBeige)
            .onAppear(perform: {
            DispatchQueue.main.async {
                notificationVM.readAppPushSettings()
                isAppOn = notificationVM.setting.allowedWebAppPush
                isMailOn = notificationVM.setting.allowedMail
            }
        })
    }
}

extension ListFooter {
    
    var changeOrderGroupAndPageBtn: some View {
        Button(action: {
            isEdit.toggle()
            if !isEdit {
                //send
                groupVM.changeOrderGroupAndPage()
            }
        }, label: {
            if !isEdit{
                Image(systemName: "arrow.up.and.down.text.horizontal")
                    .foregroundColor(.linkingGray)
                    .font(.system(size:17))
            }
            else {
                Text("Done")
                    .foregroundColor(.linkingGray)
                    .font(.system(size:17))
            }
        }).padding(.trailing).buttonStyle(.borderless)
    }
    
    var settingNotiBtn: some View {
        Button(action: {
                showPopUp = true
        }, label: {
            Image(systemName: "gearshape")
                .foregroundColor(.linkingGray)
                .font(.system(size:17))
        }).buttonStyle(.borderless).popover(isPresented: $showPopUp, arrowEdge: .leading, content: {
            popUp().background(Color.white)
        })
    }
    func popUp() -> some View {
        VStack{
            Spacer()
            Text("알림 환경 설정")
                .font(.body)
                .foregroundColor(.linkingLightGray)
           
            Spacer()
            
                Toggle(isOn: $isMailOn) {
                    Text("메일 알림")
                        .font(.body)
                        .foregroundColor(.linkingGray)
                }.toggleStyle(.switch).onChange(of: isMailOn) {
                    value in
                    updateSettings()
                }.tint(Color.linkingGreen)
            
                Toggle(isOn: $isAppOn) {
                    Text("앱 알림   ")
                        .font(.body)
                        .foregroundColor(.linkingGray)
                }.toggleStyle(.switch).onChange(of: isAppOn) {
                    value in
                    updateSettings()
                   
                }.tint(Color.linkingGreen)
            
            Spacer()
            
        }.frame(width: 200, height: 150)
    }
    
    func updateSettings(){
        notificationVM.updateAppPushSettings(allowedWebAppPush: isAppOn, allowedMail: isMailOn)
    }
}

struct ListFooter_Previews: PreviewProvider {
    @State static var isEdit: Bool = false
    static var previews: some View {
        ListFooter(isEdit: $isEdit)
    }
}
