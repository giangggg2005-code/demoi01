package uef.edu.vn.model;

import jakarta.validation.constraints.*;
import java.util.Calendar;
import java.sql.Date;
import java.util.List;
import uef.edu.vn.model.Showtime;

public class Movie {

    @Min(value = 0, message = "ID phim không được là số âm")
    private int id_Movie;

    @NotBlank(message = "Tên phim không được để trống")
    @Size(min = 1, max = 150, message = "Tên phim phải từ 1 đến 150 ký tự")
    private String title;

    @NotBlank(message = "Mô tả phim không được để trống")
    @Size(max = 1000, message = "Mô tả phim quá dài (Tối đa 1000 ký tự)")
    private String description;

    @NotBlank(message = "Tên đạo diễn không được để trống")
    @Size(max = 100, message = "Tên đạo diễn không được vượt quá 100 ký tự")
    private String director;

    @Positive(message = "Thời lượng phim phải lớn hơn 0 phút")
    @Max(value = 600, message = "Thời lượng phim không thực tế (Tối đa 600 phút)")
    private int duration;

    @NotBlank(message = "Thông tin diễn viên không được để trống")
    @Size(max = 500, message = "Danh sách diễn viên không được vượt quá 500 ký tự")
    private String cast;

    @NotBlank(message = "Ngôn ngữ phim không được để trống")
    @Size(max = 50, message = "Tên ngôn ngữ không được vượt quá 50 ký tự")
    private String language;

    @NotNull(message = "Ngày khởi chiếu không được để trống")
    private Date releaseDate;

    @NotBlank(message = "Thể loại phim không được để trống")
    @Size(max = 100, message = "Thể loại phim không được vượt quá 100 ký tự")
    private String genre;

    @Min(value = 1888, message = "Năm sản xuất không hợp lệ (Bộ phim đầu tiên của nhân loại ra đời năm 1888)")
    private int productionYear;

    @NotBlank(message = "Nhãn kiểm duyệt (Censorship) không được để trống")
    @Size(max = 10, message = "Nhãn kiểm duyệt quá dài (Tối đa 10 ký tự, ví dụ: P, T13, T16, T18)")
    private String censorship;

    @NotBlank(message = "Đường dẫn ảnh Poster không được để trống")
    @Size(max = 500, message = "Đường dẫn Poster quá dài để lưu trữ (Tối đa 500 ký tự)")
    private String posterUrl;

    @Size(max = 500, message = "Đường dẫn Trailer quá dài để lưu trữ (Tối đa 500 ký tự)")
    private String trailerUrl;

    @NotBlank(message = "Định dạng/Thể loại phụ (Category) không được để trống")
    @Size(max = 30, message = "Định dạng phim quá dài (Tối đa 30 ký tự, ví dụ: 2D, 3D, IMAX)")
    private String category;

    @PositiveOrZero(message = "Giá vé cơ bản phải lớn hơn hoặc bằng 0")
    @Digits(integer = 8, fraction = 2, message = "Giá vé không hợp lệ hoặc sai định dạng số tiền")
    private double basePrice;

    @NotBlank(message = "Trạng thái phim không được để trống")
    @Size(max = 50, message = "Trạng thái quá dài (Tối đa 50 ký tự, ví dụ: Showing, Coming Soon, Ended)")
    private String status;
    private List<Showtime> showtimes;

    public List<Showtime> getShowtimes() {
        return showtimes;
    }

    public void setShowtimes(List<Showtime> showtimes) {
        this.showtimes = showtimes;
    }

    @AssertTrue(message = "Ngoại lệ logic: Ngày khởi chiếu không thể xảy ra trước Năm sản xuất của bộ phim!")
    public boolean isTimelineValid() {
        if (this.releaseDate != null) {
            Calendar cal = Calendar.getInstance();
            cal.setTime(this.releaseDate);
            int yearOfRelease = cal.get(Calendar.YEAR);
            return yearOfRelease >= this.productionYear;
        }
        return true;
    }

    @AssertTrue(message = "Ngoại lệ logic: Năm sản xuất không được vượt quá năm hiện tại quá xa!")
    public boolean isProductionYearRealistic() {
        int currentYear = Calendar.getInstance().get(Calendar.YEAR);
        return this.productionYear <= (currentYear + 2) && this.productionYear >= 1888;
    }

    public Movie() {
        this.id_Movie = 0;
        this.title = "";
        this.description = "";
        this.director = "";
        this.duration = 0;
        this.cast = "";
        this.language = "Vietnamese";
        this.releaseDate = new Date(System.currentTimeMillis());
        this.genre = "";
        this.productionYear = Calendar.getInstance().get(Calendar.YEAR);
        this.censorship = "P";
        this.posterUrl = "default_poster.png";
        this.trailerUrl = "";
        this.category = "";
        this.basePrice = 0.0;
        this.status = "Coming Soon";
    }

    public Movie(int id_Movie, String title, String description, String director, int duration,
            String cast, String language, Date releaseDate, String genre, int productionYear,
            String censorship, String posterUrl, String trailerUrl, String category, double basePrice, String status) {
        this.id_Movie = id_Movie;
        this.title = title;
        this.description = description;
        this.director = director;
        this.duration = duration;
        this.cast = cast;
        this.language = language;
        this.releaseDate = releaseDate;
        this.genre = genre;
        this.productionYear = productionYear;
        this.censorship = censorship;
        this.posterUrl = posterUrl;
        this.trailerUrl = trailerUrl;
        this.category = category;
        this.basePrice = basePrice;
        this.status = status;
    }

    public int getId_Movie() {
        return id_Movie;
    }

    public void setId_Movie(int id_Movie) {
        this.id_Movie = id_Movie;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDirector() {
        return director;
    }

    public void setDirector(String director) {
        this.director = director;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getCast() {
        return cast;
    }

    public void setCast(String cast) {
        this.cast = cast;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public Date getReleaseDate() {
        return releaseDate;
    }

    public void setReleaseDate(Date releaseDate) {
        this.releaseDate = releaseDate;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public int getProductionYear() {
        return productionYear;
    }

    public void setProductionYear(int productionYear) {
        this.productionYear = productionYear;
    }

    public String getCensorship() {
        return censorship;
    }

    public void setCensorship(String censorship) {
        this.censorship = censorship;
    }

    public String getPosterUrl() {
        return posterUrl;
    }

    public void setPosterUrl(String posterUrl) {
        this.posterUrl = posterUrl;
    }

    public String getTrailerUrl() {
        return trailerUrl;
    }

    public void setTrailerUrl(String trailerUrl) {
        this.trailerUrl = trailerUrl;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public double getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}