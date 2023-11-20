//
//  TodoStatusBtn.swift
//  Linking
//
//  Created by 윤겸지 on 2023/05/06.
//

import SwiftUI

struct TodoStatusBtn: View {
    var status: ToDoStatus
    var id: Int
    var teamTodoIndex : Int
    var assignIndex : Int
    var childIndex : Int
    var userId : Int
    var date : Date
    @EnvironmentObject var todoVM : ToDoViewModel
    
    var body: some View {
        Button(action: {
            if todoVM.userId == userId {
                if status == .basic {
                    todoVM.changeTeamTodoStatus(id: id, status: .progress, teamTodoIndex: teamTodoIndex, assignIndex: assignIndex, childIndex: childIndex)
                }
                else if status == .progress {
                    todoVM.changeTeamTodoStatus(id: id, status: .complete, teamTodoIndex: teamTodoIndex, assignIndex: assignIndex, childIndex: childIndex)
                }
                else if status == .complete {
                    switch date.compare(Date()) {
                    case .orderedDescending:
                        todoVM.changeTeamTodoStatus(id: id, status: .basic, teamTodoIndex: teamTodoIndex, assignIndex: assignIndex, childIndex: childIndex)
                        print("Descending")
                        break
                    case .orderedAscending:
                        todoVM.changeTeamTodoStatus(id: id, status: .incomplete, teamTodoIndex: teamTodoIndex, assignIndex: assignIndex, childIndex: childIndex)
                        print("Ascending")
                        break
                    case .orderedSame:
                        todoVM.changeTeamTodoStatus(id: id, status: .basic, teamTodoIndex: teamTodoIndex, assignIndex: assignIndex, childIndex: childIndex)
                        print("Same")
                        break
                    }
                }
                else if status == .incomplete {
                    todoVM.changeTeamTodoStatus(id: id, status: .complete, teamTodoIndex: teamTodoIndex, assignIndex: assignIndex, childIndex: childIndex)
                }
                else if status == .incompleteProgress {
                    todoVM.changeTeamTodoStatus(id: id, status: .complete, teamTodoIndex: teamTodoIndex, assignIndex: assignIndex, childIndex: childIndex)
                    
                }
            }
        }, label: {
            Image(systemName: status == .complete ? "checkmark.circle.fill" : status == .progress || status == .incompleteProgress ? "arrow.triangle.2.circlepath" : "circle" )
                .font(.title3)
                .foregroundColor( status == .basic ? .black :  status == .incomplete || status == .incompleteProgress ? .linkingRed : .linkingBlue)
        }).buttonStyle(.borderless)
    }
}

//struct TodoStatusBtn_Previews: PreviewProvider {
//    static var previews: some View {
//        TodoStatusBtn(status: .basic, id: 1)
//    }
//}
