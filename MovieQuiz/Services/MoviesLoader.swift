import Foundation

protocol MoviesLoading{
    func loadMovies(handler: @escaping (Result<MostPopularMovie, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading{
    //MARK: - Network Client
    private let networkClient = NetworkClient()
    
    //MARK: - URL
    private var mostPopularMoviesURL: URL{
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_azezgvdf") else{
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    func loadMovies(handler: @escaping (Result<MostPopularMovie, Error>) -> Void) {
        
    }
}
