package uef.edu.vn.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import uef.edu.vn.model.Movie;

@Repository
public class MovieRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private Movie mapRow(ResultSet rs, int rowNum) throws SQLException {
        Movie m = new Movie();
        m.setId_Movie(rs.getInt("id_Movie"));
        m.setTitle(rs.getString("title"));
        m.setDescription(rs.getString("description"));
        m.setDirector(rs.getString("director"));
        m.setDuration(rs.getInt("duration"));
        m.setCast(rs.getString("cast"));
        m.setLanguage(rs.getString("language"));
        m.setReleaseDate(rs.getDate("releaseDate"));
        m.setGenre(rs.getString("genre"));
        m.setProductionYear(rs.getInt("productionYear"));
        m.setCensorship(rs.getString("censorship"));
        m.setPosterUrl(rs.getString("posterUrl"));
        m.setTrailerUrl(rs.getString("trailerUrl"));
        m.setCategory(rs.getString("category"));
        m.setBasePrice(rs.getDouble("basePrice"));
        m.setStatus(rs.getString("status"));
        return m;
    }

    public List<Movie> searchAndFilter(String keyword, String genre, String status) {
        StringBuilder sql = new StringBuilder("SELECT * FROM `Movie` WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND LOWER(title) LIKE ? ");
            params.add("%" + keyword.toLowerCase().trim() + "%");
        }
        if (genre != null && !genre.equals("all")) {
            sql.append("AND genre = ? ");
            params.add(genre);
        }
        if (status != null && !status.equals("all")) {
            sql.append("AND status = ? ");
            params.add(status);
        }
        return jdbcTemplate.query(sql.toString(), this::mapRow, params.toArray());
    }

    public Movie findById(int id) {
        return jdbcTemplate.queryForObject("SELECT * FROM `Movie` WHERE id_Movie = ?", this::mapRow, id);
    }

    public boolean existsByTitleAndYear(String title, int year, int excludeId) {
        String sql = "SELECT COUNT(*) FROM `Movie` WHERE LOWER(title) = LOWER(?) AND productionYear = ? AND id_Movie != ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, title, year, excludeId);
        return count != null && count > 0;
    }

    public int countSoldTicketsByMovieId(int movieId) {
        String sql = "SELECT COUNT(*) FROM `Ticket` t " +
                     "JOIN `Showtime` s ON t.showtimeId = s.id_Showtime " +
                     "WHERE s.movieId = ?";
        
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, movieId);
        return count != null ? count : 0;
    }

    public void deleteMovie(int id) {
        jdbcTemplate.update("DELETE FROM `Movie` WHERE id_Movie = ?", id);
    }

    public int createMovie(Movie m) {
        String sql = "INSERT INTO `Movie` (title, description, director, duration, cast, language, releaseDate, genre, productionYear, censorship, posterUrl, trailerUrl, category, basePrice, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, m.getTitle(), m.getDescription(), m.getDirector(), m.getDuration(), m.getCast(), m.getLanguage(), m.getReleaseDate(), m.getGenre(), m.getProductionYear(), m.getCensorship(), m.getPosterUrl(), m.getTrailerUrl(), m.getCategory(), m.getBasePrice(), m.getStatus());
    }

    public int updateMovie(Movie m) {
        String sql = "UPDATE `Movie` SET title=?, description=?, director=?, duration=?, cast=?, language=?, releaseDate=?, genre=?, productionYear=?, censorship=?, posterUrl=?, trailerUrl=?, category=?, basePrice=?, status=? WHERE id_Movie=?";
        return jdbcTemplate.update(sql, m.getTitle(), m.getDescription(), m.getDirector(), m.getDuration(), m.getCast(), m.getLanguage(), m.getReleaseDate(), m.getGenre(), m.getProductionYear(), m.getCensorship(), m.getPosterUrl(), m.getTrailerUrl(), m.getCategory(), m.getBasePrice(), m.getStatus(), m.getId_Movie());
    }

    public List<Movie> getMoviesCurrentlyShowing() {
        String sql = "SELECT DISTINCT m.* FROM `Movie` m " +
                     "JOIN `Showtime` s ON m.id_Movie = s.movieId " +
                     "WHERE CONCAT(s.showDate, ' ', s.startTime) >= NOW() " +
                     "AND m.status = 'Showing' " +
                     "ORDER BY m.releaseDate DESC";
        return jdbcTemplate.query(sql, this::mapRow);
    }

    public List<Movie> getMoviesShowingIn7Days() {
        String sql = "SELECT DISTINCT m.* FROM `Movie` m " +
                     "JOIN `Showtime` s ON m.id_Movie = s.movieId " +
                     "WHERE CONCAT(s.showDate, ' ', s.startTime) >= NOW() " +
                     "AND s.showDate <= DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY) " +
                     "AND s.status = 'Active' " +
                     "ORDER BY m.releaseDate DESC";
        return jdbcTemplate.query(sql, this::mapRow);
    }
}