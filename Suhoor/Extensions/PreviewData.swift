#if DEBUG
import Foundation

protocol PreviewData {
    static var preview: Self { get }
    static var previewList: [Self] { get }
}
#endif
