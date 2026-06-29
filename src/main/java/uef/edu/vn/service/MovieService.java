package uef.edu.vn.service;
import java.util.List;
import uef.edu.vn.model.Movie;

public interface MovieService {
    List<Movie> searchAndFilterMovies(String keyword, String genre, String status);
    Movie getMovieById(int movieId);
    boolean createMovie(Movie movie);
    boolean updateMovie(Movie movie);
    boolean deleteMovie(int movieId);
    List<Movie> getMoviesByStatus(String status);
    List<Movie> getMoviesCurrentlyShowing();
    List<Movie> getMoviesWithShowtimesForDate(java.sql.Date date);
    List<uef.edu.vn.model.Showtime> getShowtimesByMovieAndDate(int movieId, java.sql.Date date);
}