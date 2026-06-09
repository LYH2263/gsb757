<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>购物车 - 网上书店</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 min-h-screen flex flex-col">

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg bg-white shadow-sm py-3 sticky-top">
        <div class="container">
            <a class="navbar-brand font-bold text-2xl text-indigo-600 flex items-center gap-2" href="index.jsp">
                <i class="fas fa-book-open"></i> 网上书店
            </a>
            <div class="d-flex gap-3">
                <a href="index.jsp" class="btn btn-outline-secondary rounded-full px-4 font-medium transition-all">
                    <i class="fas fa-arrow-left me-2"></i> 继续购物
                </a>
            </div>
        </div>
    </nav>

    <div class="container my-5 flex-grow-1">
        <div class="bg-white rounded-2xl shadow-xl overflow-hidden p-6">
            <h2 class="text-3xl font-bold mb-6 text-gray-800 border-b pb-4">我的购物车</h2>

            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger rounded-lg" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i> 处理请求时出错，请重试。
                </div>
            <% } %>

            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="bg-gray-100 text-gray-600 uppercase text-xs tracking-wider">
                        <tr>
                            <th class="py-3 px-4">图书</th>
                            <th class="py-3 px-4">单价</th>
                            <th class="py-3 px-4">数量</th>
                            <th class="py-3 px-4">小计</th>
                            <th class="py-3 px-4 text-end">操作</th>
                        </tr>
                    </thead>
                    <tbody id="cartBody" class="text-sm font-medium text-gray-700 divide-y divide-gray-200">
                        <!-- Loaded via JS -->
                    </tbody>
                </table>
            </div>

            <div class="flex flex-col md:flex-row justify-between items-center mt-8 pt-6 border-t">
                <div class="text-2xl font-bold text-gray-800 mb-4 md:mb-0">
                    总计: <span class="text-indigo-600">¥<span id="totalAmount">0.00</span></span>
                </div>
                <div class="flex gap-4">
                    <button class="btn btn-primary btn-lg rounded-xl px-8 font-bold shadow-lg hover:shadow-xl bg-indigo-600 hover:bg-indigo-700 border-none transition-all duration-300 transform hover:-translate-y-1" onclick="checkout()">
                        <i class="fas fa-credit-card me-2"></i> 立即结算
                    </button>
                </div>
            </div>
        </div>
    </div>

    <footer class="bg-white py-6 mt-auto border-t">
        <div class="container text-center text-gray-500 text-sm">
            &copy; 2024 Bookstore Inc. 版权所有.
        </div>
    </footer>

    <script>
        // Check for server-side message (redirected from order servlet)
        const urlParams = new URLSearchParams(window.location.search);

        async function loadCart() {
            const res = await fetch('/api/cart');
            if (res.status === 401) {
                window.location.href = 'login.jsp';
                return;
            }
            const items = await res.json();
            const tbody = document.getElementById('cartBody');
            let total = 0;

            if (items.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="5" class="text-center py-10 text-gray-500">
                            <div class="flex flex-col items-center">
                                <i class="fas fa-shopping-basket text-4xl mb-3 text-gray-300"></i>
                                <span class="text-lg">您的购物车是空的。</span>
                                <a href="index.jsp" class="mt-4 text-indigo-600 hover:underline">去购物</a>
                            </div>
                        </td>
                    </tr>`;
            } else {
                tbody.innerHTML = items.map(item => {
                    const subtotal = item.book.price * item.quantity;
                    total += subtotal;
                    return `
                        <tr class="hover:bg-gray-50 transition-colors">
                            <td class="py-4 px-4">
                                <span class="font-bold text-gray-800">\${item.book.title}</span>
                                <br><span class="text-xs text-gray-400">\${item.book.author}</span>
                            </td>
                            <td class="py-4 px-4 text-indigo-600 font-semibold">¥\${item.book.price}</td>
                            <td class="py-4 px-4">
                                <span class="bg-gray-100 px-3 py-1 rounded-full text-xs font-bold">\${item.quantity}</span>
                            </td>
                            <td class="py-4 px-4 font-bold">¥\${subtotal.toFixed(2)}</td>
                            <td class="py-4 px-4 text-end">
                                <button onclick="removeItem(\${item.id})" class="text-red-500 hover:text-red-700 p-2 rounded-full hover:bg-red-50 transition-colors" title="移除">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </td>
                        </tr>
                    `;
                }).join('');
            }
            document.getElementById('totalAmount').innerText = total.toFixed(2);
        }

        async function removeItem(id) {
            Swal.fire({
                title: '确认删除？',
                text: "此操作无法撤销！",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: '确认删除',
                cancelButtonText: '取消'
            }).then(async (result) => {
                if (result.isConfirmed) {
                    await fetch('/api/cart/item/' + id, { method: 'DELETE' });
                    loadCart();
                    Swal.fire(
                        '已删除！',
                        '商品已从购物车移除',
                        'success'
                    )
                }
            })
        }

        function checkout() {
            if (document.getElementById('cartBody').innerText.includes('您的购物车是空的')) {
                Swal.fire({
                    icon: 'info',
                    title: '购物车为空',
                    text: '请先添加商品'
                });
                return;
            }

            Swal.fire({
                title: '确认结算？',
                text: "立即进行结算？",
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#4f46e5',
                cancelButtonColor: '#d33',
                confirmButtonText: '确认购买',
                cancelButtonText: '取消'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Direct redirect to index.jsp as requested
                    window.location.href = 'index.jsp';
                }
            })
        }

        loadCart();
    </script>
</body>
</html>
