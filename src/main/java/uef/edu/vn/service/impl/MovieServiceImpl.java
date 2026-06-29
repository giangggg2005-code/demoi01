package uef.edu.vn.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import uef.edu.vn.model.Movie;
import uef.edu.vn.repository.MovieRepository;
import uef.edu.vn.service.MovieService;
import uef.edu.vn.exception.MovieException;

@Service
public class MovieServiceImpl implements MovieService {

    @Autowired
    private MovieRepository movieRepo;

    @Override
    public List<Movie> searchAndFilterMovies(String keyword, String genre, String status) {
        return movieRepo.searchAndFilter(keyword, genre, status);
    }

    @Override
    public Movie getMovieById(int movieId) {
        return movieRepo.findById(movieId);
    }

    @Override
    public boolean createMovie(Movie movie) {
        validateMovieLogic(movie);
        return movieRepo.createMovie(movie) > 0;
    }

    @Override
    public boolean updateMovie(Movie movie) {
        validateMovieLogic(movie);
        return movieRepo.updateMovie(movie) > 0;
    }

    @Override
    public boolean deleteMovie(int movieId) {
        int soldTickets = movieRepo.countSoldTicketsByMovieId(movieId);
        if (soldTickets > 0) {
            throw new MovieException("Không thể xóa vì phim có lịch suất chiếu đã phát sinh vé bán cho khách hàng!");
        }

        try {
            movieRepo.deleteMovie(movieId);
            return true;
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Lỗi không xác định khi xóa phim: " + e.getMessage());
        }
    }

    private void validateMovieLogic(Movie movie) {
        if (!movie.isTimelineValid()) {
            throw new IllegalArgumentException("Ngoại lệ logic: Ngày khởi chiếu không thể xảy ra trước Năm sản xuất!");
        }
        if (!movie.isProductionYearRealistic()) {
            throw new IllegalArgumentException("Ngoại lệ logic: Năm sản xuất không hợp lý so với mốc thời gian hiện tại!");
        }
        boolean isDuplicate = movieRepo.existsByTitleAndYear(movie.getTitle(), movie.getProductionYear(), movie.getId_Movie());
        if (isDuplicate) {
            throw new IllegalArgumentException("Cảnh báo trùng lặp: Một bộ phim với tên và năm sản xuất này đã tồn tại trong hệ thống!");
        }
    }

    @Override
    public List<Movie> getMoviesByStatus(String status) {
        return movieRepo.searchAndFilter("", "", status);
    }

    @Override
    public List<Movie> getMoviesCurrentlyShowing() {
        return movieRepo.getMoviesCurrentlyShowing();
    }

    @Autowired
    private uef.edu.vn.repository.ShowtimeRepository showtimeRepo;

    @Override
    public List<Movie> getMoviesWithShowtimesForDate(java.sql.Date date) {
        List<Movie> movies = movieRepo.getMoviesShowingIn7Days();
        
        for (Movie movie : movies) {
            List<uef.edu.vn.model.Showtime> activeShowtimes = showtimeRepo.findByMovieAndSpecificDate(movie.getId_Movie(), date);
            movie.setShowtimes(activeShowtimes);
        }
        
        movies.removeIf(m -> m.getShowtimes() == null || m.getShowtimes().isEmpty());
        return movies;
    }

    @Override
    public List<uef.edu.vn.model.Showtime> getShowtimesByMovieAndDate(int movieId, java.sql.Date date) {
        return showtimeRepo.findByMovieAndSpecificDate(movieId, date);
    }
}