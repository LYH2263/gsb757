<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>网上书店 - 首页</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 min-h-screen">

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg bg-white shadow-sm py-3 sticky-top">
        <div class="container">
            <a class="navbar-brand font-bold text-2xl text-indigo-600 flex items-center gap-2" href="#">
                <i class="fas fa-book-open"></i> 网上书店
            </a>
            <div class="d-flex gap-3">
                <a href="orders.jsp" class="btn btn-outline-success rounded-full px-4 border-2 hover:bg-green-50 hover:border-green-600 hover:text-green-600 font-medium transition-all">
                    <i class="fas fa-box-open me-2"></i> 我的订单
                </a>
                <a href="cart.jsp" class="btn btn-outline-primary rounded-full px-4 border-2 hover:bg-indigo-50 hover:border-indigo-600 hover:text-indigo-600 font-medium transition-all">
                    <i class="fas fa-shopping-cart me-2"></i> 购物车
                </a>
                <button onclick="logout()" class="btn btn-danger rounded-full px-4 font-medium transition-all hover:shadow-md">
                    <i class="fas fa-sign-out-alt me-2"></i> 退出
                </button>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="container my-5">
        <div class="text-center mb-12">
            <h1 class="text-4xl font-extrabold text-gray-800 mb-2">精选图书</h1>
            <p class="text-gray-500">发现好书，开启智慧之旅</p>
        </div>

        <div class="row g-4" id="bookGrid">
            <!-- Loading Spinner -->
            <div class="col-12 text-center py-10">
                <div class="spinner-border text-indigo-600" role="status">
                    <span class="visually-hidden">加载中...</span>
                </div>
            </div>
        </div>
    </main>

    <footer class="bg-white py-6 mt-auto border-t">
        <div class="container text-center text-gray-500 text-sm">
            &copy; 2024 Bookstore Inc. 版权所有.
        </div>
    </footer>

    <script>
        async function loadBooks() {
            try {
                const res = await fetch('/api/books');
                if (res.status === 401) {
                    window.location.href = 'login.jsp';
                    return;
                }
                const books = await res.json();
                const grid = document.getElementById('bookGrid');

                grid.innerHTML = books.map(book => `
                    <div class="col-sm-6 col-md-4 col-lg-3">
                        <div class="card h-100 border-0 shadow-lg rounded-xl overflow-hidden transform hover:-translate-y-2 transition-all duration-300 group">
                            <div class="relative overflow-hidden h-64">
                                <img src="\${book.imageUrl}" class="card-img-top w-full h-full object-cover transition-transform duration-500 group-hover:scale-110" alt="\${book.title}">
                            </div>
                            <div class="card-body p-4 flex flex-col">
                                <h5 class="card-title font-bold text-lg text-gray-800 mb-1 line-clamp-1" title="\${book.title}">\${book.title}</h5>
                                <p class="text-sm text-gray-500 mb-3">\${book.author}</p>
                                <p class="card-text text-sm text-gray-600 mb-4 line-clamp-2 flex-grow">\${book.description}</p>

                                <div class="flex items-center justify-between mt-auto pt-3 border-t">
                                    <span class="text-xl font-bold text-indigo-600">¥\${Number(book.price).toFixed(2)}</span>
                                    <button onclick="addToCart(\${book.id})" class="btn bg-indigo-600 text-white rounded-lg px-4 py-2 hover:bg-indigo-700 hover:shadow-lg transition-all">
                                        加入 <i class="fas fa-plus ms-1 text-xs"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                `).join('');

            } catch (err) {
                console.error(err);
                document.getElementById('bookGrid').innerHTML = '<div class="col-12 text-center text-red-500">加载图书失败</div>';
            }
        }

        async function addToCart(bookId) {
            try {
                await fetch('/api/cart', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({bookId: bookId, quantity: 1})
                });

                // Toast notification
                const Toast = Swal.mixin({
                    toast: true,
                    position: 'top-end',
                    showConfirmButton: false,
                    timer: 3000,
                    timerProgressBar: true,
                    didOpen: (toast) => {
                        toast.addEventListener('mouseenter', Swal.stopTimer)
                        toast.addEventListener('mouseleave', Swal.resumeTimer)
                    }
                })

                Toast.fire({
                    icon: 'success',
                    title: '成功加入购物车'
                })
            } catch (err) {
                Swal.fire('错误', '加入购物车失败', 'error');
            }
        }

        async function logout() {
            try {
                await fetch('/api/logout', { method: 'POST' });
                window.location.href = 'login.jsp';
            } catch(e) {
                console.error(e);
            }
        }

        loadBooks();
    </script>
</body>
</html>
