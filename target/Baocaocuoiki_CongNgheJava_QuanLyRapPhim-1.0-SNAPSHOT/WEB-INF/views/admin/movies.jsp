<%-- views/admin/movies.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-4">
    <div>
        <h2 class="text-xl font-black text-white uppercase tracking-wider">Quản Lý Phim</h2>
        <p class="text-xs text-gray-500">Quản lý danh mục phim, thông tin và trạng thái trình chiếu tại rạp</p>
    </div>
    <div class="flex gap-3">
        <button onclick="openAddMovieSystem()" class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-xl text-sm font-bold shadow-lg shadow-red-600/20 transition flex items-center">
            <i class="fas fa-plus mr-2"></i> Thêm phim mới
        </button>
    </div>
</div>

<%-- KHU VỰC HIỂN THỊ THÔNG BÁO LỖI (BẮT TỪ BACKEND) --%>
<c:if test="${not empty errorMessage}">
    <div class="bg-red-500/10 border border-red-500 text-red-500 px-4 py-3 rounded-xl mb-4 text-sm font-bold">
        <i class="fas fa-exclamation-triangle mr-2"></i> ${errorMessage}
    </div>
</c:if>
<c:if test="${not empty successMessage}">
    <div class="bg-green-500/10 border border-green-500 text-green-500 px-4 py-3 rounded-xl mb-4 text-sm font-bold">
        <i class="fas fa-check-circle mr-2"></i> ${successMessage}
    </div>
</c:if>

<div class="glass-card border border-gray-800 rounded-2xl overflow-hidden mb-6">
    <div class="p-4 border-b border-gray-800 flex flex-col lg:flex-row justify-between items-center bg-[#161616] gap-4">
        <h3 class="text-sm font-bold text-white uppercase whitespace-nowrap"><i class="fas fa-film text-red-500 mr-2"></i>Danh sách phim</h3>

        <%-- BỘ LỌC TÌM KIẾM ĐẨY XUỐNG BACKEND --%>
        <form action="${pageContext.request.contextPath}/admin/movies" method="GET" id="searchForm" class="flex flex-col md:flex-row gap-3 w-full lg:w-auto m-0">
            <div class="relative w-full md:w-64">
                <input type="text" name="keyword" value="${currentKeyword}" placeholder="Nhập từ khóa rồi ấn Enter..." class="bg-[#0b0c10] border border-gray-800 text-gray-300 text-xs rounded-lg px-4 py-2 w-full pr-10 focus:outline-none focus:border-red-600 transition">
                <button type="submit" class="absolute right-3 top-2 text-gray-500 hover:text-white transition focus:outline-none"><i class="fas fa-search"></i></button>
            </div>

            <%-- ĐỦ TẤT CẢ THỂ LOẠI THỰC TẾ TRONG DATABASE --%>
            <select name="genre" onchange="document.getElementById('searchForm').submit();"
                    class="bg-[#0b0c10] border border-gray-800 text-gray-300 text-xs rounded-lg px-4 py-2 focus:outline-none focus:border-red-600 transition max-w-[160px]">
                <option value="all" ${currentGenre == 'all' ? 'selected' : ''}>Tất cả thể loại</option>
                <option value="Hành động" ${currentGenre == 'Hành động' ? 'selected' : ''}>Hành động</option>
                <option value="Tâm lý" ${currentGenre == 'Tâm lý' ? 'selected' : ''}>Tâm lý</option>
                <option value="Gia định" ${currentGenre == 'Gia đình' ? 'selected' : ''}>Gia đình</option>
                <option value="Hài hước" ${currentGenre == 'Hài hước' ? 'selected' : ''}>Hài hước</option>
                <option value="Hài" ${currentGenre == 'Hài' ? 'selected' : ''}>Hài</option>
                <option value="Kinh dị" ${currentGenre == 'Kinh dị' ? 'selected' : ''}>Kinh dị</option>
                <option value="Hài kinh dị" ${currentGenre == 'Hài kinh dị' ? 'selected' : ''}>Hài kinh dị</option>
                <option value="Hoạt hình" ${currentGenre == 'Hoạt hình' ? 'selected' : ''}>Hoạt hình</option>
                <option value="Hoạt hình/Hành động" ${currentGenre == 'Hoạt hình/Hành động' ? 'selected' : ''}>Hoạt hình/Hành động</option>
                <option value="Viễn tưởng" ${currentGenre == 'Viễn tưởng' ? 'selected' : ''}>Viễn tưởng</option>
                <option value="Phiêu lưu" ${currentGenre == 'Phiêu lưu' ? 'selected' : ''}>Phiêu lưu</option>
                <option value="Cổ trang" ${currentGenre == 'Cổ trang' ? 'selected' : ''}>Cổ trang</option>
                <option value="Tình cảm" ${currentGenre == 'Tình cảm' ? 'selected' : ''}>Tình cảm</option>
                <option value="Lãng mạn" ${currentGenre == 'Lãng mạn' ? 'selected' : ''}>Lãng mạn</option>
                <option value="Kỳ ảo" ${currentGenre == 'Kỳ ảo' ? 'selected' : ''}>Kỳ ảo</option>
                <option value="Nhạc kịch" ${currentGenre == 'Nhạc kịch' ? 'selected' : ''}>Nhạc kịch</option>
                <option value="Nghệ thuật" ${currentGenre == 'Nghệ thuật' ? 'selected' : ''}>Nghệ thuật</option>
                <option value="Trinh thám" ${currentGenre == 'Trinh thám' ? 'selected' : ''}>Trinh thám</option>
                <option value="Giật gân" ${currentGenre == 'Giật gân' ? 'selected' : ''}>Giật gân</option>
                <option value="Drama" ${currentGenre == 'Drama' ? 'selected' : ''}>Drama</option>
                <option value="Võ thuật" ${currentGenre == 'Võ thuật' ? 'selected' : ''}>Võ thuật</option>
            </select>

            <%-- CHUẨN 3 TRẠNG THÁI TRONG DB: Showing, Coming Soon, Closed --%>
            <select name="status" onchange="document.getElementById('searchForm').submit();"
                    class="bg-[#0b0c10] border border-gray-800 text-gray-300 text-xs rounded-lg px-4 py-2 focus:outline-none focus:border-red-600 transition">
                <option value="all" ${currentStatus == 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                <option value="Showing" ${currentStatus == 'Showing' ? 'selected' : ''}>Đang chiếu (Showing)</option>
                <option value="Coming Soon" ${currentStatus == 'Coming Soon' ? 'selected' : ''}>Sắp chiếu (Coming Soon)</option>
                <option value="Closed" ${currentStatus == 'Closed' ? 'selected' : ''}>Đã ngưng chiếu (Closed)</option>
            </select>
        </form>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-left text-sm whitespace-nowrap">
            <thead class="text-xs text-gray-400 uppercase bg-[#0e0f14] border-b border-gray-800">
                <tr>
                    <th class="p-4 font-semibold text-center w-16">Poster</th>
                    <th class="p-4 font-semibold">Tên phim</th>
                    <th class="p-4 font-semibold">Thể loại</th>
                    <th class="p-4 font-semibold text-center">Thời lượng</th>
                    <th class="p-4 font-semibold text-center">Năm KH</th>
                    <th class="p-4 font-semibold text-center">Trạng thái</th>
                    <th class="p-4 font-semibold text-center">Hành động</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-800/50">
                <c:forEach var="movie" items="${movieList}">
                    <tr class="hover:bg-white/[0.02] transition">
                        <td class="p-4 text-center">
                            <img src="${movie.posterUrl}" alt="Poster" class="w-12 h-16 object-cover rounded shadow-md border border-gray-700 mx-auto">
                        </td>
                        <td class="p-4 font-bold text-white">${movie.title}</td>
                        <td class="p-4 text-gray-400">${movie.genre}</td>
                        <td class="p-4 text-center text-gray-400">${movie.duration} phút</td>

                        <td class="p-4 text-center text-gray-400">
                            <fmt:formatDate value="${movie.releaseDate}" pattern="yyyy" />
                        </td>

                        <td class="p-4 text-center">
                            <c:choose>
                                <c:when test="${movie.status == 'Showing'}">
                                    <span class="px-2 py-1 bg-green-500/10 text-green-500 border border-green-500/20 rounded-lg text-[10px] font-bold uppercase">Showing</span>
                                </c:when>
                                <c:when test="${movie.status == 'Coming Soon'}">
                                    <span class="px-2 py-1 bg-amber-500/10 text-amber-500 border border-amber-500/20 rounded-lg text-[10px] font-bold uppercase">Coming Soon</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="px-2 py-1 bg-gray-500/10 text-gray-500 border border-gray-500/20 rounded-lg text-[10px] font-bold uppercase">Closed</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="p-4 text-center">
                            <div class="flex items-center justify-center space-x-2">
                                <a href="${pageContext.request.contextPath}/admin/movies/detail?id=${movie.id_Movie}" 
                                   class="w-8 h-8 rounded-lg bg-blue-500/10 text-blue-500 hover:bg-blue-500 hover:text-white transition flex items-center justify-center" 
                                   title="Xem chi tiết">
                                    <i class="fas fa-eye"></i>
                                </a>

                                <%-- UPDATE DATA ATTRIBUTES THEO ĐÚNG THUỘC TÍNH DATABASE --%>
                                <button class="text-blue-400 hover:text-blue-300 transition" 
                                        onclick="openEditMovieSystem(this)"
                                        data-id="${movie.id_Movie}"
                                        data-title="${movie.title}"
                                        data-director="${movie.director}"
                                        data-description="${fn:escapeXml(movie.description)}"
                                        data-cast="${movie.cast}"
                                        data-duration="${movie.duration}"
                                        data-prodyear="${movie.productionYear}"
                                        data-price="${movie.basePrice}"
                                        data-releasedate="${movie.releaseDate}"
                                        data-language="${movie.language}"
                                        data-genre="${movie.genre}"
                                        data-category="${movie.category}"
                                        data-censorship="${movie.censorship}"
                                        data-status="${movie.status}"
                                        data-poster="${movie.posterUrl}"
                                        data-trailer="${movie.trailerUrl}">
                                    <i class="fas fa-pen"></i>
                                </button>
                                <button onclick="confirmDeleteMovie('${movie.id_Movie}', '${movie.title}')" class="w-8 h-8 rounded-lg bg-red-500/10 text-red-500 hover:bg-red-500 hover:text-white transition flex items-center justify-center" title="Xóa phim"><i class="fas fa-trash"></i></button>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<%-- FORM ẨN ĐỂ SUBMIT HÀNH ĐỘNG XÓA THEO CẤU TRÚC TRUYỀN THỐNG --%>
<form id="deleteMovieForm" action="${pageContext.request.contextPath}/admin/movies/delete" method="POST" class="hidden">
    <input type="hidden" name="id" id="deleteMovieId">
</form>

<script>
    function confirmDeleteMovie(id, title) {
        if (confirm("Bạn có chắc chắn muốn xóa bộ phim '" + title + "' không?\nHành động này không thể hoàn tác!")) {
            document.getElementById('deleteMovieId').value = id;
            document.getElementById('deleteMovieForm').submit();
        }
    }
</script>


<jsp:include page="movie_add_edit.jsp" />