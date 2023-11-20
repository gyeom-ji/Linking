//
//  DocumentView.swift
//  Linking
//
//  Created by 윤겸지 on 2023/03/18.
//

import SwiftUI
import PDFKit

struct DocumentView: View {
    
    @EnvironmentObject var groupVM : GroupViewModel
    @EnvironmentObject var notiVM : NotificationViewModel
    @EnvironmentObject var pageVM : PageViewModel
    @ObservedObject var blockVM = BlockViewModel()
    @State private var isShowIndexSideBar: Bool = false
    @State private var isShowBody: Bool = true
    @State private var selectedIndex: Int = 0
    @State private var showCreatePDFAlert = false
    @State private var alertText: String = ""
    @State private var showBodyTargetId: Int = -1
    @State private var isDelete: Bool = false
    @Binding var isChangeProject : Bool
    var template : String
    var pageIndex: Int
    var groupIndex: Int
  
    init(pageIndex : Int, groupIndex: Int, template: String, isChangeProject: Binding<Bool>){
        self.pageIndex = pageIndex
        self.groupIndex = groupIndex
        self.template = template
        self._isChangeProject = isChangeProject
    }
    
    
    var body: some View {
        
        HSplitView{
            ZStack{
                
                if $isChangeProject.wrappedValue || $isDelete.wrappedValue {
                    withAnimation {
                        HomeView()
                            .background(Color.white).zIndex(1)
                            .onAppear(perform: {
                                if !isDelete && groupVM.groupList.count > groupIndex && groupVM.groupList[groupIndex].pageList.count > pageIndex {
                                    pageVM.disconnectSSE(pageId: groupVM.groupList[groupIndex].pageList[pageIndex].id)
                                    pageVM.disconnectPageWebSocket()
                                   
                                }
                            })
                    }
                }
                else {
                    GeometryReader { geometry in
                        ScrollView {
                            ScrollViewReader {
                                proxy in
                                VStack{
                                    
                                    HStack {
                                        
                                        if template == "BLOCK" {
                                            checkPersonMenu
                                        }
                                        else {
                                            blankPagecheckPersonMenu
                                        }
                                        
                                        Spacer()
                                        
                                        savePDFBtn(width: geometry.size.width, height: geometry.size.height)
                                    }
                                    // content page
                                    if template == "BLOCK" {
                                        VStack{
                                            
                                            indexBtn
                                            
                                            pageTitle
                                            
                                            if pageVM.page.blockResList.count < 1 {
                                                insertBlockBtn
                                            }
                                            else {
                                                Spacer()
                                                    .frame(height: 30.0)
                                            }
                                            
                                            blockRow.onReceive(pageVM.$isSelected, perform: {
                                                _ in
                                                withAnimation(.easeOut(duration: 0.2)){
                                                    proxy.scrollTo(selectedIndex, anchor: .bottom)
                                                }
                                            })
                                            
                                            Spacer()
                                            
                                            if pageVM.page.blockResList.count > 0 {
                                                insertBlockBtn
                                                Spacer()
                                                    .frame(height: 30.0)
                                            }
                                        }
                                    }
                                    
                                    // blankPage
                                    else {
                                        pageTitle
                                        BlankDocumentView()
                                    }
                                }
                            }
                        }
                        
                        deleteBtn
                        
                    }.background(Color.white)
                }
            }
            if isShowIndexSideBar {
                withAnimation {
                    
                    IndexSideBar(selectedIndex: $selectedIndex)
                }
            }
        }.onAppear(  perform: {
            DispatchQueue.main.async {
                if template == "BLOCK" {
                    pageVM.openPageSSE(pageId: groupVM.groupList[groupIndex].pageList[pageIndex].id)
                }
                else {
                    pageVM.openBlankPageSSE(pageId: groupVM.groupList[groupIndex].pageList[pageIndex].id)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    if template == "BLOCK" {
                        pageVM.readPage(id: groupVM.groupList[groupIndex].pageList[pageIndex].id)
                        pageVM.connectPageWebSocket(pageId: groupVM.groupList[groupIndex].pageList[pageIndex].id)
                    }
                    else {
                        pageVM.readBlankPage(id: groupVM.groupList[groupIndex].pageList[pageIndex].id)
                        pageVM.connectBlankPageWebSocket(pageId: groupVM.groupList[groupIndex].pageList[pageIndex].id)
                    }
                }
                groupVM.groupList[groupIndex].pageList[pageIndex].annoNotiCnt = 0
            }
        }).onDisappear(perform: {
            if !isDelete && groupVM.groupList.count > groupIndex && groupVM.groupList[groupIndex].pageList.count > pageIndex {
                pageVM.disconnectSSE(pageId: groupVM.groupList[groupIndex].pageList[pageIndex].id)
                pageVM.disconnectPageWebSocket()
            }
        })
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var value : Int = 0
    static var selectedTemplates: String = ""
    @State static var isChangeProject : Bool = false
    static var previews: some View {
        DocumentView(pageIndex: 1, groupIndex: 1, template: selectedTemplates, isChangeProject: $isChangeProject).environmentObject(PageViewModel())
    }
}

extension DocumentView {
    
    func createPdfAndSave(width: CGFloat, height: CGFloat) -> String  {
        let fileManager = FileManager.default
        let documentPath: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfPath: URL = documentPath.appendingPathComponent("\(pageVM.blankPage.pageTitle).pdf")
        let outUrl: CFURL = pdfPath as CFURL
        
        ///content
        let textField = NSTextField()
        textField.attributedStringValue = setLineSpacing(2, text: pageVM.blankPage.content)
        textField.maximumNumberOfLines = 0
        let newSize =  textField.sizeThatFits( CGSize(width: 500, height: CGFloat.greatestFiniteMagnitude))
        textField.setFrameSize(CGSize(width: 500, height: newSize.height))
        textField.lineBreakStrategy = .hangulWordPriority
        textField.font = NSFont.systemFont(ofSize: 12)
        textField.isBordered = false
        
        ///title
        let titleText = NSAttributedString(string: pageVM.blankPage.pageTitle , attributes: [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: NSColor.black
        ])
        let titleTextBounds = titleText.size()
        
        let doc: PDFDocument = PDFDocument()
        
        doc.insert(PDFPage(), at: 0)
        let page: PDFPage = doc.page(at: 0)!
        
        var mediaBox: CGRect = CGRect(x: page.bounds(for: .mediaBox).minX, y: 0, width: 550, height: newSize.height + titleTextBounds.height + 60)
        
        let gc = CGContext(outUrl, mediaBox: &mediaBox, nil)!
        let nsgc = NSGraphicsContext(cgContext: gc, flipped: false)
        NSGraphicsContext.current = nsgc
        
        gc.beginPDFPage(nil); do {
            page.draw(with: .mediaBox, to: gc)
            
            /// draw Title
            let point = CGPoint(x: mediaBox.midX - titleTextBounds.width / 2, y: mediaBox.maxY -  (titleTextBounds.height + 25))
            
            gc.saveGState(); do {
                gc.translateBy(x: point.x, y: point.y)
                
                titleText.draw(at: .zero)
                
            }; gc.restoreGState()
            
            /// draw Content
            let contentPoint = CGPoint(x: mediaBox.midX - textField.frame.size.width / 2, y: mediaBox.maxY -  ((titleTextBounds.height + 25) + (textField.frame.size.height + 25)))
            
            gc.saveGState(); do {
                gc.translateBy(x: contentPoint.x, y: contentPoint.y)
                
                textField.draw(mediaBox)
                
            }; gc.restoreGState()
            
        }; gc.endPDFPage()
        
        NSGraphicsContext.current = nil
        
        gc.closePDF()
        return String("\(pdfPath)")
    }
    
    func createBlockPdfAndSave() -> String  {
        let fileManager = FileManager.default
        let documentPath: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfPath: URL = documentPath.appendingPathComponent("\(pageVM.page.pageTitle).pdf")
        let outUrl: CFURL = pdfPath as CFURL
        
        /// title
        let titleText = NSAttributedString(string: pageVM.page.pageTitle , attributes: [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: NSColor.black
        ])
        
        let titleTextBounds = titleText.size()
        var docHeight = titleTextBounds.height + 15
        
        ///get Block Height
        for i in 0..<pageVM.page.blockResList.count {
            let textField = NSTextField()
            for j in 0..<2 {
                
                if j == 0 {
                    textField.attributedStringValue = setLineSpacing(2, text: pageVM.page.blockResList[i].title)
                    textField.maximumNumberOfLines = 0
                    let newSize =  textField.sizeThatFits( CGSize(width: 500, height: CGFloat.greatestFiniteMagnitude))
                    docHeight += (newSize.height + 10)
                }
                else {
                    textField.attributedStringValue = setLineSpacing(2, text: pageVM.page.blockResList[i].content)
                    textField.maximumNumberOfLines = 0
                    let newSize =  textField.sizeThatFits( CGSize(width: 500, height: CGFloat.greatestFiniteMagnitude))
                    docHeight += (newSize.height + 10)
                }
            }
        }
        
        let doc: PDFDocument = PDFDocument()
        
        doc.insert(PDFPage(), at: 0)
        let page: PDFPage = doc.page(at: 0)!
        
        var mediaBox: CGRect = CGRect(x: page.bounds(for: .mediaBox).minX, y: 0, width: 550, height: docHeight + 100)
        
        let gc = CGContext(outUrl, mediaBox: &mediaBox, nil)!
        let nsgc = NSGraphicsContext(cgContext: gc, flipped: false)
        
        NSGraphicsContext.current = nsgc
        gc.beginPDFPage(nil); do {
            page.draw(with: .mediaBox, to: gc)
            
            /// draw Title
            let point = CGPoint(x: mediaBox.midX - titleTextBounds.width / 2, y: mediaBox.maxY -  (titleTextBounds.height + 25))
            gc.saveGState(); do {
                gc.translateBy(x: point.x, y: point.y)
                
                titleText.draw(at: .zero)
                
            }; gc.restoreGState()
            
            var height = titleTextBounds.height + 15
            
            /// draw Block
            for i in 0..<pageVM.page.blockResList.count {
                let textField = NSTextField()
                textField.wantsLayer = true
                let textFieldLayer = CALayer()
                textFieldLayer.cornerRadius = 10
                textFieldLayer.borderColor = CGColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                textField.layer?.borderWidth = 2
                textField.layer = textFieldLayer
                textField.layer?.borderColor = CGColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                for j in 0..<2 {
                    if j == 0 {
                        textField.attributedStringValue = setLineSpacing(2, text: pageVM.page.blockResList[i].title)
                        textField.maximumNumberOfLines = 0
                        let newSize =  textField.sizeThatFits( CGSize(width: 500, height: CGFloat.greatestFiniteMagnitude))
                        height += (newSize.height + 10)
                        textField.setFrameSize(CGSize(width: 500, height: newSize.height))
                        textField.lineBreakStrategy = .hangulWordPriority
                        textField.font = NSFont.systemFont(ofSize: 13)
                        
                        let contentPoint = CGPoint(x: mediaBox.midX - 500 / 2, y: mediaBox.maxY -  ((titleTextBounds.height) + (height)))
                        
                        gc.saveGState(); do {
                            gc.translateBy(x: contentPoint.x, y: contentPoint.y)
                            
                            textField.draw(mediaBox)
                            
                            
                        }; gc.restoreGState()
                    }
                    else {
                        textField.attributedStringValue = setLineSpacing(2, text: pageVM.page.blockResList[i].content)
                        textField.maximumNumberOfLines = 0
                        let newSize =  textField.sizeThatFits( CGSize(width: 500, height: CGFloat.greatestFiniteMagnitude))
                        textField.setFrameSize(CGSize(width: 500, height: newSize.height))
                        textField.lineBreakStrategy = .hangulWordPriority
                        textField.font = NSFont.systemFont(ofSize: 12)
                        
                        height += (newSize.height + 10)
                        let contentPoint = CGPoint(x: mediaBox.midX - 500 / 2, y: mediaBox.maxY -  ((titleTextBounds.height ) + (height)))
                        
                        gc.saveGState(); do {
                            gc.translateBy(x: contentPoint.x, y: contentPoint.y)
                            
                            textField.draw(mediaBox)
                            
                        }; gc.restoreGState()
                    }
                }
            }
        }; gc.endPDFPage()
        NSGraphicsContext.current = nil
        
        gc.closePDF()
        return String("\(pdfPath)")
    }
    
    
    func setLineSpacing(_ spacing: CGFloat, text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        
        return NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
    }
    
    var blankPagecheckPersonMenu: some View {
        VStack{
            HStack{
                Image(systemName: "person.fill")
                    .foregroundColor(.linkingLightGreen)
                    .padding(.leading, 5.0)
                Spacer()
            }
            .padding(.top)
            
            HStack{
                Menu {
                    ForEach(0...pageVM.blankPage.pageCheckResList.count, id:\.self){
                        index in
                        Menu{
                            Menu{
                                Button(action: {
                                    if index != 0 {
                                        
                                        notiVM.insertPagePushNotification(userId: pageVM.blankPage.pageCheckResList[index-1].userId, priority: 0, targetId:  pageVM.blankPage.id, content: pageVM.blankPage.pageTitle)
                                        
                                    }
                                    else {
                                        
                                        for i in 0..<pageVM.blankPage.pageCheckResList.count {
                                            notiVM.insertPagePushNotification(userId:  pageVM.blankPage.pageCheckResList[i].userId, priority: 0, targetId: pageVM.blankPage.id, content: pageVM.blankPage.pageTitle)
                                        }
                                        
                                    }
                                }, label: {
                                    Image("circle_red")
                                    Text("메일 & 앱 알림")
                                })
                                Button(action: {
                                    if index != 0 {
                                        
                                        notiVM.insertPagePushNotification(userId: pageVM.blankPage.pageCheckResList[index-1].userId, priority: 1, targetId:  pageVM.blankPage.id, content: pageVM.blankPage.pageTitle)
                                        
                                    }
                                    else {
                                        
                                        for i in 0..<pageVM.blankPage.pageCheckResList.count {
                                            notiVM.insertPagePushNotification(userId:  pageVM.blankPage.pageCheckResList[i].userId, priority: 1, targetId: pageVM.blankPage.id, content: pageVM.blankPage.pageTitle)
                                        }
                                        
                                    }
                                }, label: {
                                    Image("circle_green")
                                    Text("앱 알림")
                                })
                                
                            }label: {
                                
                                Text("알림 보내기")
                                
                            }
                            
                        } label: {
                            Image(systemName: index == 0 ? "bell" : pageVM.blankPage.pageCheckResList[index-1].isEntering ?  "person.wave.2.fill" :  pageVM.blankPage.pageCheckResList[index-1].isChecked ? "person.fill" : "person.fill.xmark")
                            
                            Text(index == 0 ? "전체 알림 보내기" : pageVM.blankPage.pageCheckResList[index-1].isEntering ? pageVM.blankPage.pageCheckResList[index-1].userName + "         now" : pageVM.blankPage.pageCheckResList[index-1].isChecked ? pageVM.blankPage.pageCheckResList[index-1].userName + "         " + pageVM.getBlankLastCheckedDateToString(index: index-1) : pageVM.blankPage.pageCheckResList[index-1].userName)
                            
                        }
                    }
                } label: {
                    Text("\(pageVM.getBlankPageCheckCount())명")
                        .foregroundColor(.linkingLightGreen)
                }
                Spacer()
            }
            
        }.padding(.horizontal).buttonStyle(.borderless)
    }
    
    var checkPersonMenu: some View {
        VStack{
            HStack{
                Image(systemName: "person.fill")
                    .foregroundColor(.linkingLightGreen)
                    .padding(.leading, 5.0)
                Spacer()
            }
            .padding(.top)
            
            HStack{
                Menu {
                    ForEach(0...pageVM.page.pageCheckResList.count, id:\.self){
                        index in
                        Menu{
                            Menu{
                                Button(action: {
                                    if index != 0 {
                                        
                                        notiVM.insertPagePushNotification(userId: pageVM.page.pageCheckResList[index-1].userId , priority: 0, targetId:  pageVM.page.id, content: pageVM.page.pageTitle)
                                        
                                    }
                                    else {
                                        
                                        for i in 0..<pageVM.page.pageCheckResList.count {
                                            notiVM.insertPagePushNotification(userId:  pageVM.page.pageCheckResList[i].userId, priority: 0, targetId: pageVM.page.id, content: pageVM.page.pageTitle)
                                        }
                                    }
                                }, label: {
                                    Image("circle_red")
                                    Text("메일 & 앱 알림")
                                })
                                Button(action: {
                                    if index != 0 {
                                        
                                        notiVM.insertPagePushNotification(userId: pageVM.page.pageCheckResList[index-1].userId , priority: 1, targetId:  pageVM.page.id, content: pageVM.page.pageTitle)
                                    }
                                    else {
                                        for i in 0..<pageVM.page.pageCheckResList.count {
                                            notiVM.insertPagePushNotification(userId:  pageVM.page.pageCheckResList[i].userId, priority: 1, targetId: pageVM.page.id, content: pageVM.page.pageTitle)
                                            
                                        }
                                    }
                                }, label: {
                                    Image("circle_green")
                                    Text("앱 알림")
                                })
                                
                            }label: {
                                
                                Text("알림 보내기")
                                
                            }
                            
                        } label: {
                            Image(systemName: index == 0 ? "bell" : pageVM.page.pageCheckResList[index-1].isEntering ? "person.wave.2.fill" :  pageVM.page.pageCheckResList[index-1].isChecked ? "person.fill" : "person.fill.xmark")
                            
                            Text(index == 0 ? "전체 알림 보내기" : pageVM.page.pageCheckResList[index-1].isEntering ? pageVM.page.pageCheckResList[index-1].userName + "         now" : pageVM.page.pageCheckResList[index-1].isChecked ? pageVM.page.pageCheckResList[index-1].userName + "         " + pageVM.getLastCheckedDateToString(index: index-1) : pageVM.page.pageCheckResList[index-1].userName)
                            
                        }
                    }
                } label: {
                    Text("\(pageVM.getPageCheckCount())명")
                        .foregroundColor(.linkingLightGreen)
                }
                Spacer()
            }
            
        }.padding(.horizontal).buttonStyle(.borderless)
    }
    
    var insertBlockBtn: some View {
        HStack{
            Spacer()
            Button(action: {
                pageVM.appendBlock(blockTitle: "untitled")
            }, label: {
                VStack{
                    Image(systemName: "plus.circle")
                        .padding(.bottom, 1.0)
                        .font(.title)
                        .fontWeight(.thin)
                    
                    Text("목차 추가")
                        .font(.body)
                        .fontWeight(.thin)
                        .kerning(1)
                }.foregroundColor(.linkingLightGray)
            }).buttonStyle(.borderless)
            Spacer()
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    var indexBtn: some View {
        HStack{
            Spacer()
            Button(isShowIndexSideBar ? "목차 닫기" : "목차 보기", action: {
                isShowIndexSideBar.toggle()
            }).foregroundColor(.linkingLightGray).kerning(1).buttonStyle(.borderless)
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    var pageTitle: some View {
        HStack{
            Spacer()
            if groupVM.groupList.count > groupIndex && groupVM.groupList[groupIndex].pageList.count > pageIndex {
                Text(groupVM.groupList[groupIndex].pageList[pageIndex].pageTitle)
                    .font(.system(size: 33))
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .help("제목 수정은 사이드바에서만 가능합니다")
            }
            Spacer()
        }
        .padding([.leading, .bottom, .trailing])
    }
    
    var blockRow: some View {
        ForEach(0..<pageVM.page.blockResList.count, id:\.self, content: {
            index in
            if pageVM.page.blockResList.count > index && pageVM.page.blockResList[index].id != -1 {
                
                VStack{
                    
                    HStack{
                        Spacer()
                        TitleBlock(showBodyTargetId: $showBodyTargetId, isShowBody: $isShowBody, blockIndex: Int(index))
                        Spacer()
                    }.id(Int(index))
                    
                    Spacer().frame(height: 10)
                    
                    if !isShowBody && showBodyTargetId == index{
                        HStack{
                            Spacer()
                        }
                    }
                    else {
                        HStack{
                            Spacer()
                            
                            BodyBlock(blockIndex: Int(index))
                            
                            if pageVM.page.blockResList[index].annotationList.count > 0 &&
                                pageVM.page.blockResList[index].annotationList[0].id != -1 {
                                VStack{
                                    AnnotationView(blockIndex: index)
                                    Spacer()
                                }
                            }
                            else {
                                Spacer()
                                    .frame(width: 260)
                            }
                            Spacer()
                        }
                    }
                }
                Spacer()
                    .frame(height: 50.0)
            }
        })
    }
    
    var deleteBtn: some View {
        VStack{
            Spacer()
            
            HStack{
                
                Spacer()
                Button(action: {
                    groupVM.removePage(pageIndex: pageIndex, groupIndex: groupIndex)
                    isDelete = true
                    
                }, label: {
                    Image(systemName: "trash")
                        .foregroundColor(.linkingGray)
                        .font(.title)
                }).padding([.trailing, .bottom]).buttonStyle(.borderless)
            }
        }
    }
    
    func savePDFBtn(width: CGFloat, height: CGFloat) -> some View {
        Button(action: {
            //prepareData()
            if template == "BLOCK" {
                alertText = "PDF가 \(createBlockPdfAndSave()) 경로에 저장되었습니다."
            }
            else {
                alertText = "PDF가 \(createPdfAndSave(width:width, height: height))경로에 저장되었습니다."
            }
            showCreatePDFAlert = true
        }, label: {
            VStack{
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .regular)).padding(.top)
                    .foregroundColor(.linkingLightGreen)
                Text("Save as PDF")
                    .font(.caption)
                    .foregroundColor(.linkingLightGreen)
            }
        }).buttonStyle(.borderless).padding(.horizontal).alert(isPresented: $showCreatePDFAlert) {
            Alert(title: Text(alertText),
                  dismissButton: .default(Text("확인")))
        }
    }
}

