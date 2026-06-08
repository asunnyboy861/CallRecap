import Foundation
import UIKit

class ExportService {
    static func exportRecording(_ recording: Recording, format: ExportFormat) -> URL? {
        switch format {
        case .pdf: return exportAsPDF(recording)
        case .srt: return exportAsSRT(recording)
        case .txt: return exportAsTXT(recording)
        case .audio: return recording.audioFileURL
        }
    }

    private static func exportAsPDF(_ recording: Recording) -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(recording.contactName ?? "Recording")-\(recording.date.formattedDate).pdf")

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                var y: CGFloat = 50

                let titleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 18),
                    .foregroundColor: UIColor.label
                ]
                let bodyAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label
                ]

                let title = "\(recording.contactName ?? "Unknown") — \(recording.date.formattedDate)"
                title.draw(at: CGPoint(x: 50, y: y), withAttributes: titleAttrs)
                y += 30

                "Duration: \(recording.formattedDuration)".draw(at: CGPoint(x: 50, y: y), withAttributes: bodyAttrs)
                y += 25

                if let summary = recording.summary {
                    "Summary".draw(at: CGPoint(x: 50, y: y), withAttributes: titleAttrs)
                    y += 25
                    summary.overview.draw(at: CGPoint(x: 50, y: y), withAttributes: bodyAttrs)
                    y += 20

                    if !summary.keyPoints.isEmpty {
                        y += 10
                        "Key Points".draw(at: CGPoint(x: 50, y: y), withAttributes: titleAttrs)
                        y += 25
                        for point in summary.keyPoints {
                            "• \(point)".draw(at: CGPoint(x: 60, y: y), withAttributes: bodyAttrs)
                            y += 18
                        }
                    }

                    if !summary.actionItems.isEmpty {
                        y += 10
                        "Action Items".draw(at: CGPoint(x: 50, y: y), withAttributes: titleAttrs)
                        y += 25
                        for item in summary.actionItems {
                            "☐ \(item.text)".draw(at: CGPoint(x: 60, y: y), withAttributes: bodyAttrs)
                            y += 18
                        }
                    }
                }

                if let transcript = recording.transcriptText {
                    y += 20
                    "Transcript".draw(at: CGPoint(x: 50, y: y), withAttributes: titleAttrs)
                    y += 25
                    transcript.draw(in: CGRect(x: 50, y: y, width: 512, height: 400), withAttributes: bodyAttrs)
                }
            }
            return url
        } catch {
            return nil
        }
    }

    private static func exportAsSRT(_ recording: Recording) -> URL? {
        guard let segments = recording.segments else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(recording.contactName ?? "Recording").srt")

        var srtContent = ""
        for (index, segment) in segments.enumerated() {
            srtContent += "\(index + 1)\n"
            srtContent += "\(formatSRTTime(segment.startTime)) --> \(formatSRTTime(segment.endTime))\n"
            srtContent += "\(segment.text)\n\n"
        }

        do {
            try srtContent.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private static func exportAsTXT(_ recording: Recording) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(recording.contactName ?? "Recording").txt")
        var content = "Call Recording — \(recording.date.formattedDate)\n"
        content += "Duration: \(recording.formattedDuration)\n"
        content += "Contact: \(recording.contactName ?? "Unknown")\n\n"

        if let summary = recording.summary {
            content += "=== Summary ===\n"
            content += "\(summary.overview)\n\n"
            if !summary.keyPoints.isEmpty {
                content += "Key Points:\n"
                summary.keyPoints.forEach { content += "• \($0)\n" }
                content += "\n"
            }
            if !summary.actionItems.isEmpty {
                content += "Action Items:\n"
                summary.actionItems.forEach { content += "☐ \($0.text)\n" }
                content += "\n"
            }
        }

        if let transcript = recording.transcriptText {
            content += "=== Transcript ===\n\(transcript)\n"
        }

        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private static func formatSRTTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds.truncatingRemainder(dividingBy: 1)) * 1000)
        return String(format: "%02d:%02d:%02d,%03d", hours, minutes, secs, ms)
    }
}
