package uef.edu.vn.service;

import java.util.List;
import uef.edu.vn.model.Room;
import uef.edu.vn.model.Seat;
import uef.edu.vn.model.Showtime;

public interface RoomService {
    int countFutureSoldTickets(int roomId);
  
    List<Room> getAllRooms();
    Room getRoomById(int roomId);
    Room getRoomByName(String roomName); 
    List<Room> getRoomsByStatus(String status);
    
        Room getRoomWithSeatMap(int showtimeId);
    
    
    boolean createRoom(Room room);
    boolean updateRoom(Room room);
    boolean updateRoomStatus(int roomId, String newStatus);
    boolean deleteRoom(int roomId);

   
    List<Seat> getSeatsByRoomId(int roomId);
    boolean updateSeatStatus(int seatId, String status);

    List<Showtime> getActiveShowtimesForRoom(int roomId);
     Room findRoomWithSeatStatusByShowtimeId(int showtimeId);
}