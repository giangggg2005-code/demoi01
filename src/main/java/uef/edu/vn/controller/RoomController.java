package uef.edu.vn.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.validation.Valid;

import uef.edu.vn.exception.RoomException;
import uef.edu.vn.model.Room;
import uef.edu.vn.model.Seat;
import uef.edu.vn.model.Showtime;
import uef.edu.vn.service.RoomService;

import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
public class RoomController {

    private final RoomService roomService;

    @Autowired
    public RoomController(RoomService roomService) {
        this.roomService = roomService;
    }

    private final String path = "/WEB-INF/views/admin/";
    private final String pathview = "layout/admin-layout/main";

    // =========================================================================
    // HÀM HỖ TRỢ HIỂN THỊ THÔNG BÁO CHO TOAST NOTIFICATION TRÊN GIAO DIỆN
    // =========================================================================
    private void addErrorMessage(RedirectAttributes redirectAttributes, String message) {
        redirectAttributes.addFlashAttribute("systemErrorMsg", message);
        // Giữ lại errorMsg nếu JSP cũ cần dùng biến này để validate form
        redirectAttributes.addFlashAttribute("errorMsg", message); 
    }

    private void addSuccessMessage(RedirectAttributes redirectAttributes, String message) {
        redirectAttributes.addFlashAttribute("successMsg", message);
    }

    @GetMapping("/rooms")
    public String listRooms(Model model) {
        List<Room> roomList = roomService.getAllRooms();
        model.addAttribute("roomList", roomList);
        model.addAttribute("view", "rooms");
        model.addAttribute("body", path + "rooms.jsp");
        return pathview;
    }

    // 1. XỬ LÝ LƯU HOẶC CẬP NHẬT QUA FORM
    @PostMapping("/rooms/save")
    public String saveRoom(@Valid @ModelAttribute Room room,
            BindingResult bindingResult,
            @RequestParam(value = "id", required = false) Integer id,
            @RequestParam(value = "roomId", required = false) Integer roomId,
            RedirectAttributes redirectAttributes) {
        try {
            if (room.getId_Room() == 0) {
                if (id != null) {
                    room.setId_Room(id);
                } else if (roomId != null) {
                    room.setId_Room(roomId);
                }
            }

            List<FieldError> actualErrors = bindingResult.getFieldErrors().stream()
                    .filter(err -> !("roomName".equals(err.getField()) && "Pattern".equals(err.getCode())))
                    .collect(Collectors.toList());

            if (!actualErrors.isEmpty() || bindingResult.hasGlobalErrors()) {
                String errorMsg = actualErrors.stream()
                        .map(FieldError::getDefaultMessage)
                        .collect(Collectors.joining("<br/>"));
                String globalErrors = bindingResult.getGlobalErrors().stream()
                        .map(err -> err.getDefaultMessage())
                        .collect(Collectors.joining("<br/>"));
                if (!globalErrors.isEmpty()) {
                    errorMsg = errorMsg.isEmpty() ? globalErrors : errorMsg + "<br/>" + globalErrors;
                }

                addErrorMessage(redirectAttributes, errorMsg);
                return room.getId_Room() == 0 ? "redirect:/admin/rooms" : "redirect:/admin/rooms/detail?id=" + room.getId_Room();
            }

            if (room.getId_Room() == 0) {
                roomService.createRoom(room);
                addSuccessMessage(redirectAttributes, "Thêm phòng chiếu '" + room.getRoomName() + "' thành công!");
            } else {
                // Nếu đổi trạng thái sang bảo trì bị chặn do có vé, hàm updateRoom sẽ quăng RoomException
                roomService.updateRoom(room);
                addSuccessMessage(redirectAttributes, "Cập nhật phòng chiếu '" + room.getRoomName() + "' thành công!");
            }
        } catch (RoomException e) {
            // BẮT LỖI NGHIỆP VỤ (VÉ ĐÃ BÁN, TRÙNG TÊN) -> Hiển thị bảng màu đỏ trên UI
            addErrorMessage(redirectAttributes, e.getMessage());
            return room.getId_Room() == 0 ? "redirect:/admin/rooms" : "redirect:/admin/rooms/detail?id=" + room.getId_Room();
        } catch (Exception e) {
            addErrorMessage(redirectAttributes, "Đã xảy ra lỗi hệ thống không xác định: " + e.getMessage());
            return "redirect:/admin/rooms";
        }
        return "redirect:/admin/rooms";
    }

    // 2. XỬ LÝ CẬP NHẬT QUA AJAX (Nếu thành công hiển thị Modal, nếu lỗi quăng lỗi ra JS xử lý)
    @PostMapping(value = "/rooms/update", produces = "text/plain;charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> updateRoomAjax(@Valid @ModelAttribute Room room,
            BindingResult bindingResult,
            @RequestParam(value = "id_Room", required = false) Integer id_Room,
            @RequestParam(value = "id", required = false) Integer id,
            @RequestParam(value = "roomId", required = false) Integer roomId) {
        try {
            if (room.getId_Room() == 0) {
                if (id_Room != null) {
                    room.setId_Room(id_Room);
                } else if (id != null) {
                    room.setId_Room(id);
                } else if (roomId != null) {
                    room.setId_Room(roomId);
                }
            }

            if (room.getId_Room() <= 0) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                        "Không tìm thấy ID phòng chiếu để cập nhật (" + room.getId_Room() + ")."
                );
            }

            List<FieldError> actualErrors = bindingResult.getFieldErrors().stream()
                    .filter(err -> !("roomName".equals(err.getField()) && "Pattern".equals(err.getCode())))
                    .collect(Collectors.toList());

            if (!actualErrors.isEmpty() || bindingResult.hasGlobalErrors()) {
                String errorMsg = actualErrors.stream()
                        .map(FieldError::getDefaultMessage)
                        .collect(Collectors.joining(", "));
                String globalErrors = bindingResult.getGlobalErrors().stream()
                        .map(err -> err.getDefaultMessage())
                        .collect(Collectors.joining(", "));
                if (!globalErrors.isEmpty()) {
                    errorMsg = errorMsg.isEmpty() ? globalErrors : errorMsg + ", " + globalErrors;
                }
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorMsg);
            }

            // Gọi service, nếu vướng vé sẽ quăng RoomException
            boolean isUpdated = roomService.updateRoom(room);
            if (isUpdated) {
                // THÀNH CÔNG: Sẽ kích hoạt mở "khung cửa sổ cập nhật thành công" bằng JS dưới UI
                return ResponseEntity.ok("Cập nhật phòng chiếu và sơ đồ ghế thành công!");
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Không thể cập nhật thông tin phòng chiếu.");
            }
        } catch (RoomException e) {
            // LỖI: Chặn thao tác do có vé (Trả message cụ thể về cho AJAX JS hiển thị)
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Lỗi hệ thống: " + e.getMessage());
        }
    }

    // 3. XỬ LÝ ĐỔI STATUS NHANH QUA NÚT TOGGLE / AJAX
    @PostMapping(value = "/rooms/update-room-status", produces = "text/plain;charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> updateRoomStatus(@RequestParam("id") int id, @RequestParam("status") String status) {
        try {
            boolean isUpdated = roomService.updateRoomStatus(id, status);
            if (isUpdated) {
                return ResponseEntity.ok("success");
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Không thể cập nhật trạng thái phòng.");
            }
        } catch (RoomException e) {
            // BẮT LỖI TRỰC TIẾP: Trả thông báo vướng vé 7 ngày tới về cho UI
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Lỗi hệ thống: " + e.getMessage());
        }
    }

    @PostMapping(value = "/rooms/delete-ajax", produces = "text/plain;charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> deleteRoomAjax(@RequestParam("id") int id) {
        try {
            roomService.deleteRoom(id);
            return ResponseEntity.ok("Xóa phòng chiếu thành công!");
        } catch (RoomException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(
                    "Không thể xóa phòng chiếu này vì sơ đồ ghế trong phòng đã có lịch sử giao dịch mua vé của khách hàng!"
            );
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage() != null ? e.getMessage().toLowerCase() : "";

            if (errorMsg.contains("foreign key") || errorMsg.contains("constraint") || errorMsg.contains("sql")) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(
                        "Không thể xóa phòng chiếu này vì sơ đồ ghế trong phòng đã có lịch sử giao dịch mua vé của khách hàng!"
                );
            }

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                    "Đã xảy ra lỗi hệ thống trong quá trình xử lý. Vui lòng thử lại sau hoặc liên hệ quản trị viên!"
            );
        }
    }

    @GetMapping("/rooms/delete")
    public String deleteRoom(@RequestParam("id") int id, RedirectAttributes redirectAttributes) {
        try {
            roomService.deleteRoom(id);
            addSuccessMessage(redirectAttributes, "Xóa phòng chiếu thành công!");
        } catch (RoomException e) {
            addErrorMessage(redirectAttributes, e.getMessage());
        } catch (Exception e) {
            addErrorMessage(redirectAttributes, "Không thể xóa phòng chiếu do có ràng buộc dữ liệu vé đặt hoặc lỗi hệ thống.");
        }
        return "redirect:/admin/rooms";
    }

    @GetMapping("/rooms/detail")
    public String roomDetail(@RequestParam("id") int id,
            @RequestParam(value = "mode", defaultValue = "edit") String mode,
            Model model) {
        Room room = roomService.getRoomById(id);
        List<Seat> seats = roomService.getSeatsByRoomId(id);
        List<Showtime> activeShowtimes = roomService.getActiveShowtimesForRoom(id);

        model.addAttribute("activeShowtimes", activeShowtimes);
        model.addAttribute("room", room);
        model.addAttribute("seats", seats);
        model.addAttribute("mode", mode);
        model.addAttribute("view", "rooms");
        model.addAttribute("body", path + "room_detail.jsp");
        return pathview;
    }

    @PostMapping(value = "/rooms/update-seat", produces = "text/plain;charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> updateSeat(@RequestParam("id") int id, @RequestParam("status") String status) {
        try {
            boolean isUpdated = roomService.updateSeatStatus(id, status);
            if (isUpdated) {
                return ResponseEntity.ok("success");
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Không thể cập nhật ghế");
            }
        } catch (RoomException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Lỗi Server");
        }
    }

    // Nơi xử lý tập trung tất cả các ngoại lệ RoomException lọt qua các tầng
    @ExceptionHandler(uef.edu.vn.exception.RoomException.class)
    public String handleRoomException(uef.edu.vn.exception.RoomException ex, RedirectAttributes redirectAttributes) {
        // Chỉ lấy đúng câu thông báo cụ thể từ Service và đẩy ra Khung Toast
        addErrorMessage(redirectAttributes, ex.getMessage());
        return "redirect:/admin/rooms";
    }

    @GetMapping("/rooms/check-future-tickets/{id}")
    @ResponseBody
    public ResponseEntity<Integer> checkFutureTickets(@PathVariable("id") int roomId) {
        try {
            int count = roomService.countFutureSoldTickets(roomId); // Bạn nhớ thêm hàm này vào Interface RoomService nhé
            return ResponseEntity.ok(count);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(0);
        }
    }
}