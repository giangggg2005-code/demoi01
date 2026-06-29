package uef.edu.vn.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import uef.edu.vn.exception.RoomException;
import uef.edu.vn.model.Room;
import uef.edu.vn.model.Seat;
import uef.edu.vn.model.Showtime;
import uef.edu.vn.repository.RoomRepository;
import uef.edu.vn.repository.SeatRepository;
import uef.edu.vn.repository.ShowtimeRepository;
import uef.edu.vn.service.RoomService;

@Service
public class RoomServiceImpl implements RoomService {

    private final RoomRepository roomRepo;
    private final SeatRepository seatRepo;
    private final ShowtimeRepository showtimeRepo;

    @Autowired
    public RoomServiceImpl(RoomRepository roomRepo, SeatRepository seatRepo, ShowtimeRepository showtimeRepo) {
        this.roomRepo = roomRepo;
        this.seatRepo = seatRepo;
        this.showtimeRepo = showtimeRepo;
    }

    @Override
    public List<Showtime> getActiveShowtimesForRoom(int roomId) {
        return showtimeRepo.getActiveShowtimesForRoom(roomId);
    }

    @Override
    public List<Room> getAllRooms() {
        return roomRepo.findAll();
    }

    @Override
    public Room getRoomById(int roomId) {
        if (roomId <= 0) {
            throw new RoomException("Lỗi: ID phòng chiếu không hợp lệ.");
        }
        Room room = roomRepo.findById(roomId);
        if (room == null) {
            throw new RoomException("Lỗi truy xuất: Không tìm thấy phòng chiếu với ID = " + roomId);
        }
        return room;
    }

    @Override
    public Room getRoomByName(String roomName) {
        if (roomName == null || roomName.trim().isEmpty()) {
            throw new RoomException("Lỗi: Tên phòng tìm kiếm không được để trống.");
        }
        return roomRepo.findByName(roomName.trim());
    }

    @Override
    public List<Room> getRoomsByStatus(String status) {
        if (status == null || status.trim().isEmpty()) {
            throw new RoomException("Lỗi: Trạng thái tìm kiếm không được để trống.");
        }
        return roomRepo.findByStatus(status.trim());
    }

    @Override
    public Room getRoomWithSeatMap(int showtimeId) {
        if (showtimeId <= 0) {
            throw new RoomException("Lỗi: ID lịch chiếu không hợp lệ.");
        }
        Room room = roomRepo.findRoomWithSeatStatusByShowtimeId(showtimeId);
        if (room == null) {
            throw new RoomException("Lỗi truy xuất: Không tìm thấy thông tin sơ đồ phòng hoặc ghế cho lịch chiếu này.");
        }
        return room;
    }

    @Override
    public boolean createRoom(Room room) {
        if (room == null) {
            throw new RoomException("Lỗi: Dữ liệu phòng chiếu cần tạo không được null.");
        }

        // 1. Kiểm tra giới hạn 20x20 cứng ở tầng Service (đề phòng vượt qua được Model)
        if (room.getTotalRows() > 20 || room.getTotalCols() > 20) {
            throw new RoomException("Lỗi kích thước: Số hàng và cột không được vượt quá 20!");
        }

        if (room.getStatus() == null || room.getStatus().isEmpty()) {
            room.setStatus("Active");
        }

        // 2. Kiểm tra trùng tên phòng và lưu vào DB
        try {
            if (roomRepo.checkRoomNameExistsForUpdate(room.getRoomName().trim(), 0)) {
                throw new RoomException("Tên phòng chiếu '" + room.getRoomName() + "' đã tồn tại! Vui lòng chọn tên khác.");
            }

            // Tiến hành gọi hàm Repository lưu vào DB ở đây...
            roomRepo.save(room);
            return true;

        } catch (DataAccessException e) {
            // 3. Xử lý lỗi Database mất kết nối hoặc truy vấn sai
            throw new RoomException("Lỗi hệ thống cơ sở dữ liệu: Không thể kết nối hoặc thực thi truy vấn!");
        }
    }

    @Override
    public boolean updateRoomStatus(int roomId, String newStatus) {
        try {
            if ("Maintenance".equalsIgnoreCase(newStatus)) {
                // 1. Kiểm tra vé đã bán trong 7 ngày tới (Nếu có sẽ quăng lỗi văng ra khung màu đỏ trên UI)
                int futureTickets = roomRepo.countFutureSoldTicketsByRoomId(roomId);
                if (futureTickets > 0) {
                    throw new RoomException("Chặn thao tác: Không thể chuyển phòng chiếu sang trạng thái Bảo trì vì hiện tại đang có " + futureTickets + " suất chiếu/ghế đã được khách hàng mua vé từ nay đến 7 ngày tới!");
                }

                // 2. Nếu không vướng vé, cho phép cập nhật trạng thái phòng sang Bảo trì
                boolean updated = roomRepo.updateRoomStatusInDB(roomId, "Maintenance");
                if (updated) {
                    // 3. ÉP TOÀN BỘ GHẾ sang "Maintenance" bất kể trạng thái hiện tại
                    seatRepo.updateAllSeatsByRoomId(roomId, "Maintenance");
                }
                return updated;
            } else if ("Active".equalsIgnoreCase(newStatus)) {
                boolean updated = roomRepo.updateRoomStatusInDB(roomId, "Active");
                if (updated) {
                    // Mở lại các ghế khi phòng hoạt động trở lại
                    seatRepo.updateAllSeatsByRoomId(roomId, "Available");
                }
                return updated;
            }
            return roomRepo.updateRoomStatusInDB(roomId, newStatus);
        } catch (DataAccessException e) {
            throw new RoomException("Lỗi hệ thống cơ sở dữ liệu: Không thể kết nối hoặc thực thi truy vấn!");
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateRoom(Room room) {
        if (room == null) {
            throw new RoomException("Lỗi: Dữ liệu phòng chiếu cập nhật không được null.");
        }

        if (room.getTotalRows() > 20 || room.getTotalCols() > 20) {
            throw new RoomException("Lỗi kích thước: Số hàng và cột không được vượt quá 20!");
        }

        Room existingRoom;
        try {
            existingRoom = roomRepo.findById(room.getId_Room());
        } catch (DataAccessException e) {
            throw new RoomException("Lỗi hệ thống cơ sở dữ liệu: Không thể kết nối hoặc thực thi truy vấn!");
        }

        if (existingRoom == null) {
            throw new RoomException("Lỗi truy xuất: Không tìm thấy phòng chiếu cần cập nhật.");
        }

        try {
            if (roomRepo.checkRoomNameExistsForUpdate(room.getRoomName().trim(), room.getId_Room())) {
                throw new RoomException("Tên phòng chiếu '" + room.getRoomName() + "' đã tồn tại! Vui lòng chọn tên khác.");
            }

            // XỬ LÝ KHI NGƯỜI DÙNG THAY ĐỔI CẢ KÍCH THƯỚC HÀNG/CỘT
            boolean isSizeChanged = (existingRoom.getTotalRows() != room.getTotalRows())
                    || (existingRoom.getTotalCols() != room.getTotalCols());

            if (isSizeChanged) {
                int futureTickets = roomRepo.countFutureSoldTicketsByRoomId(room.getId_Room());
                if (futureTickets > 0) {
                    throw new RoomException("Chặn thao tác: Không thể thay đổi số lượng hàng và cột (hoặc bảo trì)! Phòng này đang có " + futureTickets + " vé được mua tại các suất chiếu trong 7 ngày tới.");
                }

                boolean isRoomUpdated = roomRepo.update(room);
                if (isRoomUpdated) {
                    seatRepo.deleteAllSeatsByRoomId(room.getId_Room());

                    // Nếu khi lưu kích thước mới người dùng đổi luôn sang Bảo Trì
                    String targetSeatStatus = "Maintenance".equalsIgnoreCase(room.getStatus()) ? "Maintenance" : "Available";

                    for (int r = 1; r <= room.getTotalRows(); r++) {
                        for (int c = 1; c <= room.getTotalCols(); c++) {
                            Seat newSeat = new Seat();
                            newSeat.setRoomId(room.getId_Room());
                            newSeat.setRowPos(r);
                            newSeat.setColPos(c);
                            newSeat.setStatus(targetSeatStatus);
                            char rowChar = (char) ('A' + (r - 1));
                            newSeat.setSeatName(String.valueOf(rowChar) + c);
                            seatRepo.insertSeat(newSeat);
                        }
                    }
                }
                return isRoomUpdated;
            }

            // XỬ LÝ CHỈ ĐỔI TRẠNG THÁI PHÒNG (KHÔNG ĐỔI KÍCH THƯỚC)
            if (!existingRoom.getStatus().equalsIgnoreCase(room.getStatus())) {
                if ("Maintenance".equalsIgnoreCase(room.getStatus())) {
                    int futureSoldTickets = roomRepo.countFutureSoldTicketsByRoomId(room.getId_Room());
                    if (futureSoldTickets > 0) {
                        throw new RoomException("Không thể chuyển phòng '" + room.getRoomName() + "' sang trạng thái Bảo trì vì hiện tại đang có " + futureSoldTickets + " ghế thuộc suất chiếu đã được khách hàng mua vé từ nay đến 7 ngày tới!");
                    }
                    // Nếu hợp lệ, ép TOÀN BỘ CÁC GHẾ sang trạng thái bảo trì
                    seatRepo.updateAllSeatsByRoomId(room.getId_Room(), "Maintenance");
                } else if ("Active".equalsIgnoreCase(room.getStatus())) {
                    // Nếu phòng Active trở lại, ép toàn bộ ghế sang Available
                    seatRepo.updateAllSeatsByRoomId(room.getId_Room(), "Available");
                }
            }

            roomRepo.update(room);
            return true;

        } catch (DataAccessException e) {
            throw new RoomException("Lỗi hệ thống cơ sở dữ liệu: Không thể kết nối hoặc thực thi truy vấn!");
        }
    }

    @Override
    public boolean deleteRoom(int roomId) {
        try {
            if (roomRepo.findById(roomId) == null) {
                throw new RoomException("Lỗi truy xuất: Không thể xóa! Không tìm thấy phòng chiếu yêu cầu.");
            }

            roomRepo.deleteById(roomId);
            return true;
        } catch (DataAccessException e) {
            throw new RoomException("Lỗi hệ thống cơ sở dữ liệu: Không thể kết nối hoặc thực thi truy vấn!");
        }
    }

    @Override
    public List<Seat> getSeatsByRoomId(int roomId) {
        if (roomId <= 0) {
            throw new RoomException("Lỗi: ID phòng không hợp lệ.");
        }
        return seatRepo.findByRoomId(roomId);
    }

    @Override
    public boolean updateSeatStatus(int seatId, String status) {
        try {
            Seat seat = seatRepo.findById(seatId);
            if (seat == null) {
                throw new RoomException("Lỗi: Ghế không tồn tại!");
            }

            Room room = roomRepo.findById(seat.getRoomId());
            if (room != null && "Maintenance".equalsIgnoreCase(room.getStatus())) {
                throw new RoomException("Chặn thao tác: Phòng chiếu đang ở trạng thái BẢO TRÌ, không thể thay đổi trạng thái ghế!");
            }

            if (!"Available".equalsIgnoreCase(status)) {
                int futureTickets = seatRepo.countFutureSoldTicketsBySeatId(seatId);
                if (futureTickets > 0) {
                    throw new RoomException("Chặn thao tác: Ghế " + seat.getSeatName() + " đã có vé được mua trong 7 ngày tới!");
                }
            }

            return seatRepo.updateSeatStatus(seatId, status.trim());
        } catch (DataAccessException e) {
            throw new RoomException("Lỗi hệ thống cơ sở dữ liệu: Không thể kết nối hoặc thực thi truy vấn!");
        }
    }
    // Trong RoomServiceImpl.java

    @Override
    public int countFutureSoldTickets(int roomId) {
        return roomRepo.countFutureSoldTicketsByRoomId(roomId);
    }
    @Override
    public Room findRoomWithSeatStatusByShowtimeId(int showtimeId) {
        if (showtimeId <= 0) {
            throw new IllegalArgumentException("Lỗi: Mã suất chiếu không hợp lệ!");
        }
        // Gọi thẳng hàm đã viết sẵn trong RoomRepository
        return roomRepo.findRoomWithSeatStatusByShowtimeId(showtimeId);
    }
}
