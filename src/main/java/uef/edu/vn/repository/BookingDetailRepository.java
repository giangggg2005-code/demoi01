package uef.edu.vn.repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import uef.edu.vn.model.BookingDetail;
import uef.edu.vn.model.Ticket;
import uef.edu.vn.model.Showtime;
import uef.edu.vn.model.Movie;
import uef.edu.vn.model.Seat;

@Repository
public class BookingDetailRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final String BASE_SELECT_SQL = 
        "SELECT bd.*, t.id_Ticket, st.id_Showtime, m.id_Movie, m.title AS movie_title, s.id_Seat, s.seatName " +
        "FROM `BookingDetail` bd " +
        "INNER JOIN `Ticket` t ON bd.ticketId = t.id_Ticket " +
        "INNER JOIN `Showtime` st ON t.showtimeId = st.id_Showtime " +
        "INNER JOIN `Movie` m ON st.movieId = m.id_Movie " +
        "INNER JOIN `Seat` s ON t.seatId = s.id_Seat";

    private BookingDetail mapRow(ResultSet rs, int rowNum) throws SQLException {
        BookingDetail bd = new BookingDetail();
        bd.setId_Detail(rs.getInt("id_Detail"));
        bd.setPrice(rs.getDouble("price"));
        bd.setBookingId(rs.getInt("bookingId"));
        bd.setTicketId(rs.getInt("ticketId"));

        Ticket t = new Ticket();
        t.setId_Ticket(rs.getInt("id_Ticket"));

        Showtime st = new Showtime();
        st.setId_Showtime(rs.getInt("id_Showtime"));
        
        Movie m = new Movie();
        m.setId_Movie(rs.getInt("id_Movie"));
        m.setTitle(rs.getString("movie_title")); 
        st.setMovie(m);
        t.setShowtime(st);

        Seat s = new Seat();
        s.setId_Seat(rs.getInt("id_Seat"));
        s.setSeatName(rs.getString("seatName")); 
        t.setSeat(s);

        bd.setTicket(t);
        return bd;
    }

    public List<BookingDetail> findAll() {
        return jdbcTemplate.query(BASE_SELECT_SQL, this::mapRow);
    }

    public BookingDetail findById(int id) {
        String sql = BASE_SELECT_SQL + " WHERE bd.id_Detail = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, id);
        } catch (EmptyResultDataAccessException e) {
            return null; 
        }
    }

    public void save(BookingDetail bd) {
        String sql = "INSERT INTO `BookingDetail` (price, bookingId, ticketId) VALUES (?, ?, ?)";
        jdbcTemplate.update(sql, bd.getPrice(), bd.getBookingId(), bd.getTicketId());
    }

    public void update(BookingDetail bd) {
        String sql = "UPDATE `BookingDetail` SET price = ?, bookingId = ?, ticketId = ? WHERE id_Detail = ?";
        jdbcTemplate.update(sql, bd.getPrice(), bd.getBookingId(), bd.getTicketId(), bd.getId_Detail());
    }

    public void delete(int id) {
        String sql = "DELETE FROM `BookingDetail` WHERE id_Detail = ?";
        jdbcTemplate.update(sql, id);
    }

    public List<BookingDetail> getDetailsByBooking(int bookingId) {
        String sql = BASE_SELECT_SQL + " WHERE bd.bookingId = ?";
        return jdbcTemplate.query(sql, this::mapRow, bookingId);
    }

    public BookingDetail findByTicketId(int ticketId) {
        String sql = BASE_SELECT_SQL + " WHERE bd.ticketId = ?";
        try {
            return jdbcTemplate.queryForObject(sql, this::mapRow, ticketId);
        } catch (EmptyResultDataAccessException e) {
            return null;
        }
    }

    public void deleteByBookingId(int bookingId) {
        String sql = "DELETE FROM `BookingDetail` WHERE bookingId = ?";
        jdbcTemplate.update(sql, bookingId);
    }

    public void saveMultipleDetails(List<BookingDetail> details) {
        if (details == null || details.isEmpty()) return;
        
        String sql = "INSERT INTO `BookingDetail` (price, bookingId, ticketId) VALUES (?, ?, ?)";
        
        jdbcTemplate.batchUpdate(sql, new BatchPreparedStatementSetter() {
            @Override
            public void setValues(java.sql.PreparedStatement ps, int i) throws SQLException {
                BookingDetail bd = details.get(i);
                ps.setDouble(1, bd.getPrice());
                ps.setInt(2, bd.getBookingId());
                ps.setInt(3, bd.getTicketId());
            }

            @Override
            public int getBatchSize() {
                return details.size();
            }
        });
    }
}