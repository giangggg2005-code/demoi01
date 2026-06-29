// assets/js/main.js
document.addEventListener("DOMContentLoaded", function () {
    "use strict";
    // ========================================================================
    // 1. ĐỒNG HỒ HIỂN THỊ THỜI GIAN THỰC (Tối ưu hóa bộ nhớ & Caching DOM)
    // ========================================================================
    const clockElement = document.getElementById('realtime-clock');

    if (clockElement) {
        const updateRealTimeClock = () => {
            const now = new Date();
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            const seconds = String(now.getSeconds()).padStart(2, '0');
            const day = String(now.getDate()).padStart(2, '0');
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const year = now.getFullYear();

            clockElement.innerHTML = `<i class="far fa-clock text-red-500 mr-2"></i>${hours}:${minutes}:${seconds} — ${day}/${month}/${year}`;
        };

        // Chạy ngay lập tức để tránh độ trễ 1 giây ban đầu, sau đó thiết lập chu kỳ
        updateRealTimeClock();
        setInterval(updateRealTimeClock, 1000);
    }

    // ========================================================================
    // 2. XỬ LÝ SỰ KIỆN SIDEBAR (Sửa lỗi click đầu tiên & Đồng bộ hóa Responsive)
    // ========================================================================
    const toggleBtn = document.getElementById('sidebar-toggle');
    const sidebar = document.getElementById('admin-sidebar');
    const mainContent = document.getElementById('main-container-wrapper');

    if (toggleBtn && sidebar && mainContent) {
        toggleBtn.addEventListener('click', function () {
            const isMobile = window.innerWidth < 768;

            // SỬA LỖI NGHIÊM TRỌNG: Xác định chính xác trạng thái đóng/mở ban đầu 
            const isHidden = sidebar.style.transform === 'translateX(-100%)' || (!sidebar.style.transform && isMobile);

            if (isHidden) {
                // Hiển thị Sidebar
                sidebar.style.transform = 'translateX(0%)';
                if (!isMobile)
                    mainContent.style.marginLeft = '16rem';
            } else {
                // Ẩn Sidebar
                sidebar.style.transform = 'translateX(-100%)';
                if (!isMobile)
                    mainContent.style.marginLeft = '0';
            }
        });

        // KHẮC PHỤC LỖI VỠ GIAO DIỆN: Tự động dọn dẹp inline-style khi người dùng co giãn trình duyệt
        window.addEventListener('resize', function () {
            const isMobile = window.innerWidth < 768;
            if (!isMobile) {
                if (sidebar.style.transform !== 'translateX(-100%)') {
                    sidebar.style.transform = '';
                    mainContent.style.marginLeft = '';
                }
            } else {
                if (sidebar.style.transform !== 'translateX(0%)') {
                    sidebar.style.transform = '';
                    mainContent.style.marginLeft = '';
                }
            }
        });
    }

    // ========================================================================
    // 3. KHỞI TẠO BIỂU ĐỒ DOANH THU & HIỆU ỨNG RẮN BÒ (REPLAY KHI HOVER)
    // ========================================================================
    setTimeout(function () {
        const canvas = document.getElementById('monthlyRevenueChart');
        if (!canvas)
            return;

        const ctx = canvas.getContext('2d');

        // Hủy chart cũ nếu đã tồn tại (Ngăn chặn rò rỉ bộ nhớ hoặc lỗi vẽ chồng chéo)
        const oldChart = Chart.getChart(canvas);
        if (oldChart)
            oldChart.destroy();

        // Kiểm tra và chuẩn bị dữ liệu an toàn từ Database
        const chartData = (window.chartDataFromDB && window.chartDataFromDB.length === 12)
                ? window.chartDataFromDB
                : Array(12).fill(0);

        // Cấu hình Timeline nâng cao cho Progressive Animation (Hiệu ứng rắn bò)
        const totalDuration = 2000;
        const delayBetweenPoints = totalDuration / chartData.length;

        let animState = {x: {}, y: {}};

        const previousY = (ctx) => {
            if (ctx.index === 0)
                return ctx.chart.scales.y.getPixelForValue(0);
            const meta = ctx.chart.getDatasetMeta(ctx.datasetIndex);
            return meta.data[ctx.index - 1].getProps(['y'], true).y;
        };

        const progressiveAnimation = {
            x: {
                type: 'number',
                easing: 'linear',
                duration: delayBetweenPoints,
                from: NaN,
                delay(ctx) {
                    if (ctx.type !== 'data' || animState.x[ctx.index])
                        return 0;
                    animState.x[ctx.index] = true;
                    return ctx.index * delayBetweenPoints;
                }
            },
            y: {
                type: 'number',
                easing: 'easeOutQuart',
                duration: delayBetweenPoints,
                from: previousY,
                delay(ctx) {
                    if (ctx.type !== 'data' || animState.y[ctx.index])
                        return 0;
                    animState.y[ctx.index] = true;
                    return ctx.index * delayBetweenPoints;
                }
            }
        };

        // Khởi tạo đối tượng biểu đồ chính thức
        window.revenueChartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'],
                datasets: [{
                        label: 'Doanh thu',
                        data: chartData,
                        borderColor: '#ef4444',
                        borderWidth: 3,
                        tension: 0.4,
                        fill: true,
                        backgroundColor: function (context) {
                            const chart = context.chart;
                            const {ctx: gradientCtx, chartArea} = chart;
                            if (!chartArea)
                                return 'rgba(239, 68, 68, 0.05)';

                            const gradient = gradientCtx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom);
                            gradient.addColorStop(0, 'rgba(239, 68, 68, 0.25)');
                            gradient.addColorStop(1, 'rgba(239, 68, 68, 0.0)');
                            return gradient;
                        },
                        pointBackgroundColor: '#ef4444',
                        pointBorderColor: '#0b0c10',
                        pointHoverRadius: 7,
                        pointRadius: 4
                    }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: progressiveAnimation,
                plugins: {
                    legend: {display: false},
                    tooltip: {
                        backgroundColor: 'rgba(18, 18, 18, 0.95)',
                        titleColor: '#fff',
                        bodyColor: '#ef4444',
                        borderColor: 'rgba(239, 68, 68, 0.3)',
                        borderWidth: 1,
                        padding: 10,
                        cornerRadius: 8,
                        callbacks: {
                            label: function (context) {
                                return ' Doanh thu: ' + context.parsed.y.toLocaleString('vi-VN') + ' ₫';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        grid: {color: 'rgba(255, 255, 255, 0.05)'},
                        ticks: {
                            color: '#9ca3af',
                            callback: function (value) {
                                if (value >= 1e9)
                                    return (value / 1e9).toLocaleString('vi-VN', {maximumFractionDigits: 1}) + ' Tỷ ₫';
                                if (value >= 1e6)
                                    return (value / 1e6).toLocaleString('vi-VN', {maximumFractionDigits: 1}) + 'M ₫';
                                if (value >= 1e3)
                                    return (value / 1e3).toLocaleString('vi-VN') + 'K ₫';
                                return value.toLocaleString('vi-VN') + ' ₫';
                            }
                        },
                        beginAtZero: true
                    },
                    x: {
                        grid: {display: false},
                        ticks: {color: '#9ca3af'}
                    }
                }
            }
        });

        // KÍCH HOẠT VẼ LẠI ANIMATION KHI RE-HOVER CANVAS
        canvas.addEventListener('mouseenter', () => {
            if (window.revenueChartInstance) {
                animState.x = {};
                animState.y = {};
                window.revenueChartInstance.reset();
                window.revenueChartInstance.update();
            }
        });
    }, 200);

    // === (Các phần Đồng hồ, Sidebar, Chuyển trang của main.js bạn giữ nguyên) ===

    document.addEventListener("DOMContentLoaded", function () {
        const movieModal = document.getElementById('modal-movie');
        const movieForm = document.getElementById('movie-form');
        const modalMovieTitle = document.getElementById('modal-movie-title');

        window.openAddMovieModal = function () {
            if (!movieModal)
                return;
            if (movieForm)
                movieForm.reset();
            document.getElementById('form-movie-id').value = '0'; // id_Movie = 0 để insert
            if (modalMovieTitle)
                modalMovieTitle.textContent = 'Thêm Phim Mới';

            movieModal.classList.remove('hidden');
            setTimeout(() => {
                movieModal.classList.remove('opacity-0');
                movieModal.querySelector('.glass-card')?.classList.remove('scale-95');
            }, 10);
        };

        window.closeMovieModal = function () {
            if (!movieModal)
                return;
            movieModal.classList.add('opacity-0');
            movieModal.querySelector('.glass-card')?.classList.add('scale-95');
            setTimeout(() => movieModal.classList.add('hidden'), 300);
        };

        // Điền dữ liệu từ data-attributes vào Modal Sửa
        document.addEventListener('click', function (e) {
            const editBtn = e.target.closest('.edit-movie-btn');
            if (!editBtn || !movieModal)
                return;

            if (modalMovieTitle)
                modalMovieTitle.textContent = 'Cập Nhật Thông Tin Phim';
            const data = editBtn.dataset;

            document.getElementById('form-movie-id').value = data.id || '0';
            document.getElementById('form-movie-title').value = data.title || '';
            document.getElementById('form-movie-genre').value = data.genre || '';
            document.getElementById('form-movie-duration').value = data.duration || '';
            document.getElementById('form-movie-year').value = data.year || '';
            document.getElementById('form-movie-status').value = data.status || 'Showing';
            document.getElementById('form-movie-poster').value = data.poster || '';

            movieModal.classList.remove('hidden');
            setTimeout(() => {
                movieModal.classList.remove('opacity-0');
                movieModal.querySelector('.glass-card')?.classList.remove('scale-95');
            }, 10);
        });

        // Nút xác nhận Xóa Phim
        window.confirmDeleteMovie = function (id, title) {
            if (confirm(`Hành động này không thể hoàn tác!\nBạn có chắc chắn muốn gỡ bộ phim "${title}" ra khỏi hệ thống rạp không?`)) {
                window.location.href = `${window.location.origin}/admin/movies/delete?id=${id}`;
            }
        };
    });
    // ========================================================================
    // 5. CƠ CHẾ CHUYỂN TRANG (PAGE SWITCHER ENGINE) VÀ ĐỒNG BỘ MENU SIDEBAR
    // ========================================================================
    window.switchPage = function (pageId) {
        const pages = document.querySelectorAll('.page-content');
        if (pages.length === 0)
            return;

        // Ẩn tất cả các trang hiện tại
        pages.forEach(page => page.classList.remove('active'));

        // Hiển thị trang đích được chỉ định
        const targetPage = document.getElementById(pageId);
        if (targetPage) {
            targetPage.classList.add('active');
            // Cuộn mượt lên đầu trang khi đổi tab
            window.scrollTo({top: 0, behavior: 'smooth'});
        }

        // Cập nhật trạng thái active (đỏ nền) trên cả hai Sidebar (Desktop & Mobile)
        const menuButtons = document.querySelectorAll('#sidebar-menu button, #mobile-sidebar-menu button');
        menuButtons.forEach(btn => {
            const targetAttr = btn.getAttribute('data-target') || btn.getAttribute('onclick')?.match(/'([^']+)'/)?.[1];
            if (targetAttr === pageId) {
                btn.className = "menu-item w-full flex items-center space-x-3 bg-red-600 text-white px-4 py-3 rounded-xl font-medium transition text-left";
            } else {
                btn.className = "menu-item w-full flex items-center space-x-3 text-gray-400 hover:bg-[#1e1e1e] hover:text-white px-4 py-3 rounded-xl font-medium transition text-left";
            }
        });

        // Tự động đóng sidebar nếu đang ở chế độ hiển thị mobile màn hình nhỏ
        if (window.innerWidth < 768 && sidebar) {
            sidebar.style.transform = 'translateX(-100%)';
        }
    };

    // Gắn sự kiện click cho các nút menu có thuộc tính data-target thay vì dùng inline onclick
    document.querySelectorAll('[data-target]').forEach(button => {
        button.addEventListener('click', function () {
            const targetPage = this.getAttribute('data-target');
            if (targetPage)
                window.switchPage(targetPage);
        });
    });

    // ========================================================================
    // 6. XỬ LÝ MODAL XEM CHI TIẾT PHIM TRỰC QUAN (MOVIE DETAIL VIEWER)
    // ========================================================================
    const movieDetailModal = document.getElementById('modal-movie-detail');

    window.openMovieDetailModal = function (dataJsonOrId) {
        if (!movieDetailModal)
            return;

        let data = {};
        try {
            data = typeof dataJsonOrId === 'string' ? JSON.parse(dataJsonOrId) : dataJsonOrId;
        } catch (e) {
            console.error("Lỗi parse chuỗi JSON chi tiết phim: ", e);
            return;
        }

        // Ánh xạ dữ liệu an toàn vào các trường giao diện chi tiết
        const mappings = {
            'detail-movie-title': data.title || 'Không rõ tên',
            'detail-movie-genre': data.genre || 'Chưa phân loại',
            'detail-movie-duration': (data.duration || '0') + ' phút',
            'detail-movie-status': data.status || 'Chưa cập nhật',
            'detail-movie-desc': data.description || 'Chưa có mô tả chi tiết cho bộ phim này.',
            'detail-movie-director': data.director || 'Đang cập nhật',
            'detail-movie-cast': data.cast || 'Đang cập nhật',
            'detail-movie-language': data.language || 'Phụ đề tiếng Việt',
            'detail-movie-release': data.releaseDate || 'N/A'
        };

        for (const [id, value] of Object.entries(mappings)) {
            const el = document.getElementById(id);
            if (el)
                el.innerText = value;
        }

        // Cập nhật ảnh Poster phim
        const posterEl = document.getElementById('detail-movie-poster');
        if (posterEl) {
            posterEl.src = data.posterUrl || 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=300';
        }

        // Hiển thị modal kèm hiệu ứng animation
        movieDetailModal.classList.remove('hidden');
        movieDetailModal.classList.add('flex');
    };

    window.closeMovieDetailModal = function () {
        if (movieDetailModal) {
            movieDetailModal.classList.add('hidden');
            movieDetailModal.classList.remove('flex');
        }
    };

    if (movieDetailModal) {
        movieDetailModal.addEventListener('click', (e) => {
            if (e.target === movieDetailModal)
                window.closeMovieDetailModal();
        });
    }

    // ========================================================================
    // 7. QUẢN LÝ NGƯỜI DÙNG & BỘ LỌC THỜI GIAN THÔNG MINH (USER MANAGEMENT)
    // ========================================================================
    window.toggleUserStatus = function (userId, buttonElement) {
        if (!buttonElement)
            return;
        const row = buttonElement.closest('tr');
        if (!row)
            return;

        const statusBadge = row.querySelector('.status-badge');
        const isCurrentlyActive = statusBadge && statusBadge.textContent.trim() === 'Hoạt động';

        if (confirm(`Bạn có chắc muốn ${isCurrentlyActive ? 'KHÓA tài khoản' : 'KÍCH HOẠT lại tài khoản'} của người dùng này không?`)) {
            if (statusBadge) {
                if (isCurrentlyActive) {
                    statusBadge.textContent = 'Bị khóa';
                    statusBadge.className = 'status-badge bg-red-500/10 text-red-500 text-xs px-2 py-0.5 rounded font-medium';
                    buttonElement.className = 'text-green-400 hover:text-green-500 transition';
                    buttonElement.innerHTML = '<i class="fa-solid fa-circle-check text-lg"></i>';
                    buttonElement.title = 'Kích hoạt tài khoản';
                } else {
                    statusBadge.textContent = 'Hoạt động';
                    statusBadge.className = 'status-badge bg-green-500/10 text-green-500 text-xs px-2 py-0.5 rounded font-medium';
                    buttonElement.className = 'text-red-400 hover:text-red-500 transition';
                    buttonElement.innerHTML = '<i class="fa-solid fa-ban text-lg"></i>';
                    buttonElement.title = 'Khóa tài khoản';
                }
            }
        }
    };

    // Tìm kiếm lọc người dùng thời gian thực kết hợp đa tiêu chí
    window.filterUsers = function () {
        const searchName = document.getElementById('search-user-name')?.value.toLowerCase() || '';
        const searchDay = document.getElementById('filter-user-day')?.value || '';
        const searchMonth = document.getElementById('filter-user-month')?.value || '';
        const searchYear = document.getElementById('filter-user-year')?.value || '';
        const filterStatus = document.getElementById('filter-user-status')?.value || 'Tất cả';

        const rows = document.querySelectorAll('#user-table-body tr');
        rows.forEach(row => {
            const name = row.children[1]?.textContent.toLowerCase() || '';
            const email = row.children[2]?.textContent.toLowerCase() || '';
            const dateText = row.children[5]?.textContent.trim() || ''; // Format DD/MM/YYYY
            const status = row.querySelector('.status-badge')?.textContent.trim() || '';

            const [day, month, year] = dateText.split('/');

            const matchesName = name.includes(searchName) || email.includes(searchName);
            const matchesDay = !searchDay || day === searchDay.padStart(2, '0');
            const matchesMonth = !searchMonth || month === searchMonth.padStart(2, '0');
            const matchesYear = !searchYear || year === searchYear;
            const matchesStatus = filterStatus === 'Tất cả' || status === filterStatus;

            row.style.display = (matchesName && matchesDay && matchesMonth && matchesYear && matchesStatus) ? "" : "none";
        });
    };

    // Ràng buộc logic Ngày/Tháng/Năm tự động tính toán số ngày trong tháng (Bao gồm năm nhuận)
    window.updateDateDropdowns = function (prefix) {
        const yearSel = document.getElementById(`filter-${prefix}-year`);
        const monthSel = document.getElementById(`filter-${prefix}-month`);
        const daySel = document.getElementById(`filter-${prefix}-day`);

        if (!daySel || !monthSel || !yearSel)
            return;

        const selectedMonth = parseInt(monthSel.value) || 0;
        const selectedYear = parseInt(yearSel.value) || 0;
        const currentSelectedDay = daySel.value;

        // Lưu vết giá trị ngày đang chọn hiện tại để hồi phục nếu hợp lệ
        daySel.innerHTML = '<option value="">Ngày</option>';

        if (!selectedMonth)
            return; // Nếu chưa chọn tháng thì không render ngày công thức

        let daysInMonth = 31;
        if ([4, 6, 9, 11].includes(selectedMonth)) {
            daysInMonth = 30;
        } else if (selectedMonth === 2) {
            // Kiểm tra điều kiện thuật toán năm nhuận chính xác
            const isLeapYear = (selectedYear % 4 === 0 && selectedYear % 100 !== 0) || (selectedYear % 400 === 0);
            daysInMonth = isLeapYear ? 29 : 28;
        }

        for (let d = 1; d <= daysInMonth; d++) {
            const opt = document.createElement('option');
            opt.value = d;
            opt.textContent = String(d).padStart(2, '0');
            if (currentSelectedDay && parseInt(currentSelectedDay) === d) {
                opt.selected = true;
            }
            daySel.appendChild(opt);
        }

        // Gọi lại hàm filter tương ứng để cập nhật giao diện
        if (prefix === 'user')
            window.filterUsers();
    };

    // Đăng ký bộ lắng nghe sự kiện đổi bộ lọc ngày tháng năm an toàn
    ['user', 'revenue', 'staff'].forEach(prefix => {
        const m = document.getElementById(`filter-${prefix}-month`);
        const y = document.getElementById(`filter-${prefix}-year`);
        const d = document.getElementById(`filter-${prefix}-day`);
        const s = document.getElementById(`filter-${prefix}-status`);
        const input = document.getElementById(`search-${prefix}-name`);

        if (m)
            m.addEventListener('change', () => window.updateDateDropdowns(prefix));
        if (y)
            y.addEventListener('change', () => window.updateDateDropdowns(prefix));
        if (d && prefix === 'user')
            d.addEventListener('change', window.filterUsers);
        if (s && prefix === 'user')
            s.addEventListener('change', window.filterUsers);
        if (input && prefix === 'user')
            input.addEventListener('input', window.filterUsers);
    });

    // ========================================================================
    // 8. PHÂN HỆ QUẢN LÝ PHÒNG CHIẾU (THEATER ROOM CONFIGURATION MODULE)
    // ========================================================================
    const roomModal = document.getElementById('room-modal');

    window.openRoomModal = function (id = '', name = '', type = '2D', rows = 10, cols = 12, status = 'Sẵn sàng') {
        if (!roomModal)
            return;

        const titleEl = document.getElementById('room-modal-title');
        if (titleEl)
            titleEl.textContent = id ? 'Cập Nhật Phòng Chiếu' : 'Thêm Phòng Chiếu Mới';

        const fields = {
            'form-room-id': id,
            'form-room-name': name,
            'form-room-type': type,
            'form-room-rows': rows,
            'form-room-cols': cols,
            'form-room-status': status
        };

        for (const [key, value] of Object.entries(fields)) {
            const el = document.getElementById(key);
            if (el)
                el.value = value;
        }

        roomModal.classList.remove('hidden');
    };

    window.closeRoomModal = function () {
        if (roomModal)
            roomModal.classList.add('hidden');
    };

    window.deleteRoom = function (id, name) {
        if (confirm(`Bạn có chắc chắn muốn xóa phòng chiếu "${name}" (Mã: ${id})? Hành động này không thể hoàn tác!`)) {
            alert(`Đã yêu cầu xóa phòng ${name} lên hệ thống backend.`);
            // Thực hiện điều hướng hoặc fetch gọi API xóa ở đây
        }
    };

    // ========================================================================
    // 9. CƠ CHẾ QUẢN LÝ LỊCH CHIẾU PHIM (SHOWTIME MANAGEMENT CORE ENGINE)
    // ========================================================================
    const showtimeModal = document.getElementById('showtime-modal');

    // Mảng mock danh sách lịch chiếu phục vụ render cập nhật trực tiếp tại Client
    let mockShowtimes = [
        {id: 'SC001', movie: 'Avengers: Endgame', room: 'Phòng số 1 (IMAX)', date: '2026-06-15', time: '19:30', price: 120000, status: 'Đang chiếu'},
        {id: 'SC002', movie: 'The Batman', room: 'Phòng số 3 (2D)', date: '2026-06-15', time: '20:45', price: 95000, status: 'Sắp chiếu'}
    ];

    window.renderShowtimes = function () {
        const tbody = document.getElementById('showtime-table-body');
        if (!tbody)
            return;

        tbody.innerHTML = '';
        mockShowtimes.forEach(st => {
            const tr = document.createElement('tr');
            tr.className = "border-b border-gray-800 hover:bg-[#14151b] transition";
            tr.innerHTML = `
                <td class="p-4 font-mono font-bold text-red-500">${st.id}</td>
                <td class="p-4 text-white font-medium">${st.movie}</td>
                <td class="p-4 text-gray-300">${st.room}</td>
                <td class="p-4 text-gray-400">${st.date} | <span class="text-amber-500 font-bold">${st.time}</span></td>
                <td class="p-4 text-green-500 font-semibold">${st.price.toLocaleString('vi-VN')} ₫</td>
                <td class="p-4">
                    <span class="px-2 py-0.5 rounded text-xs font-medium ${st.status === 'Đang chiếu' ? 'bg-green-500/10 text-green-400' : st.status === 'Sắp chiếu' ? 'bg-blue-500/10 text-blue-400' : 'bg-gray-500/10 text-gray-400'}">
                        ${st.status}
                    </span>
                </td>
                <td class="p-4 flex space-x-2">
                    <button onclick="window.openShowtimeModal('${st.id}')" class="text-blue-400 hover:text-blue-500 transition"><i class="fa-solid fa-pen-to-square text-base"></i></button>
                    <button onclick="window.deleteShowtime('${st.id}')" class="text-red-400 hover:text-red-500 transition"><i class="fa-solid fa-trash text-base"></i></button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    };

    window.openShowtimeModal = function (id = '') {
        if (!showtimeModal)
            return;

        const titleEl = document.getElementById('showtime-modal-title');
        if (titleEl)
            titleEl.textContent = id ? 'Cập Nhật Lịch Chiếu Phim' : 'Tạo Lịch Chiếu Mới';

        if (id) {
            const data = mockShowtimes.find(st => st.id === id);
            if (data) {
                if (document.getElementById('showtime-id'))
                    document.getElementById('showtime-id').value = data.id;
                if (document.getElementById('showtime-movie'))
                    document.getElementById('showtime-movie').value = data.movie;
                if (document.getElementById('showtime-room'))
                    document.getElementById('showtime-room').value = data.room;
                if (document.getElementById('showtime-date'))
                    document.getElementById('showtime-date').value = data.date;
                if (document.getElementById('showtime-time'))
                    document.getElementById('showtime-time').value = data.time;
                if (document.getElementById('showtime-price'))
                    document.getElementById('showtime-price').value = data.price;
                if (document.getElementById('showtime-status'))
                    document.getElementById('showtime-status').value = data.status;
            }
        } else {
            const form = showtimeModal.querySelector('form');
            if (form)
                form.reset();
            if (document.getElementById('showtime-id'))
                document.getElementById('showtime-id').value = '';
        }

        showtimeModal.classList.remove('hidden');
    };

    window.closeShowtimeModal = function () {
        if (showtimeModal)
            showtimeModal.classList.add('hidden');
    };

    window.deleteShowtime = function (id) {
        if (confirm(`Bạn có chắc chắn muốn hủy lịch chiếu mang mã định danh "${id}"?`)) {
            mockShowtimes = mockShowtimes.filter(st => st.id !== id);
            window.renderShowtimes();
        }
    };

    // Khởi tạo bảng danh sách lịch chiếu ngay từ ban đầu
    window.renderShowtimes();

    // ========================================================================
    // 10. HỆ THỐNG CÀI ĐẶT CHUNG (GLOBAL SYSTEM CONFIGURATION)
    // ========================================================================
    window.openSettings = function () {
        alert("Tính năng cài đặt hệ thống tổng thể đang được tải. Vui lòng đợi trong giây lát...");
    };
    // ========================================================================
    // 12. HỆ THỐNG QUẢN LÝ BIỂU MẪU PHIM & XÁC NHẬN THÔNG MINH
    // ========================================================================
    const movieModal = document.getElementById('movie-form-modal');
    const movieForm = document.getElementById('movie-core-form');
    const titleText = document.getElementById('modal-title-text');
    const frontErrorBox = document.getElementById('frontend-error-box');
    const frontErrorMsg = document.getElementById('frontend-error-msg');

    // Yếu tố Live Preview
    const modalBgPoster = document.getElementById('modal-bg-poster');
    const livePosterImg = document.getElementById('live-poster-img');
    const posterInput = document.getElementById('form-movie-poster');

    // TÍNH NĂNG 1: LIVE PREVIEW POSTER (Tự động đổi nền & ảnh khung bên trái khi dán link)
    if (posterInput && modalBgPoster && livePosterImg) {
        posterInput.addEventListener('input', function () {
            const url = this.value.trim() || 'https://via.placeholder.com/320x480.png?text=No+Poster';
            modalBgPoster.style.backgroundImage = `url('${url}')`;
            livePosterImg.src = url;
        });
    }

    // TÍNH NĂNG 2: XEM THỬ TRAILER TRỰC TIẾP TRÊN FORM
    window.previewLiveTrailer = function () {
        const trailerUrl = document.getElementById('form-movie-trailer').value.trim();
        if (trailerUrl) {
            if (typeof openTrailerModal === "function") {
                openTrailerModal(trailerUrl);
            } else {
                alert("Mở link Trailer: " + trailerUrl);
            }
        } else {
            showFrontendError("Vui lòng nhập Link Video Trailer trước khi xem thử!");
        }
    };

    // QUẢN LÝ TRẠNG THÁI DỮ LIỆU ĐỂ CẢNH BÁO THOÁT
    let initialFormSnapshot = "";
    const captureFormSnapshot = () => {
        if (!movieForm)
            return "";
        const formData = new FormData(movieForm);
        let snapshot = "";
        for (let [key, value] of formData.entries()) {
            if (key !== "id_Movie")
                snapshot += `${key}:${value}|`;
        }
        return snapshot;
    };
    const isFormDirty = () => captureFormSnapshot() !== initialFormSnapshot;

    // HỘP THOẠI XÁC NHẬN TÙY CHỈNH
    window.showCustomConfirm = function (options) {
        const dialog = document.getElementById('custom-confirm-dialog');
        document.getElementById('confirm-dialog-title').textContent = options.title || "Xác nhận";
        document.getElementById('confirm-dialog-message').textContent = options.message || "Bạn có chắc chắn?";
        const btnYes = document.getElementById('confirm-btn-yes');
        btnYes.textContent = options.yesText || "Đồng ý";
        document.getElementById('confirm-btn-no').textContent = options.noText || "Hủy bỏ";

        const iconWrapper = document.getElementById('confirm-icon-wrapper');
        const iconElement = document.getElementById('confirm-dialog-icon');

        if (options.type === 'danger') {
            iconWrapper.className = "w-20 h-20 bg-red-600/10 border border-red-500/20 text-red-500 rounded-full flex items-center justify-center text-3xl mx-auto animate-pulse";
            iconElement.className = "fas fa-exclamation-triangle";
            btnYes.className = "flex-1 bg-red-600 hover:bg-red-700 text-white font-black py-3.5 rounded-xl text-sm transition-all shadow-[0_0_15px_rgba(239,68,68,0.4)]";
        } else {
            iconWrapper.className = "w-20 h-20 bg-amber-600/10 border border-amber-500/20 text-amber-500 rounded-full flex items-center justify-center text-3xl mx-auto";
            iconElement.className = "fas fa-save";
            btnYes.className = "flex-1 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white font-black py-3.5 rounded-xl text-sm transition-all shadow-[0_0_15px_rgba(245,158,11,0.4)]";
        }

        dialog.classList.remove('hidden');
        btnYes.onclick = () => {
            dialog.classList.add('hidden');
            if (options.onConfirm)
                options.onConfirm();
        };
        document.getElementById('confirm-btn-no').onclick = () => {
            dialog.classList.add('hidden');
            if (options.onCancel)
                options.onCancel();
        };
    };

    // MỞ GIAO DIỆN THÊM PHIM MỚI
    window.openAddMovieSystem = function () {
        if (!movieModal || !movieForm)
            return;
        movieForm.reset();

        document.getElementById('form-movie-id').value = "0";
        document.getElementById('form-movie-prodyear').value = new Date().getFullYear();

        // RÀNG BUỘC NGHIỆP VỤ THÊM MỚI: Chỉ cho phép trạng thái "Sắp chiếu"
        const statusSelect = document.getElementById('form-movie-status');
        statusSelect.innerHTML = '<option value="Coming Soon" class="text-amber-500">Sắp chiếu (Bắt buộc với phim mới)</option>';
        statusSelect.value = "Coming Soon";

        // Reset Live preview
        const defaultPoster = 'https://cdn.galaxycine.vn/fanti.jpg';
        if (modalBgPoster)
            modalBgPoster.style.backgroundImage = `url('${defaultPoster}')`;
        if (livePosterImg)
            livePosterImg.src = defaultPoster;

        if (frontErrorBox)
            frontErrorBox.classList.add('hidden');
        titleText.textContent = "Thêm phim mới";

        movieModal.classList.remove('hidden');
        document.body.style.overflow = 'hidden';
        initialFormSnapshot = captureFormSnapshot();
    };

    // MỞ GIAO DIỆN CHỈNH SỬA PHIM
    window.openEditMovieSystem = function (btn) {
        if (!movieModal || !movieForm || !btn)
            return;
        if (frontErrorBox)
            frontErrorBox.classList.add('hidden');

        // Phục hồi lại Option trạng thái cho Edit Mode (Các rule check suất chiếu phức tạp sẽ được Backend chặn)
        const statusSelect = document.getElementById('form-movie-status');
        statusSelect.innerHTML = `
            <option value="Coming Soon" class="text-amber-500">Sắp chiếu</option>
            <option value="Showing" class="text-green-500">Đang chiếu</option>
            <option value="Closed" class="text-gray-500">Đã ngưng chiếu</option>
        `;

        document.getElementById('form-movie-id').value = btn.getAttribute('data-id') || "0";
        document.getElementById('form-movie-title').value = btn.getAttribute('data-title') || "";
        document.getElementById('form-movie-director').value = btn.getAttribute('data-director') || "";
        document.getElementById('form-movie-description').value = btn.getAttribute('data-description') || "";
        document.getElementById('form-movie-cast').value = btn.getAttribute('data-cast') || "";
        document.getElementById('form-movie-duration').value = btn.getAttribute('data-duration') || "";
        document.getElementById('form-movie-prodyear').value = btn.getAttribute('data-prodyear') || new Date().getFullYear();
        document.getElementById('form-movie-price').value = btn.getAttribute('data-price') || "0";
        document.getElementById('form-movie-releasedate').value = btn.getAttribute('data-releasedate') || "";
        document.getElementById('form-movie-language').value = btn.getAttribute('data-language') || "";
        document.getElementById('form-movie-genre').value = btn.getAttribute('data-genre') || "Hành động";
        document.getElementById('form-movie-category').value = btn.getAttribute('data-category') || "Phim truyện 2D";
        document.getElementById('form-movie-censorship').value = btn.getAttribute('data-censorship') || "P";
        document.getElementById('form-movie-status').value = btn.getAttribute('data-status') || "Coming Soon";
        document.getElementById('form-movie-trailer').value = btn.getAttribute('data-trailer') || "";

        // Kích hoạt lại Live Preview cho Edit
        const posterUrl = btn.getAttribute('data-poster') || "https://via.placeholder.com/320x480.png?text=No+Poster";
        document.getElementById('form-movie-poster').value = posterUrl;
        if (modalBgPoster)
            modalBgPoster.style.backgroundImage = `url('${posterUrl}')`;
        if (livePosterImg)
            livePosterImg.src = posterUrl;

        titleText.textContent = "Chỉnh sửa hồ sơ phim";

        movieModal.classList.remove('hidden');
        document.body.style.overflow = 'hidden';
        initialFormSnapshot = captureFormSnapshot();
    };

    // ĐÓNG FORM AN TOÀN KÈM CẢNH BÁO
    window.handleCancelOrBack = function () {
        if (isFormDirty()) {
            window.showCustomConfirm({
                title: "Thoát và không lưu?",
                message: "Cảnh báo: Bạn đã thay đổi dữ liệu trong biểu mẫu. Việc thoát ngay bây giờ sẽ làm mất toàn bộ nội dung bạn vừa sửa. Chắc chắn thoát?",
                type: "danger",
                yesText: "Vẫn thoát",
                noText: "Quay lại",
                onConfirm: () => {
                    movieModal.classList.add('hidden');
                    document.body.style.overflow = '';
                }
            });
        } else {
            movieModal.classList.add('hidden');
            document.body.style.overflow = '';
        }
    };

    const showFrontendError = (message) => {
        if (frontErrorBox && frontErrorMsg) {
            frontErrorMsg.textContent = message;
            frontErrorBox.classList.remove('hidden');
        }
    };

    // TRIGGER VALIDATION TRƯỚC KHI SUBMIT
    window.triggerSaveValidation = function () {
        if (!movieForm)
            return;
        if (!movieForm.checkValidity()) {
            movieForm.reportValidity();
            return;
        }

        const title = document.getElementById('form-movie-title').value.trim();
        const duration = parseInt(document.getElementById('form-movie-duration').value) || 0;
        const prodYear = parseInt(document.getElementById('form-movie-prodyear').value) || 0;
        const basePrice = parseFloat(document.getElementById('form-movie-price').value) || 0;
        const releaseDateStr = document.getElementById('form-movie-releasedate').value;
        const currentYear = new Date().getFullYear();

        // [RÀNG BUỘC 1]: Năm sản xuất không được vượt quá năm hiện tại
        if (prodYear < 1900 || prodYear > currentYear) {
            showFrontendError(`Lỗi Logic: Năm sản xuất của phim (${prodYear}) không được lớn hơn năm hiện tại (${currentYear}).`);
            return;
        }

        // [RÀNG BUỘC 2]: Thời lượng phim
        if (duration <= 0 || duration > 600) {
            showFrontendError("Lỗi dữ liệu: Thời lượng phim phải lớn hơn 0 và tối đa 600 phút.");
            return;
        }

        // [RÀNG BUỘC 3]: Giá vé (0 -> 500k)
        if (basePrice < 0 || basePrice > 500000) {
            showFrontendError("Lỗi kinh doanh: Giá vé cơ bản không hợp lệ (Giới hạn: 0 - 500,000 VND).");
            return;
        }

        // [RÀNG BUỘC 4]: Ngày khởi chiếu >= Năm sản xuất
        if (releaseDateStr) {
            const releaseYear = new Date(releaseDateStr).getFullYear();
            if (releaseYear < prodYear) {
                showFrontendError(`Lỗi Logic: Ngày khởi chiếu (Năm ${releaseYear}) không thể xảy ra trước Năm sản xuất (${prodYear})!`);
                return;
            }
        }

        frontErrorBox.classList.add('hidden');

        // Mở thông báo Confirm Submit
        const isEditMode = document.getElementById('form-movie-id').value !== "0";
        window.showCustomConfirm({
            title: isEditMode ? "Cập nhật dữ liệu" : "Thêm phim mới",
            message: isEditMode
                    ? `Lưu ý: Nếu bạn điều chỉnh Trạng thái trình chiếu của phim "${title}", hệ thống Backend sẽ rà soát lại toàn bộ Suất chiếu (Quá khứ/Hiện tại/Tương lai) để xác minh tính hợp lệ. Bạn xác nhận muốn thực hiện thao tác cập nhật này?`
                    : `Khởi tạo phim "${title}" với trạng thái "Sắp chiếu". Hệ thống sẽ tạo hồ sơ phân phối suất chiếu mới. Xác nhận lưu?`,
            type: "info",
            yesText: "Xác nhận lưu",
            noText: "Kiểm tra lại",
            onConfirm: () => movieForm.submit()
        });
    };
    // ========================================================================
// [QUẢN LÝ PHÒNG CHIẾU] - BỘ LỌC VÀ TÌM KIẾM
// ========================================================================
    function filterRooms() {
        const searchVal = document.getElementById('roomSearchInput') ? document.getElementById('roomSearchInput').value.toLowerCase() : '';
        const typeVal = document.getElementById('roomTypeFilter') ? document.getElementById('roomTypeFilter').value : 'all';
        const statusVal = document.getElementById('roomStatusFilter') ? document.getElementById('roomStatusFilter').value : 'all';

        const rows = document.querySelectorAll('#roomTableBody tr');
        rows.forEach(row => {
            const rName = row.getAttribute('data-name').toLowerCase();
            const rType = row.getAttribute('data-type');
            const rStatus = row.getAttribute('data-status');

            const matchName = rName.includes(searchVal);
            const matchType = (typeVal === 'all' || rType === typeVal);
            const matchStatus = (statusVal === 'all' || rStatus === statusVal);

            row.style.display = (matchName && matchType && matchStatus) ? '' : 'none';
        });
    }

// ========================================================================
// [QUẢN LÝ PHÒNG CHIẾU] - MODAL VÀ XỬ LÝ SỰ KIỆN
// ========================================================================
    function openAddRoomModal() {
        document.getElementById('form-room-id').value = "0";
        document.getElementById('form-room-name').value = "";
        document.getElementById('form-room-type').value = "Standard";
        document.getElementById('form-room-price').value = "0";
        document.getElementById('form-room-rows').value = "5";
        document.getElementById('form-room-cols').value = "5";

        // Khi thêm mới được phép nhập Rows/Cols để Trigger DB chạy
        document.getElementById('form-room-rows').readOnly = false;
        document.getElementById('form-room-cols').readOnly = false;
        document.getElementById('roomNotice').classList.remove('hidden');

        document.getElementById('form-room-status').value = "Active";
        document.getElementById('roomModalTitle').innerText = "Thêm Phòng Chiếu Mới";

        toggleModalVisibility('roomModal', 'roomModalContent', true);
    }

    function openEditRoomModal(btn) {
        document.getElementById('form-room-id').value = btn.getAttribute('data-id');
        document.getElementById('form-room-name').value = btn.getAttribute('data-name');
        document.getElementById('form-room-type').value = btn.getAttribute('data-type');
        document.getElementById('form-room-price').value = btn.getAttribute('data-price');
        document.getElementById('form-room-rows').value = btn.getAttribute('data-rows');
        document.getElementById('form-room-cols').value = btn.getAttribute('data-cols');

        // KHÓA Rows/Cols khi Edit, vì ghế đã được sinh rồi, tránh lỗi logic dữ liệu
        document.getElementById('form-room-rows').readOnly = true;
        document.getElementById('form-room-cols').readOnly = true;
        document.getElementById('roomNotice').classList.add('hidden'); // Ẩn thông báo sinh ghế

        document.getElementById('form-room-status').value = btn.getAttribute('data-status');
        document.getElementById('roomModalTitle').innerText = "Cập Nhật Phòng Chiếu";

        toggleModalVisibility('roomModal', 'roomModalContent', true);
    }



    function confirmDeleteRoom(id, name) {
        if (confirm(`Bạn có chắc muốn xóa phòng "${name}"?\nHành động này sẽ XÓA TOÀN BỘ SƠ ĐỒ GHẾ của phòng này!`)) {
            window.location.href = `/admin/rooms/delete?id=${id}`;
        }
    }

// Hàm hiệu ứng bật/tắt Modal mượt mà tái sử dụng
    function toggleModalVisibility(modalId, contentId, isShow) {
        const modal = document.getElementById(modalId);
        const content = document.getElementById(contentId);
        if (isShow) {
            modal.classList.remove('hidden');
            setTimeout(() => content.classList.replace('scale-95', 'scale-100'), 10);
        } else {
            content.classList.replace('scale-100', 'scale-95');
            setTimeout(() => modal.classList.add('hidden'), 200);
        }
    }

// ========================================================================
// [QUẢN LÝ PHÒNG CHIẾU] - ĐỔI TRẠNG THÁI GHẾ BẰNG AJAX
// ========================================================================

    // Thêm đoạn code này vào file main.js (có thể đặt ở cuối file)
    window.closeRoomModal = function () {
        const modal = document.getElementById('roomModal');
        if (modal) {
            // Ẩn modal bằng cách thêm class hidden và xóa class flex
            modal.classList.add('hidden');
            modal.classList.remove('flex');

            // (Tùy chọn) Reset lại form mỗi khi đóng để lần mở sau không dính dữ liệu cũ
            const formId = document.getElementById('form-room-id');
            if (formId && formId.value === "0") {
                document.querySelector('#roomModalContent form').reset();
            }
        }
    };
}); // <--- ĐÂY LÀ DẤU ĐÓNG DUY NHẤT CỦA CẢ FILE CHUẨN CHỈNH