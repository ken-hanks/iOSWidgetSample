//
//  SingleNews.swift
//  SingleNews
//
//  Created by KANG HAN on 2020/9/25.
//

import WidgetKit
import SwiftUI
import Network

var newsList: [NewsSummary] = []
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let previewList : [NewsSummary] = [NewsSummary(id: 0, title: "预览新闻标题A"), NewsSummary(id: 0, title: "预览新闻标题B")]
        return SimpleEntry(date: Date(), newsList: previewList)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        ClientAgent.requestNewsList { (newsList) in
            let entry = SimpleEntry(date: Date(), newsList: newsList)
            completion(entry)
        } failure: { (responseBase) in
            let previewList : [NewsSummary] = [NewsSummary(id: 0, title: "预览新闻标题A"), NewsSummary(id: 0, title: "预览新闻标题B")]
            let entry = SimpleEntry(date: Date(), newsList: previewList)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let updateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)
        
        ClientAgent.requestNewsList { (resultList) in
            newsList = resultList
            
            //需在此阶段将网络图片下载并以Image方式保存
            var finishImageCount = 0
            for i in  0..<newsList.count {
                let url: URL = URL(string: newsList[i].picUrl)!
                ImageHelper.downloadImage(url: url) { (result) in
                    if case .success(let response) = result {
                        newsList[i].image = response
                        finishImageCount += 1
                        if finishImageCount == newsList.count {
                            let entry = SimpleEntry(date: updateDate!, newsList: newsList)
                            let timeline = Timeline(entries: [entry], policy: .after(updateDate!))
                            completion(timeline)
                        }
                    }
                }
            }

        } failure: { (responseBase) in
            let entry = SimpleEntry(date: updateDate!, newsList: newsList)
            let timeline = Timeline(entries: [entry], policy: .after(updateDate!))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let newsList: [NewsSummary]
}

//小尺寸下的Widget布局
struct NewsViewSmall : View {
    var entry: Provider.Entry
    var body : some View {
        VStack {
            if entry.newsList.count > 0
            {
                Image(uiImage: entry.newsList[0].image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 90)
                    .clipped()
                Spacer()
                Text(entry.newsList[0].title)
                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color("title_color"))
                    .lineLimit(4)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            else {
                Text(entry.date, style: .time)
            }
        }
        .widgetURL(URL(string: entry.newsList.count > 0 ? entry.newsList[0].detailUrl : ""))
    }
}

//中/大尺寸下的Widget布局
struct NewsViewMedium : View {
    var entry: Provider.Entry
    var body : some View {
        VStack {
            if entry.newsList.count > 0
            {
                Link(destination: URL(string: entry.newsList[0].detailUrl)!) {
                    HStack {
                        Image(uiImage: entry.newsList[0].image!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40, alignment: .center)
                            .clipped()
                            .padding(.leading, 12.0)
                            .shadow(radius: 5)
                        Text(entry.newsList[0].title)
                            .font(/*@START_MENU_TOKEN@*/.caption/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color("title_color"))
                            .lineLimit(3)
                        Spacer()
                    }
                }
            }
            else
            {
                Text(entry.date, style: .time)
            }

            
            if(entry.newsList.count > 1)
            {
                Divider()
                    .padding(.horizontal)
                Link(destination: URL(string: entry.newsList[1].detailUrl)!) {
                    HStack {
                        Image(uiImage: entry.newsList[1].image!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40, alignment: .center)
                            .clipped()
                            .padding(.leading, 12.0)
                            .shadow(radius: 5)
                        Text(entry.newsList[1].title)
                            .font(/*@START_MENU_TOKEN@*/.caption/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color("title_color"))
                            .lineLimit(3)
                        Spacer()
                    }
                }
            }
        }
    }
}


struct SingleNewsEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: Provider.Entry
    var body: some View {
        switch family {
        case .systemSmall:
            NewsViewSmall(entry: entry)
        default:
            NewsViewMedium(entry: entry)
        }
        
    }
}

@main
struct SingleNews: Widget {
    let kind: String = "SingleNews"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SingleNewsEntryView(entry: entry)
        }
        .configurationDisplayName("Sample News Widget")
        .description("This is an example widget.")
    }
}

struct SingleNews_Previews: PreviewProvider {
    static var previews: some View {
        let previewList : [NewsSummary] = [NewsSummary(id: 0, title: "用于预览的新闻标题A"), NewsSummary(id: 0, title: "预览新闻标题B")]
        SingleNewsEntryView(entry: SimpleEntry(date: Date(), newsList: previewList))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
