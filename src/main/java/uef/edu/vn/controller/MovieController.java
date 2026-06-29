package uef.edu.vn.controller;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import uef.edu.vn.model.Movie;
import uef.edu.vn.service.MovieService;
import java.util.List;
import org.springframework.validation.BindingResult;

@Controller
@RequestMapping("/admin")
public class MovieController {

    private final MovieService movieService;
    private final String path = "/WEB-INF/views/admin/";
    private final String pathview = "layout/admin-layout/main";

    @Autowired
    public MovieController(MovieService movieService) {
        this.movieService = movieService;
    }

    @GetMapping("/movies")
    public String showMovies(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String genre,
            @RequestParam(required = false) String status,
            Model model) {
        try {
            List<Movie> movies = movieService.searchAndFilterMovies(keyword, genre, status);
            model.addAttribute("movieList", movies);
            
            model.addAttribute("currentKeyword", keyword);
            model.addAttribute("currentGenre", genre);
            model.addAttribute("currentStatus", status);
        } catch (Exception e) {
            model.addAttribute("errorMessage", "Lỗi tải danh sách phim: " + e.getMessage());
        }
        model.addAttribute("view", "movies");
        model.addAttribute("body", path + "movies.jsp");
        return pathview;
    }

   // Nhớ import thêm 2 thư viện này ở đầu file nhé:
    // import javax.validation.Valid;
    // import org.springframework.validation.BindingResult;

    @PostMapping("/movies/save")
    public String saveMovie(@Valid @ModelAttribute Movie movie, BindingResult bindingResult, RedirectAttributes redirectAttributes) {
        
        // 🛡️ TRẠM 2: CHẶN Ở CONTROLLER/MODEL (@Valid)
        if (bindingResult.hasErrors()) {
            // Lấy câu thông báo lỗi đầu tiên trong Movie.java (ví dụ: "Tên phim không được để trống")
            String errorMsg = bindingResult.getAllErrors().get(0).getDefaultMessage();
            redirectAttributes.addFlashAttribute("errorMessage", errorMsg);
            redirectAttributes.addFlashAttribute("hasModalError", true); // Cờ ra lệnh mở lại Modal
            redirectAttributes.addFlashAttribute("movie", movie); // Tùy chọn: Giữ lại data người dùng vừa nhập
            return "redirect:/admin/movies";
        }

        // 🛡️ TRẠM 3: CHẶN Ở SERVICE (Logic nghiệp vụ)
        try {
            if (movie.getId_Movie() > 0) {
                movieService.updateMovie(movie);
                redirectAttributes.addFlashAttribute("successMessage", "Cập nhật phim thành công!");
            } else {
                movieService.createMovie(movie);
                redirectAttributes.addFlashAttribute("successMessage", "Thêm phim mới thành công!");
            }
        } catch (IllegalArgumentException e) {
            // Bắt lỗi trùng tên, lỗi năm sản xuất...
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            redirectAttributes.addFlashAttribute("hasModalError", true); // Có lỗi là phải mở Modal
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            redirectAttributes.addFlashAttribute("hasModalError", true);
        }
        
        return "redirect:/admin/movies";
    }

    @PostMapping("/movies/delete")
    public String deleteMovie(@RequestParam("id") int movieId, RedirectAttributes redirectAttributes) {
        try {
            movieService.deleteMovie(movieId);
            redirectAttributes.addFlashAttribute("successMessage", "✅ Xóa phim thành công!");
        } catch (uef.edu.vn.exception.MovieException e) {
            redirectAttributes.addFlashAttribute("errorMessage", "❌ Không thể xóa bộ phim này: " + e.getMessage());
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("errorMessage", "❌ Thao tác thất bại! Phim này đã có lịch sử dữ liệu liên kết quan trọng trên hệ thống.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "❌ Lỗi hệ thống: " + e.getMessage());
        }
        return "redirect:/admin/movies";
    }
    
    @GetMapping("/movies/detail")
    public String showMovieDetails(@RequestParam("id") int id, Model model, RedirectAttributes redirectAttributes) {
        try {
            Movie movie = movieService.getMovieById(id);
            
            model.addAttribute("movie", movie);
            model.addAttribute("view", "movies"); 
            model.addAttribute("body", path + "movie_detail.jsp");
            
            return pathview;
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Không tìm thấy thông tin phim hoặc có lỗi xảy ra!");
            return "redirect:/admin/movies";
        }
    }
}