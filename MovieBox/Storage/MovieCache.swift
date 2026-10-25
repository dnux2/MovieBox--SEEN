import Foundation
import SwiftData

// save and reads movies on the disk
final class MovieCache{
    
    
    private let context: ModelContext
// Needs a ModelContext to talk to the storage
    init(context: ModelContext) {
        self.context = context
    }
    
    
    func save(_ movies: [Movie] , section : String ) {
// Deletes the old movies of this section first, so nothing is duplicated
        let old = fetchCached(section: section)
        for item in old {
            context.delete(item)
        }
        
        //save new
        for(index,movie)in movies.enumerated(){
            let cached = CachedMovie(movie: movie, section: section, position: index)
                       context.insert(cached)
            
        }
        // Writes the changes to the disk
        try? context.save()
    }
    func load(section:String)-> [Movie]{
        
        fetchCached(section: section)
                  .sorted { $0.position < $1.position }
                  .map { $0.toMovie() }
    }
   
    
    private func fetchCached(section: String) -> [CachedMovie] {
        //يحدد نوع البيانات الي اجيبها
        let descriptor = FetchDescriptor<CachedMovie>(
            //يفلترها بشرط فاعرف الفرق بين كاش الهوم وكاش السي ال
            predicate: #Predicate{$0.section == section})
        return (try? context.fetch(descriptor)) ?? []

    }
}
