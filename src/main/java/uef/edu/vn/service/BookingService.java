package uef.edu.vn.service;

import java.sql.Timestamp;
import java.util.List;
import uef.edu.vn.model.Booking;

public interface BookingService {
    
   
    List<Booking> getAllBookings();
    Booking getBookingById(int bookingId);
    List<Booking> getBookingHistoryByUser(int userId);
    List<Booking> getBookingsByStatus(String status);
    List<Booking> getBookingsWithPagination(int limit, int offset);

  
    boolean createBooking(Booking booking);
    int createBookingAndGetId(Booking booking); 
    boolean updateBooking(Booking booking);
    boolean deleteBooking(int bookingId);
    boolean updateBookingStatus(int bookingId, String status);
}