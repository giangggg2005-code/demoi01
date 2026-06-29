package uef.edu.vn.controller;

import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.http.HttpSession;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import uef.edu.vn.model.Booking;
import uef.edu.vn.model.Movie;
import uef.edu.vn.model.Showtime;
import uef.edu.vn.model.User;
import uef.edu.vn.service.BookingService;
import uef.edu.vn.service.CustomerService;
import uef.edu.vn.service.MovieService;

@Controller
@RequestMapping("/customer")
public class CustomerViewController {

    private final CustomerService customerService;
    private final BookingService bookingService;
    private final MovieService movieService;

    @Autowired
    public CustomerViewController(CustomerService customerService, BookingService bookingService, MovieService movieService) {
        this.customerService = customerService;
        this.bookingService = bookingService;
        this.movieService = movieService;
    }

    @GetMapping({"", "/", "/home"})
    public String showCustomerHome(Model model) {
        List<Map<String, Object>> dateTabs = new ArrayList<>();
        java.text.SimpleDateFormat dayFormat = new java.text.SimpleDateFormat("dd/MM");
        java.text.SimpleDateFormat labelFormat = new java.text.SimpleDateFormat("EEE", new java.util.Locale("vi", "VN"));
        java.text.SimpleDateFormat dbFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");

        Calendar cal = Calendar.getInstance();
        java.sql.Date todaySql = new java.sql.Date(cal.getTimeInMillis());

        for (int i = 0; i < 7; i++) {
            Map<String, Object> tab = new HashMap<>();
            String dbDateStr = dbFormat.format(cal.getTime());
            String dayStr = dayFormat.format(cal.getTime());
            String dayLabel = (i == 0) ? "Hôm nay" : labelFormat.format(cal.getTime());

            tab.put("dbDate", dbDateStr);
            tab.put("dayStr", dayStr);
            tab.put("dayLabel", dayLabel);

            dateTabs.add(tab);
            cal.add(Calendar.DAY_OF_YEAR, 1);
        }
        model.addAttribute("dateTabs", dateTabs);

        List<Movie> movieList = movieService.getMoviesWithShowtimesForDate(todaySql);
        model.addAttribute("movieList", movieList);

        if (movieList != null && !movieList.isEmpty()) {
            model.addAttribute("heroMovie", movieList.get(0));
        }

        model.addAttribute("totalMovies", movieList != null ? movieList.size() : 0);
        model.addAttribute("totalRooms", 5);
        model.addAttribute("totalMembers", customerService.getTotalCustomerCount());

        return "customer/home";
    }

    @GetMapping("/api/showtimes")
    @ResponseBody
    public List<Map<String, Object>> getShowtimesByJson(@RequestParam("movieId") int movieId, @RequestParam("date") String dateStr) {
        List<Map<String, Object>> responseData = new ArrayList<>();
        try {
            java.sql.Date selectedDate = java.sql.Date.valueOf(dateStr);
            List<Showtime> showtimes = movieService.getShowtimesByMovieAndDate(movieId, selectedDate);
            
            for (Showtime st : showtimes) {
                Map<String, Object> map = new HashMap<>();
                map.put("id_Showtime", st.getId_Showtime());
                map.put("roomId", st.getRoomId());
                
                String timeStr = "";
                if (st.getStartTime() != null) {
                    timeStr = st.getStartTime().toString();
                    if (timeStr.length() >= 5) {
                        timeStr = timeStr.substring(0, 5);
                    }
                }
                map.put("startTime", timeStr);
                
                responseData.add(map);
            }
            return responseData;
        } catch (Exception e) {
            e.printStackTrace();
            return responseData;
        }
    }

    @GetMapping("/profile")
    public String showCustomerProfile(HttpSession session, Model model) {
        User loggedInUser = (User) session.getAttribute("loggedInUser");
        if (loggedInUser == null) {
            return "redirect:/login-customer";
        }

        try {
            User customer = customerService.getCustomerById(loggedInUser.getId_User());
            List<Booking> bookingList = bookingService.getBookingHistoryByUser(loggedInUser.getId_User());

            model.addAttribute("customer", customer);
            model.addAttribute("bookingList", bookingList != null ? bookingList : new ArrayList<>());
            return "customer/profile";
        } catch (Exception e) {
            model.addAttribute("error", e.getMessage());
            return "redirect:/login-customer";
        }
    }
}